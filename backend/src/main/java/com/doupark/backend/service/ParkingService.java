package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.repository.ParkingRepository;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        List<Map<String, Object>> result = new ArrayList<>();

        for (Object[] row : data) {
            Map<String, Object> map = new HashMap<>();
            // Native SQL'den gelen değerler BigInteger/BigDecimal/Long olabilir
            // Her birini Number cast ile güvenle okuyoruz
            map.put("id",             row[0] != null ? ((Number) row[0]).longValue() : 0L);
            map.put("parkingName",    row[1] != null ? row[1].toString() : "Bilinmeyen Otopark");
            map.put("totalSpots",     row[2] != null ? ((Number) row[2]).intValue() : 0);
            map.put("availableSpots", row[3] != null ? ((Number) row[3]).intValue() : 0);
            result.add(map);
        }
        return result;
    }

    public Parking getParkingById(Long id) {
        return parkingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Parking not found"));
    }

    public void deleteParking(Long id) {
        parkingRepository.deleteById(id);
    }
}
