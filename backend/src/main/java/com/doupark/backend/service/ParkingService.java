package com.doupark.backend.service;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.repository.ParkingRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ParkingService {

    private final ParkingRepository parkingRepository;

    public ParkingService(ParkingRepository parkingRepository) {
        this.parkingRepository = parkingRepository;
    }

    public Parking addParking(Parking parking){
        return parkingRepository.save(parking);
    }

    public List<Parking> getAllParkings(){
        return parkingRepository.findAll();
    }

    public Parking getParkingById(Long id){
        return parkingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Parking not found"));
    }

    public void deleteParking(Long id){
        parkingRepository.deleteById(id);
    }
}