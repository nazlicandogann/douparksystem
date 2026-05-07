package com.doupark.backend.controller;

import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.ReservationService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Çıkış Bariyeri Endpoint'i
 *
 * Çıkış kamerası plakayı okur → bu endpoint'i çağırır →
 * Süre hesaplanır → Cüzdandan çekilir → Bariyer açılır.
 */
@RestController
@RequestMapping("/api/exit")
@CrossOrigin(origins = "*")
public class ExitController {

    private final ReservationService reservationService;

    public ExitController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    /**
     * POST /api/exit/plate
     * Body: { "plateNumber": "34ABC123" }
     *
     * Dönüş:
     *   200 → { barrierOpen: true, chargedAmount, durationMinutes, remainingBalance }
     *   400 → hata mesajı (yetersiz bakiye, plaka bulunamadı vb.)
     */
    @PostMapping("/plate")
    public ResponseEntity<?> processExit(@RequestBody Map<String, String> body) {
        String plateNumber = body.get("plateNumber");
        if (plateNumber == null || plateNumber.isBlank()) {
            return ResponseEntity.badRequest().body("Plaka numarası boş olamaz");
        }

        // Büyük harf + boşluk temizle (kamera çıktısı normalize)
        plateNumber = plateNumber.trim().toUpperCase().replaceAll("\\s+", "");

        try {
            Reservation reservation = reservationService.processPlateExit(plateNumber);

            long durationMinutes = 0;
            if (reservation.getActualEntryTime() != null && reservation.getActualExitTime() != null) {
                durationMinutes = java.time.temporal.ChronoUnit.MINUTES.between(
                        reservation.getActualEntryTime(),
                        reservation.getActualExitTime()
                );
            }

            return ResponseEntity.ok(Map.of(
                    "barrierOpen",      true,
                    "message",          "Çıkış onaylandı. Güle güle!",
                    "plateNumber",      reservation.getPlateNumber(),
                    "durationMinutes",  durationMinutes,
                    "chargedAmount",    reservation.getChargedAmount(),
                    "entryTime",        reservation.getActualEntryTime() != null
                                            ? reservation.getActualEntryTime().toString() : "N/A",
                    "exitTime",         reservation.getActualExitTime().toString()
            ));

        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "barrierOpen", false,
                    "message",     e.getMessage()
            ));
        }
    }
}
