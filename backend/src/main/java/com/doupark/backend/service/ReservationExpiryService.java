package com.doupark.backend.service;

import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Rezervasyon süresi dolma ve yaptırım servisi.
 *
 * Kurallar:
 * - Kullanıcı PENDING_ENTRY rezervasyonuna 15 dakika içinde giriş yapmazsa
 *   rezervasyon otomatik EXPIRED olur, park yeri serbest kalır.
 * - 1. gelmeme: uyarı (noShowCount = 1)
 * - 3. ve üzeri gelmeme: rezervasyon yapma engeli (banned = true)
 */
@Service
public class ReservationExpiryService {

    private final ReservationRepository reservationRepository;
    private final UserRepository userRepository;

    public ReservationExpiryService(ReservationRepository reservationRepository,
                                    UserRepository userRepository) {
        this.reservationRepository = reservationRepository;
        this.userRepository = userRepository;
    }

    /**
     * Her 1 dakikada bir çalışır.
     * 15 dakikadan fazla PENDING_ENTRY olan rezervasyonları expire eder.
     */
    @Scheduled(fixedDelay = 60_000) // 60 saniye
    @Transactional
    public void expireStaleReservations() {
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(15);

        List<Reservation> stale = reservationRepository
                .findByStatusAndCreatedAtBefore("PENDING_ENTRY", cutoff);

        for (Reservation r : stale) {
            r.setStatus("EXPIRED");
            reservationRepository.save(r);

            // Yaptırım uygula
            applyNoShowPenalty(r);
        }
    }

    private void applyNoShowPenalty(Reservation r) {
        if (r.getUser() == null) return;

        User user = userRepository.findById(r.getUser().getId()).orElse(null);
        if (user == null) return;

        int noShowCount = (user.getNoShowCount() != null ? user.getNoShowCount() : 0) + 1;
        user.setNoShowCount(noShowCount);

        if (noShowCount >= 3) {
            user.setReservationBanned(true);
        }

        userRepository.save(user);
    }

    /**
     * Kullanıcının ban durumunu kontrol eder.
     */
    public boolean isUserBanned(String email) {
        return userRepository.findByEmail(email)
                .map(u -> Boolean.TRUE.equals(u.getReservationBanned()))
                .orElse(false);
    }

    /**
     * Kullanıcının no-show sayısını döner.
     */
    public int getNoShowCount(String email) {
        return userRepository.findByEmail(email)
                .map(u -> u.getNoShowCount() != null ? u.getNoShowCount() : 0)
                .orElse(0);
    }
}
