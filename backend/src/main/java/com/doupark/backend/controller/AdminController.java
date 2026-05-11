package com.doupark.backend.controller;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.service.ParkingService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Admin Panel Endpoint'leri
 * Tüm endpoint'ler ADMIN rolü gerektirir.
 * SecurityConfig'de /api/admin/** hasRole("ADMIN") ile korunur.
 */
@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    private final UserRepository userRepository;
    private final ReservationRepository reservationRepository;
    private final ParkingRepository parkingRepository;
    private final ParkingService parkingService;

    public AdminController(UserRepository userRepository,
                           ReservationRepository reservationRepository,
                           ParkingRepository parkingRepository,
                           ParkingService parkingService) {
        this.userRepository = userRepository;
        this.reservationRepository = reservationRepository;
        this.parkingRepository = parkingRepository;
        this.parkingService = parkingService;
    }

    // ── KULLANICILAR ─────────────────────────────────────────────────────────

    /** Tüm kullanıcıları listele */
    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers(Authentication auth) {
        checkAdmin(auth);
        return ResponseEntity.ok(userRepository.findAll());
    }

    /** Kullanıcı rolünü değiştir (USER ↔ ADMIN) */
    @PutMapping("/users/{id}/role")
    public ResponseEntity<?> updateUserRole(@PathVariable Long id,
                                             @RequestBody Map<String, String> body,
                                             Authentication auth) {
        checkAdmin(auth);
        String newRole = body.get("role");
        if (newRole == null || (!newRole.equals("USER") && !newRole.equals("ADMIN"))) {
            return ResponseEntity.badRequest().body(Map.of("error", "Geçersiz rol. USER veya ADMIN olmalı."));
        }
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        user.setRole(newRole);
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Rol güncellendi", "email", user.getEmail(), "role", newRole));
    }

    /** Kullanıcı sil */
    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        if (!userRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        userRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Kullanıcı silindi"));
    }

    // ── REZERVASYONLAR ───────────────────────────────────────────────────────

    /** Tüm rezervasyonları listele */
    @GetMapping("/reservations")
    public ResponseEntity<List<Reservation>> getAllReservations(Authentication auth) {
        checkAdmin(auth);
        return ResponseEntity.ok(reservationRepository.findAll());
    }

    /** Rezervasyon durumunu güncelle */
    @PutMapping("/reservations/{id}/status")
    public ResponseEntity<?> updateReservationStatus(@PathVariable Long id,
                                                      @RequestBody Map<String, String> body,
                                                      Authentication auth) {
        checkAdmin(auth);
        Reservation res = reservationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Rezervasyon bulunamadı"));
        res.setStatus(body.get("status"));
        reservationRepository.save(res);
        return ResponseEntity.ok(Map.of("message", "Durum güncellendi"));
    }

    /** Rezervasyon sil */
    @DeleteMapping("/reservations/{id}")
    public ResponseEntity<?> deleteReservation(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        if (!reservationRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        reservationRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Rezervasyon silindi"));
    }

    // ── OTOPARKLAR ───────────────────────────────────────────────────────────

    /** Otopark ekle */
    @PostMapping("/parkings")
    public ResponseEntity<?> addParking(@RequestBody Parking parking, Authentication auth) {
        checkAdmin(auth);
        Parking saved = parkingService.addParking(parking);
        return ResponseEntity.ok(saved);
    }

    /** Otopark güncelle */
    @PutMapping("/parkings/{id}")
    public ResponseEntity<?> updateParking(@PathVariable Long id,
                                            @RequestBody Parking body,
                                            Authentication auth) {
        checkAdmin(auth);
        Parking parking = parkingRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Otopark bulunamadı"));
        if (body.getParkingName() != null) parking.setParkingName(body.getParkingName());
        if (body.getCode() != null) parking.setCode(body.getCode());
        if (body.getStatus() != null) parking.setStatus(body.getStatus());
        if (body.getTotalSpots() > 0) parking.setTotalSpots(body.getTotalSpots());
        parkingRepository.save(parking);
        return ResponseEntity.ok(Map.of("message", "Otopark güncellendi"));
    }

    /** Otopark sil */
    @DeleteMapping("/parkings/{id}")
    public ResponseEntity<?> deleteParking(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        if (!parkingRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        parkingRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Otopark silindi"));
    }

    // ── DASHBOARD İSTATİSTİKLERİ ──────────────────────────────────────────

    @GetMapping("/stats")
    public ResponseEntity<?> getStats(Authentication auth) {
        checkAdmin(auth);
        long totalUsers = userRepository.count();
        long totalReservations = reservationRepository.count();
        long totalParkings = parkingRepository.count();
        long activeReservations = reservationRepository.findAll().stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()) || "WAITING".equals(r.getStatus()))
                .count();
        return ResponseEntity.ok(Map.of(
                "totalUsers", totalUsers,
                "totalReservations", totalReservations,
                "totalParkings", totalParkings,
                "activeReservations", activeReservations
        ));
    }

    // ── YARDIMCI ─────────────────────────────────────────────────────────────

    private void checkAdmin(Authentication auth) {
        String email = auth.getName();
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        if (!"ADMIN".equals(user.getRole())) {
            throw new RuntimeException("Erişim reddedildi. Admin yetkisi gerekli.");
        }
    }
}
