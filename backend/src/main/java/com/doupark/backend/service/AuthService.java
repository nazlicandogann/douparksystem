package com.doupark.backend.service;

import com.doupark.backend.dto.LoginResponseDTO;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.util.JwtUtil;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JwtUtil jwtUtil;
    private final BCryptPasswordEncoder passwordEncoder;

    public AuthService(UserRepository userRepository,
                       JwtUtil jwtUtil,
                       BCryptPasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.jwtUtil = jwtUtil;
        this.passwordEncoder = passwordEncoder;
    }

    // ---------------------------
    // REGISTER
    // ---------------------------
    public String register(User user) {

        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Email already exists"
            );
        }

        // 🔐 Şifreyi hashle
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // 👑 Default role
        user.setRole("USER");

        userRepository.save(user);

        return "User registered successfully";
    }

    // ---------------------------
    // LOGIN
    // ---------------------------
    public LoginResponseDTO login(String email, String password) {

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.UNAUTHORIZED,
                        "User not found"
                ));

        // 🔐 HASH KONTROL
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new ResponseStatusException(
                    HttpStatus.UNAUTHORIZED,
                    "Wrong password"
            );
        }

        // 🔥 TOKEN OLUŞTUR
        String token = jwtUtil.generateToken(user.getEmail());

        return new LoginResponseDTO(
                token,
                user.getEmail(),
                user.getName()
        );
    }
}