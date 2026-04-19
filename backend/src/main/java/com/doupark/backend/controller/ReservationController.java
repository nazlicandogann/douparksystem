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
@CrossOrigin(origins = "*")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    // CREATE — frontend'den düz { parkingId, plateNumber, startTime, endTime } gelir
    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody ReservationDTO dto,
            Authentication auth) {

        String email = auth.getName();

        // DTO → Reservation entity dönüşümü
        Reservation reservation = new Reservation();

        Parking parking = new Parking();
        parking.setId(dto.getParkingId());
        reservation.setParking(parking);

        reservation.setPlateNumber(dto.getPlateNumber());

        if (dto.getStartTime() != null) {
            reservation.setStartTime(LocalDateTime.parse(dto.getStartTime()));
        }
        if (dto.getEndTime() != null) {
            reservation.setEndTime(LocalDateTime.parse(dto.getEndTime()));
        }

        return ResponseEntity.ok(
                reservationService.createReservation(reservation, email)
        );
    }

    // USER RESERVATIONS
    @GetMapping
    public ResponseEntity<List<Reservation>> getMyReservations(Authentication auth) {
        String email = auth.getName();
        return ResponseEntity.ok(
                reservationService.getUserReservations(email)
        );
    }

    // ALL (ADMIN)
    @GetMapping("/all")
    public ResponseEntity<List<Reservation>> getAllReservations() {
        return ResponseEntity.ok(
                reservationService.getAllReservations()
        );
    }

    // CANCEL
    @DeleteMapping("/{id}")
    public ResponseEntity<?> cancelReservation(@PathVariable Long id) {
        reservationService.cancelReservation(id);
        return ResponseEntity.ok("Reservation cancelled");
    }
}
