package com.doupark.backend.repository;

import com.doupark.backend.entity.Parking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ParkingRepository extends JpaRepository<Parking, Long> {

   @Query("""
SELECT p.id, p.location, p.totalSpots,
(p.totalSpots - COUNT(r.id))
FROM Parking p
LEFT JOIN Reservation r 
ON r.parking = p AND r.status = 'ACTIVE'
GROUP BY p.id
""")
List<Object[]> getAllWithAvailable();
}