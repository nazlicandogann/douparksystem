package com.doupark.backend.controller;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.service.ParkingService;
import com.doupark.backend.util.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/parking")
@CrossOrigin(origins = "*")
public class ParkingController {

    private final ParkingService parkingService;
    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;

    public ParkingController(ParkingService parkingService,
                             UserRepository userRepository,
                             JwtUtil jwtUtil) {
        this.parkingService = parkingService;
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/add")
    public String addParking(@RequestBody Parking parking,
                             @RequestHeader("Authorization") String token) {
        String email = jwtUtil.extractEmail(token.replace("Bearer ", ""));
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));
        if (!user.getRole().equals("ADMIN")) {
            throw new RuntimeException("Access denied");
        }
        parkingService.addParking(parking);
        return "Parking added";
    }

    // Token ile veya token'siz erişilebilir (SecurityConfig'de permitAll var)
    @GetMapping("/all")
    public ResponseEntity<List<Map<String, Object>>> getAllParkings() {
        try {
            List<Map<String, Object>> list = parkingService.getAllParkings();
            return ResponseEntity.ok(list);
        } catch (Exception e) {
            System.err.println("[ParkingController] getAllParkings hatasi: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.ok(List.of()); // hata olsa bile boş liste dön, 500 değil
        }
    }

    @GetMapping("/{id}")
    public Parking getParking(@PathVariable Long id) {
        return parkingService.getParkingById(id);
    }

    @DeleteMapping("/{id}")
    public void deleteParking(@PathVariable Long id) {
        parkingService.deleteParking(id);
    }
}
