package com.doupark.backend.controller;

import com.doupark.backend.dto.ReservationDTO;
import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.ReservationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*") // Frontend erişimi için CORS izni 
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    /**
     * Rezervasyon Oluşturma
     * Frontend'den gelen düz JSON verisini DTO ile karşılar.
     */
    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody ReservationDTO dto, 
            Authentication auth) {

        // JWT üzerinden kullanıcı emailini al 
        String email = auth.getName();

        // DTO'dan Entity'ye dönüşüm (Mapping) 
        Reservation reservation = new Reservation();
        
        // Otopark eşleştirmesi
        Parking parking = new Parking();
        // DTO'daki int değeri Long olarak set edildi.
parking.setId(Long.valueOf(dto.getParkingId()));
        reservation.setParking(parking);

        // Kullanıcının haritadan seçtiği kutucuk (spot) numarası
        // Not: Reservation entity'nizde 'selectedSpotIndex' alanı tanımlanmış olmalıdır.
        reservation.setSelectedSpotIndex(dto.getSelectedSpotIndex());
        
        // Plaka bilgisi (Artık hardcoded değil, kullanıcıdan geliyor) [cite: 20, 55]
        reservation.setPlateNumber(dto.getPlateNumber());

        // Tarih formatlama (ISO-8601 formatında string beklenir) 
        try {
            if (dto.getStartTime() != null) {
                reservation.setStartTime(LocalDateTime.parse(dto.getStartTime()));
            }
            if (dto.getEndTime() != null) {
                reservation.setEndTime(LocalDateTime.parse(dto.getEndTime()));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Geçersiz tarih formatı. Lütfen ISO-8601 kullanın.");
        }

        // Rezervasyonu servis katmanı üzerinden kaydet 
        Reservation created = reservationService.createReservation(reservation, email);
        return ResponseEntity.ok(created);
    }

    /**
     * Giriş yapmış kullanıcının kendi rezervasyonlarını listeler[cite: 20, 54].
     */
    @GetMapping
    public ResponseEntity<List<Reservation>> getMyReservations(Authentication auth) {
        String email = auth.getName();
        return ResponseEntity.ok(
                reservationService.getUserReservations(email)
        );
    }
    //Rezerve olan yerlerin krımızı gözükmesi
    @GetMapping("/occupied-spots/{parkingId}")
public ResponseEntity<List<Integer>> getOccupiedSpots(@PathVariable Long parkingId) {
    List<Integer> spots = reservationService.getOccupiedSpotIndices(parkingId);
    return ResponseEntity.ok(spots);
}

    /**
     * Tüm rezervasyonları listeler (Admin paneli için).
     */
    @GetMapping("/all")
    public ResponseEntity<List<Reservation>> getAllReservations() {
        return ResponseEntity.ok(
                reservationService.getAllReservations()
        );
    }

    /**
     * Rezervasyon İptali
     * Kaydı silmek yerine durumunu 'DONE' veya 'CANCELLED' olarak günceller.
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> cancelReservation(@PathVariable Long id) {
        reservationService.cancelReservation(id);
        return ResponseEntity.ok("Rezervasyon başarıyla iptal edildi.");
    }
}