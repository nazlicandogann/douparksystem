package com.doupark.backend.controller;

import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.QrService;
import com.doupark.backend.service.ReservationService;
import com.doupark.backend.repository.ReservationRepository;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/qr")
@CrossOrigin(origins = "*")
public class QrController {

    private final ReservationService reservationService;
    private final QrService qrService;
    private final ReservationRepository reservationRepository;

    public QrController(ReservationService reservationService, QrService qrService,
                        ReservationRepository reservationRepository) {
        this.reservationService = reservationService;
        this.qrService = qrService;
        this.reservationRepository = reservationRepository;
    }

    /**
     * QR token metnini döner (Flutter tarafında QR render için).
     * GET /api/qr/token/{reservationId}
     */
    @GetMapping("/token/{reservationId}")
    public ResponseEntity<?> getQrToken(
            @PathVariable Long reservationId,
            Authentication auth) {

        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new RuntimeException("Rezervasyon bulunamadi: " + reservationId));

        // Rezervasyonun sahibi mi kontrol et
        if (!reservation.getUser().getEmail().equals(auth.getName())) {
            return ResponseEntity.status(403).body(Map.of("error", "Bu rezervasyon size ait degil"));
        }

        return ResponseEntity.ok(Map.of(
                "reservationId", reservation.getId(),
                "qrToken",       reservation.getQrToken(),
                "qrUsed",        reservation.isQrUsed(),
                "status",        reservation.getStatus()
        ));
    }

    /**
     * QR gorsel olarak doner (PNG).
     * GET /api/qr/generate/{reservationId}
     */
    @GetMapping(value = "/generate/{reservationId}", produces = MediaType.IMAGE_PNG_VALUE)
    public ResponseEntity<byte[]> generateQrImage(
            @PathVariable Long reservationId,
            Authentication auth) {

        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new RuntimeException("Rezervasyon bulunamadi"));

        if (!reservation.getUser().getEmail().equals(auth.getName())) {
            return ResponseEntity.status(403).build();
        }

        if (reservation.isQrUsed()) {
            return ResponseEntity.badRequest().build();
        }

        byte[] qrImage = qrService.generateQrImageBytes(reservation.getQrToken());
        return ResponseEntity.ok().contentType(MediaType.IMAGE_PNG).body(qrImage);
    }

    /**
     * Giris bariyeri - otomat cagirir.
     * POST /api/qr/entry
     */
    @PostMapping("/entry")
    public ResponseEntity<?> processEntry(@RequestBody Map<String, String> body) {
        String qrToken = body.get("qrToken");
        if (qrToken == null || qrToken.isBlank()) {
            return ResponseEntity.badRequest().body("QR token bos olamaz");
        }

        try {
            Reservation reservation = reservationService.processQrEntry(qrToken);
            return ResponseEntity.ok(Map.of(
                    "barrierOpen",  true,
                    "message",      "Giris onaylandi. Iyi parklar!",
                    "plateNumber",  reservation.getPlateNumber(),
                    "parkingName",  reservation.getParking().getParkingName(),
                    "spotIndex",    reservation.getSelectedSpotIndex() != null
                                        ? reservation.getSelectedSpotIndex() : "N/A",
                    "entryTime",    reservation.getActualEntryTime().toString()
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                    "barrierOpen", false,
                    "message",     e.getMessage()
            ));
        }
    }
}