package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final ParkingRepository parkingRepository;

    public ReservationService(ReservationRepository reservationRepository,
                              ParkingRepository parkingRepository) {
        this.reservationRepository = reservationRepository;
        this.parkingRepository = parkingRepository;
    }

    public Reservation createReservation(Reservation reservation){

        Parking parking = parkingRepository.findById(reservation.getParkingId())
                .orElseThrow(() -> new RuntimeException("Parking not found"));

        if (parking.getAvailableSpots() <= 0) {
            throw new RuntimeException("No parking spot available");
        }

        parking.setAvailableSpots(parking.getAvailableSpots() - 1);
        parkingRepository.save(parking);

        return reservationRepository.save(reservation);
    }

    public List<Reservation> getAllReservations(){
        return reservationRepository.findAll();
    }

    public List<Reservation> getUserReservations(String email){
        return reservationRepository.findByUserEmail(email);
    }

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