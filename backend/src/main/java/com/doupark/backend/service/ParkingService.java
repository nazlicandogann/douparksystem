package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.repository.ParkingRepository;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;                          // ✅ Missing import added
import java.util.stream.Collectors;            // ✅ Cleaner import

@Service
public class ParkingService {

    private final ParkingRepository parkingRepository;

    public ParkingService(ParkingRepository parkingRepository) {
        this.parkingRepository = parkingRepository;
    }

    public Parking addParking(Parking parking) {
        return parkingRepository.save(parking);
    }

    public List<Map<String, Object>> getAllParkings() {

        List<Object[]> data = parkingRepository.getAllWithAvailable();

        return data.stream().map(row -> {
            Map<String, Object> map = new HashMap<>();
            map.put("id",             row[0]);
            map.put("location",       row[1]);
            map.put("totalSpots",     row[2]);
            map.put("availableSpots", row[3]);
            return map;
        }).collect(Collectors.toList());        // ✅ Cleaner, no inline class ref
    }

    public Parking getParkingById(Long id) {
        return parkingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Parking not found"));
    }

    public void deleteParking(Long id) {
        parkingRepository.deleteById(id);
    }
}