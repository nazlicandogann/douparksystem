package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.List;

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
    public Reservation createReservation(Reservation reservation, String email){

        // USER BUL
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        reservation.setUser(user); // EN KRİTİK SATIR

        Parking parking = parkingRepository.findById(reservation.getParkingId())
                .orElseThrow(() -> new RuntimeException("Parking not found"));

        if (parking.getAvailableSpots() <= 0) {
            throw new RuntimeException("No parking spot available");
        }

        parking.setAvailableSpots(parking.getAvailableSpots() - 1);
        parkingRepository.save(parking);

        return reservationRepository.save(reservation);
    }

    // TÜMÜ (ADMIN için)
    public List<Reservation> getAllReservations(){
        return reservationRepository.findAll();
    }

    // USER’A GÖRE
    public List<Reservation> getUserReservations(String email){
        return reservationRepository.findByUser_Email(email);
    }

    // CANCEL
    public void cancelReservation(Long id){

        Reservation reservation = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reservation not found"));

        Parking parking = parkingRepository.findById(reservation.getParkingId())
                .orElseThrow(() -> new RuntimeException("Parking not found"));

        parking.setAvailableSpots(parking.getAvailableSpots() + 1);
        parkingRepository.save(parking);

        reservationRepository.deleteById(id);
    }
}