package com.doupark.backend.controller;

import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.ReservationService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservations")
@CrossOrigin(origins = "*")
public class ReservationController {

    private final ReservationService reservationService;

    public ReservationController(ReservationService reservationService) {
        this.reservationService = reservationService;
    }

    //  CREATE
    @PostMapping
    public ResponseEntity<?> createReservation(
            @RequestBody Reservation reservation,
            Authentication auth) {

        String email = auth.getName(); //  JWT'den otomatik geliyor

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

    //  ALL
    @GetMapping("/all")
    public ResponseEntity<List<Reservation>> getAllReservations() {
        return ResponseEntity.ok(
                reservationService.getAllReservations()
        );
    }

    //  DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<?> cancelReservation(@PathVariable Long id) {

        reservationService.cancelReservation(id);

        return ResponseEntity.ok("Reservation cancelled");
    }
}