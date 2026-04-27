package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects; 
import java.util.stream.Collectors;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ParkingRepository parkingRepository;
    private final UserRepository userRepository;

    public ReservationService(ReservationRepository reservationRepository,
                              ParkingRepository parkingRepository,
                              UserRepository userRepository) {
        this.reservationRepository = reservationRepository;
        this.parkingRepository = parkingRepository;
        this.userRepository = userRepository;
    }

    // CREATE
    public Reservation createReservation(Reservation reservation, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        reservation.setUser(user);

        Parking parking = parkingRepository.findById(reservation.getParking().getId())
                .orElseThrow(() -> new RuntimeException("Parking not found"));
        reservation.setParking(parking);

        long activeCount = reservationRepository.countByParking_IdAndStatus(parking.getId(), "ACTIVE");
        int availableSpots = parking.getTotalSpots() - (int) activeCount;

        if (availableSpots <= 0) {
            throw new RuntimeException("No parking spot available");
        }

        reservation.setStatus("ACTIVE");
        if (reservation.getStartTime() == null) {
            reservation.setStartTime(LocalDateTime.now());
        }

        return reservationRepository.save(reservation);
    }

    // TÜMÜ (ADMIN için)
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    // USER'A GÖRE
    public List<Reservation> getUserReservations(String email) {
        return reservationRepository.findByUser_Email(email);
    }

    // CANCEL
    public void cancelReservation(Long id) {
        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reservation not found"));

        reservation.setStatus("DONE");
        reservation.setEndTime(LocalDateTime.now());
        reservationRepository.save(reservation);
    }

    // DOLU KOLTUKLARI GETİR
    public List<Integer> getOccupiedSpotIndices(Long parkingId) {
        // findByParkingId metodunu Repository'ye eklemelisin!
        return reservationRepository.findByParkingId(parkingId).stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()))
                .map(Reservation::getSelectedSpotIndex)
                .filter(Objects::nonNull) // Objects import edildiği için artık hata vermez
                .collect(Collectors.toList());
    }
}