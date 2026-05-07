package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.ParkingPricingRule;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ParkingPricingRuleRepository;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ParkingRepository parkingRepository;
    private final UserRepository userRepository;
    private final QrService qrService;
    private final WalletService walletService;
    private final ParkingPricingRuleRepository pricingRuleRepository;

    public ReservationService(ReservationRepository reservationRepository,
                              ParkingRepository parkingRepository,
                              UserRepository userRepository,
                              QrService qrService,
                              WalletService walletService,
                              ParkingPricingRuleRepository pricingRuleRepository) {
        this.reservationRepository = reservationRepository;
        this.parkingRepository = parkingRepository;
        this.userRepository = userRepository;
        this.qrService = qrService;
        this.walletService = walletService;
        this.pricingRuleRepository = pricingRuleRepository;
    }

    // ── REZERVASYON OLUŞTURMA ─────────────────────────────────────────────────
    @Transactional
    public Reservation createReservation(Reservation reservation, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        reservation.setUser(user);

        Parking parking = parkingRepository.findById(reservation.getParking().getId())
                .orElseThrow(() -> new RuntimeException("Otopark bulunamadı"));
        reservation.setParking(parking);

        long activeCount = reservationRepository.countByParking_IdAndStatus(parking.getId(), "PARKED")
                         + reservationRepository.countByParking_IdAndStatus(parking.getId(), "PENDING_ENTRY");
        if (activeCount >= parking.getTotalSpots()) {
            throw new RuntimeException("Otoparkta boş yer yok");
        }

        // 🔑 Tek kullanımlık QR token üret
        String qrToken = qrService.generateQrToken();
        reservation.setQrToken(qrToken);
        reservation.setQrUsed(false);

        // Durum: kullanıcı henüz girmedi
        reservation.setStatus("PENDING_ENTRY");

        if (reservation.getStartTime() == null) {
            reservation.setStartTime(LocalDateTime.now());
        }

        return reservationRepository.save(reservation);
    }

    // ── QR OKUTMA — BARIYER GİRİŞİ ───────────────────────────────────────────
    /**
     * Otomat QR okuyucu bu endpoint'i çağırır.
     * Token geçerliyse ve daha önce kullanılmamışsa bariyeri açar.
     */
    @Transactional
    public Reservation processQrEntry(String qrToken) {
        Reservation reservation = reservationRepository.findByQrToken(qrToken)
                .orElseThrow(() -> new RuntimeException("Geçersiz QR kodu"));

        if (reservation.isQrUsed()) {
            throw new RuntimeException("Bu QR kodu daha önce kullanıldı");
        }
        if (!"PENDING_ENTRY".equals(reservation.getStatus())) {
            throw new RuntimeException("Rezervasyon uygun durumda değil: " + reservation.getStatus());
        }

        // QR kullanıldı işaretle, araç içeride
        reservation.setQrUsed(true);
        reservation.setActualEntryTime(LocalDateTime.now());
        reservation.setStatus("PARKED");

        return reservationRepository.save(reservation);
    }

    // ── PLAKA OKUMA — BARIYER ÇIKIŞI + ÖDEME ─────────────────────────────────
    /**
     * Çıkış kamerası plakayı okuyup bu endpoint'i çağırır.
     * Süreye göre ücret hesaplanır, cüzdandan çekilir, bariyer açılır.
     */
    @Transactional
    public Reservation processPlateExit(String plateNumber) {
        Reservation reservation = reservationRepository
                .findByPlateNumberAndStatus(plateNumber, "PARKED")
                .orElseThrow(() -> new RuntimeException(
                        "Bu plakaya ait aktif park kaydı bulunamadı: " + plateNumber));

        LocalDateTime exitTime = LocalDateTime.now();
        reservation.setActualExitTime(exitTime);
        reservation.setStatus("DONE");
        reservation.setEndTime(exitTime);

        // 💰 Ücret hesapla
        BigDecimal fee = calculateFee(reservation);
        reservation.setChargedAmount(fee);

        // 💳 Cüzdandan çek
        walletService.charge(
                reservation.getUser().getEmail(),
                fee,
                reservation.getId()
        );

        return reservationRepository.save(reservation);
    }

    // ── ÜCRETLENDİRME ────────────────────────────────────────────────────────
    private BigDecimal calculateFee(Reservation reservation) {
        LocalDateTime entry = reservation.getActualEntryTime();
        LocalDateTime exit  = reservation.getActualExitTime();

        if (entry == null || exit == null) return BigDecimal.ZERO;

        long totalMinutes = ChronoUnit.MINUTES.between(entry, exit);

        // Fiyat kuralını getir
        ParkingPricingRule rule = pricingRuleRepository
                .findByParking_Id(reservation.getParking().getId())
                .orElse(null);

        // Kural yoksa varsayılan: saatte 20 TL, ücretsiz ilk 0 dakika
        BigDecimal pricePerHour = rule != null ? rule.getPricePerHour() : new BigDecimal("20.00");
        int freeMinutes         = rule != null ? rule.getFreeMinutes()  : 0;
        int minimumMinutes      = rule != null ? rule.getMinimumMinutes() : 30;

        long billableMinutes = totalMinutes - freeMinutes;
        if (billableMinutes <= 0) return BigDecimal.ZERO;

        // Minimum süre uygulaması
        billableMinutes = Math.max(billableMinutes, minimumMinutes);

        // Ücret = (dakika / 60) * saatlik fiyat
        BigDecimal hours = new BigDecimal(billableMinutes).divide(new BigDecimal("60"), 4, RoundingMode.HALF_UP);
        BigDecimal fee = hours.multiply(pricePerHour).setScale(2, RoundingMode.HALF_UP);

        return fee;
    }

    // ── DİĞER MEVCUT METODLAR ─────────────────────────────────────────────────
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    public List<Reservation> getUserReservations(String email) {
        return reservationRepository.findByUser_Email(email);
    }

    @Transactional
    public void cancelReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Rezervasyon bulunamadı"));

        if ("PARKED".equals(reservation.getStatus())) {
            throw new RuntimeException("Araç içerideyken rezervasyon iptal edilemez. Lütfen çıkış yapın.");
        }

        reservation.setStatus("CANCELLED");
        reservation.setEndTime(LocalDateTime.now());
        reservationRepository.save(reservation);
    }

    public List<Integer> getOccupiedSpotIndices(Long parkingId) {
        return reservationRepository.findByParkingId(parkingId).stream()
                .filter(r -> "PARKED".equals(r.getStatus()) || "PENDING_ENTRY".equals(r.getStatus()))
                .map(Reservation::getSelectedSpotIndex)
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }
    
    // ── TEK REZERVASYON GETİRME ────────────────────────────────────────────────
    public Reservation getReservationById(Long id) {
        return reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Rezervasyon bulunamadı: " + id));
    }
}
