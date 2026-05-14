package com.doupark.backend.controller;

import com.doupark.backend.dto.ReservationDTO;
import com.doupark.backend.service.ReservationExpiryService;
import com.doupark.backend.dto.ReservationResponseDTO;
import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.ReservationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
public class ReservationController {

    private final ReservationService reservationService;
    private final ReservationExpiryService expiryService;

    public ReservationController(ReservationService reservationService,
                                  ReservationExpiryService expiryService) {
        this.reservationService = reservationService;
        this.expiryService = expiryService;
    }

    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody ReservationDTO dto,
            Authentication auth) {

        String email = auth.getName();

        // Yaptırım kontrolü: Kullanıcı ban'lı mı?
        if (expiryService.isUserBanned(email)) {
            return ResponseEntity.status(403).body(
                "Rezervasyon yapma yetkiniz kaldırılmıştır. Üç veya daha fazla rezervasyona gelmediğiniz tespit edilmiştir. Lütfen yönetici ile iletişime geçin."
            );
        }

        // Uyarı: İlk no-show
        int noShowCount = expiryService.getNoShowCount(email);
        // (Bilgi amaçlı, ban 3'ten başlıyor)

        // Bug #9 Düzeltme: Tarih validasyonu
        LocalDateTime startTime = null;
        LocalDateTime endTime = null;

        try {
            if (dto.getStartTime() != null) {
                startTime = LocalDateTime.parse(dto.getStartTime());
            }
            if (dto.getEndTime() != null) {
                endTime = LocalDateTime.parse(dto.getEndTime());
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Geçersiz tarih formatı. Lütfen ISO-8601 kullanın. Örnek: 2026-05-13T10:00:00");
        }

        // Bug #9 Düzeltme: Geçmiş tarih kontrolü
        if (startTime != null && startTime.isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Başlangıç tarihi geçmiş bir tarih olamaz.");
        }

        // Bug #9 Düzeltme: Bitiş başlangıçtan önce olamaz
        if (startTime != null && endTime != null && endTime.isBefore(startTime)) {
            return ResponseEntity.badRequest().body("Bitiş tarihi başlangıç tarihinden önce olamaz.");
        }

        // Bug #9 Düzeltme: En az 15 dakika
        if (startTime != null && endTime != null && endTime.isBefore(startTime.plusMinutes(15))) {
            return ResponseEntity.badRequest().body("Rezervasyon süresi en az 15 dakika olmalıdır.");
        }

        Reservation reservation = new Reservation();
        Parking parking = new Parking();
        parking.setId(Long.valueOf(dto.getParkingId()));
        reservation.setParking(parking);
        reservation.setSelectedSpotIndex(dto.getSelectedSpotIndex());
        reservation.setPlateNumber(dto.getPlateNumber());
        reservation.setStartTime(startTime);
        reservation.setEndTime(endTime);

        Reservation created = reservationService.createReservation(reservation, email);

        // Bug #6 Düzeltme: Entity yerine DTO dön (password hash gizlendi)
        return ResponseEntity.ok(ReservationResponseDTO.from(created));
    }

    @GetMapping
    public ResponseEntity<List<ReservationResponseDTO>> getMyReservations(Authentication auth) {
        String email = auth.getName();
        List<ReservationResponseDTO> list = reservationService.getUserReservations(email)
                .stream()
                .map(ReservationResponseDTO::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    @GetMapping("/occupied-spots/{parkingId}")
    public ResponseEntity<List<Integer>> getOccupiedSpots(
            @PathVariable Long parkingId,
            @RequestParam(required = false) String startTime,
            @RequestParam(required = false) String endTime) {

        List<Integer> spots;

        // startTime ve endTime verilmişse tarih bazlı filtrele
        if (startTime != null && endTime != null) {
            try {
                LocalDateTime start = LocalDateTime.parse(startTime);
                LocalDateTime end = LocalDateTime.parse(endTime);
                spots = reservationService.getOccupiedSpotIndicesForTime(parkingId, start, end);
            } catch (Exception e) {
                spots = reservationService.getOccupiedSpotIndices(parkingId);
            }
        } else {
            spots = reservationService.getOccupiedSpotIndices(parkingId);
        }

        return ResponseEntity.ok(spots);
    }

    @GetMapping("/all")
    public ResponseEntity<List<ReservationResponseDTO>> getAllReservations() {
        List<ReservationResponseDTO> list = reservationService.getAllReservations()
                .stream()
                .map(ReservationResponseDTO::from)
                .collect(Collectors.toList());
        return ResponseEntity.ok(list);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationResponseDTO> getReservationById(@PathVariable Long id) {
        Reservation res = reservationService.getReservationById(id);
        if (res == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(ReservationResponseDTO.from(res));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> cancelReservation(@PathVariable Long id) {
        reservationService.cancelReservation(id);
        return ResponseEntity.ok("Rezervasyon başarıyla iptal edildi.");
    }
}
