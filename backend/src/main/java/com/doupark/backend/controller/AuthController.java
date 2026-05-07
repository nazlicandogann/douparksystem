package com.doupark.backend.controller;

import com.doupark.backend.dto.LoginRequest;
import com.doupark.backend.entity.User;
import com.doupark.backend.service.AuthService;
import com.doupark.backend.util.JwtUtil;
import com.doupark.backend.dto.LoginResponseDTO;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final JwtUtil jwtUtil; 

    public AuthController(AuthService authService, JwtUtil jwtUtil) {
        this.authService = authService;
        this.jwtUtil = jwtUtil; 
    }

    @PostMapping("/register")
public String register(@RequestBody User user) {

    System.out.println("REGISTER GELDİ: " + user.getEmail()); // 🔥 EKLE

    return authService.register(user);
}

 @PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest request) {

    try {
        LoginResponseDTO response = authService.login(
                request.getEmail(),
                request.getPassword()
        );

        return ResponseEntity.ok(response);

    } catch (Exception e) {
        return ResponseEntity.status(401).body(e.getMessage());
    }
}

    @PostMapping("/refresh")
    public ResponseEntity<?> refresh(@RequestBody Map<String, String> body) {
        String refreshToken = body.get("refreshToken");
        if (refreshToken == null || refreshToken.isBlank()) {
            return ResponseEntity.status(400).body("refreshToken gerekli");
        }
        try {
            String email = jwtUtil.extractUsername(refreshToken);
            if (email == null || jwtUtil.isTokenExpired(refreshToken)) {
                return ResponseEntity.status(401).body("Refresh token geçersiz veya süresi dolmuş");
            }
            String newAccessToken = jwtUtil.generateToken(email);
            String newRefreshToken = jwtUtil.generateRefreshToken(email);
            return ResponseEntity.ok(Map.of(
                    "token", newAccessToken,
                    "refreshToken", newRefreshToken
            ));
        } catch (Exception e) {
            return ResponseEntity.status(401).body("Refresh token hatalı: " + e.getMessage());
        }
    }
}