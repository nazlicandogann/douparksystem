package com.doupark.backend.repository;

import com.doupark.backend.entity.Parking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ParkingRepository extends JpaRepository<Parking, Long> {

    // row[0]=id, row[1]=parkingName, row[2]=totalSpots, row[3]=availableSpots
    @Query(value = """
        SELECT p.id,
               COALESCE(p.parking_name, 'Bilinmeyen Otopark') AS parkingName,
               COALESCE(p.total_spots, 0)                      AS totalSpots,
               COALESCE(p.total_spots, 0) - (
                   SELECT COUNT(*) FROM reservation r
                   WHERE r.parking_id = p.id AND r.status = 'ACTIVE'
               )                                               AS availableSpots
        FROM parking p
        """, nativeQuery = true)
    List<Object[]> getAllWithAvailable();
}
