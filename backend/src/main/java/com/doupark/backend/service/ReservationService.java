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

        // JWT'den gelen email ile user bul
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        reservation.setUser(user);

        // Reservation içindeki parking nesnesinden id al
        Parking parking = parkingRepository.findById(reservation.getParking().getId())
                .orElseThrow(() -> new RuntimeException("Parking not found"));
        reservation.setParking(parking);

        // Mevcut aktif rezervasyon sayısını hesapla (availableSpots alanı olmadığı için dinamik)
        long activeCount = reservationRepository.countByParking_IdAndStatus(parking.getId(), "ACTIVE");
        int availableSpots = parking.getTotalSpots() - (int) activeCount;

        if (availableSpots <= 0) {
            throw new RuntimeException("No parking spot available");
        }

        // Status ve zaman set et
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

        // Status DONE yap, bitiş zamanı ekle
        // availableSpots DB'de tutulmadığından güncellemeye gerek yok,
        // count query otomatik olarak düşük gösterecek
        reservation.setStatus("DONE");
        reservation.setEndTime(LocalDateTime.now());
        reservationRepository.save(reservation);
    }
}
