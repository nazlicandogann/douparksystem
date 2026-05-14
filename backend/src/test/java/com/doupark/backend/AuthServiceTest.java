package com.doupark.backend;

import com.doupark.backend.entity.User;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.service.AuthService;
import com.doupark.backend.util.JwtUtil;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private JwtUtil jwtUtil;

    @Mock
    private BCryptPasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthService authService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setEmail("test@test.com");
        testUser.setPassword("hashedPassword");
        testUser.setRole("USER");
    }

    // ── REGISTER TESTLERİ ────────────────────────────────────────────────────

    @Test
    void register_yeniKullanici_basarili() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.empty());
        when(passwordEncoder.encode(any())).thenReturn("hashedPassword");

        String result = authService.register(testUser);

        assertEquals("User registered successfully", result);
        verify(userRepository, times(1)).save(any(User.class));
    }

    @Test
    void register_mevcutEmail_hataFirlatir() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.of(testUser));

        assertThrows(ResponseStatusException.class,
                () -> authService.register(testUser));

        verify(userRepository, never()).save(any());
    }

    @Test
    void register_rolOtomatikUser_atanir() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.empty());
        when(passwordEncoder.encode(any())).thenReturn("hashedPassword");

        testUser.setRole(null);
        authService.register(testUser);

        assertEquals("USER", testUser.getRole());
    }

    // ── LOGIN TESTLERİ ───────────────────────────────────────────────────────

    @Test
    void login_dogruKimlik_tokenDoner() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(any(), any())).thenReturn(true);
        when(jwtUtil.generateToken(any())).thenReturn("access-token");
        when(jwtUtil.generateRefreshToken(any())).thenReturn("refresh-token");

        var result = authService.login("test@test.com", "test123");

        assertNotNull(result);
        assertEquals("access-token", result.getToken());
        assertEquals("test@test.com", result.getEmail());
    }

    @Test
    void login_yanlisParola_hataFirlatir() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.of(testUser));
        when(passwordEncoder.matches(any(), any())).thenReturn(false);

        assertThrows(ResponseStatusException.class,
                () -> authService.login("test@test.com", "yanlis"));
    }

    @Test
    void login_olmayankKullanici_hataFirlatir() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.empty());

        assertThrows(ResponseStatusException.class,
                () -> authService.login("yok@test.com", "test123"));
    }
}