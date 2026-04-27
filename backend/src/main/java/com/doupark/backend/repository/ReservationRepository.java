package com.doupark.backend.repository;

import com.doupark.backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    
    List<Reservation> findByUser_Email(String email);
    
    long countByParking_IdAndStatus(Long parkingId, String status);

    List<Reservation> findByParkingId(Long parkingId); 
}