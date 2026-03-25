package com.doupark.backend.controller;

import com.doupark.backend.dto.LoginResponseDTO;
import com.doupark.backend.entity.User;
import com.doupark.backend.service.AuthService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // REGISTER
    @PostMapping("/register")
    public String register(@RequestBody User user) {
        return authService.register(user);
    }

  
@PostMapping("/login2")
public LoginResponseDTO login(@RequestBody User user) {
    return authService.login(user.getEmail(), user.getPassword());
}
}