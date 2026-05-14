package com.doupark.backend.controller;

import com.doupark.backend.dto.ParkingRequestDTO;
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

    @GetMapping("/users")
    public ResponseEntity<List<User>> getAllUsers(Authentication auth) {
        checkAdmin(auth);
        return ResponseEntity.ok(userRepository.findAll());
    }

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

    /**
     * Kullanıcının ban durumunu kaldır (rezervasyon hakkını geri ver)
     */
    @PutMapping("/users/{id}/unban")
    public ResponseEntity<?> unbanUser(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        user.setReservationBanned(false);
        user.setNoShowCount(0);
        userRepository.save(user);
        return ResponseEntity.ok(Map.of(
            "message", "Rezervasyon yasağı kaldırıldı",
            "email", user.getEmail()
        ));
    }

    /**
     * Kullanıcıyı manuel olarak banla
     */
    @PutMapping("/users/{id}/ban")
    public ResponseEntity<?> banUser(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı"));
        user.setReservationBanned(true);
        userRepository.save(user);
        return ResponseEntity.ok(Map.of(
            "message", "Rezervasyon yasağı uygulandı",
            "email", user.getEmail()
        ));
    }

    /**
     * Ban'lı kullanıcıları listele
     */
    @GetMapping("/users/banned")
    public ResponseEntity<?> getBannedUsers(Authentication auth) {
        checkAdmin(auth);
        var banned = userRepository.findAll().stream()
            .filter(u -> Boolean.TRUE.equals(u.getReservationBanned()))
            .map(u -> Map.of(
                "id", u.getId(),
                "name", u.getName() != null ? u.getName() : "",
                "email", u.getEmail(),
                "noShowCount", u.getNoShowCount() != null ? u.getNoShowCount() : 0,
                "reservationBanned", true
            ))
            .toList();
        return ResponseEntity.ok(banned);
    }

    /**
     * Bug #3 Düzeltme: Kullanıcı silinmeden önce rezervasyonları da silinir.
     * Cascade delete yerine manuel silme - daha güvenli.
     */
    @DeleteMapping("/users/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        if (!userRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        // Önce kullanıcının rezervasyonlarını sil
        List<Reservation> userReservations = reservationRepository.findByUser_Id(id);
        if (!userReservations.isEmpty()) {
            reservationRepository.deleteAll(userReservations);
        }
        // Sonra kullanıcıyı sil
        userRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Kullanıcı ve ilişkili rezervasyonlar silindi"));
    }

    // ── REZERVASYONLAR ───────────────────────────────────────────────────────

    @GetMapping("/reservations")
    public ResponseEntity<List<Reservation>> getAllReservations(Authentication auth) {
        checkAdmin(auth);
        return ResponseEntity.ok(reservationRepository.findAll());
    }

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

    /**
     * Bug #5 Düzeltme: Frontend'den "name" veya "parkingName" geliyorsa ikisini de handle et.
     */
    @PostMapping("/parkings")
    public ResponseEntity<?> addParking(@RequestBody ParkingRequestDTO dto, Authentication auth) {
        checkAdmin(auth);
        Parking parking = new Parking();
        parking.setParkingName(dto.getResolvedName());
        parking.setCode(dto.getCode() != null ? dto.getCode() : String.valueOf(dto.getTotalSpots()));
        parking.setStatus(dto.getStatus() != null ? dto.getStatus() : "bos");
        parking.setTotalSpots(dto.getTotalSpots());
        Parking saved = parkingService.addParking(parking);
        return ResponseEntity.ok(saved);
    }

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

    @DeleteMapping("/parkings/{id}")
    public ResponseEntity<?> deleteParking(@PathVariable Long id, Authentication auth) {
        checkAdmin(auth);
        if (!parkingRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        parkingRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "Otopark silindi"));
    }

    // ── DASHBOARD ─────────────────────────────────────────────────────────

    @GetMapping("/stats")
    public ResponseEntity<?> getStats(Authentication auth) {
        checkAdmin(auth);
        long totalUsers = userRepository.count();
        long totalReservations = reservationRepository.count();
        long totalParkings = parkingRepository.count();
        long activeReservations = reservationRepository.findAll().stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()) || "PENDING_ENTRY".equals(r.getStatus()))
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
