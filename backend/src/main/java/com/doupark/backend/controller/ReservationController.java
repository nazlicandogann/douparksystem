package com.doupark.backend.controller;

import com.doupark.backend.entity.Reservation;
import com.doupark.backend.service.ReservationService;
import com.doupark.backend.dto.ReservationDTO;
import com.doupark.backend.util.JwtUtil;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reservation")
public class ReservationController {

    private final ReservationService reservationService;
    private final JwtUtil jwtUtil;

    public ReservationController(ReservationService reservationService, JwtUtil jwtUtil) {
        this.reservationService = reservationService;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/create")
    public Reservation createReservation(
            @RequestBody ReservationDTO dto,
            @RequestHeader("Authorization") String token){

        String email = jwtUtil.extractEmail(token.replace("Bearer ", ""));

        Reservation reservation = new Reservation();
        reservation.setUserEmail(email);
        reservation.setParkingId(dto.getParkingId());
        reservation.setPlateNumber(dto.getPlateNumber());

        return reservationService.createReservation(reservation);
    }

    @GetMapping("/all")
    public List<Reservation> getAllReservations(){
        return reservationService.getAllReservations();
    }

    @GetMapping("/user/{email}")
    public List<Reservation> getUserReservations(@PathVariable String email){
        return reservationService.getUserReservations(email);
    }

    @DeleteMapping("/{id}")
    public void cancelReservation(@PathVariable Long id){
        reservationService.cancelReservation(id);
    }
}