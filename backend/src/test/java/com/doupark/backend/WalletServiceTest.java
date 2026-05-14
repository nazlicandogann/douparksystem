package com.doupark.backend;

import com.doupark.backend.entity.User;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.repository.WalletTransactionRepository;
import com.doupark.backend.service.WalletService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class WalletServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private WalletTransactionRepository transactionRepository;

    @InjectMocks
    private WalletService walletService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setEmail("test@test.com");
        testUser.setWalletBalance(new BigDecimal("100.00"));
    }

    // ── DEPOSIT TESTLERİ ─────────────────────────────────────────────────────

    @Test
    void deposit_gecerliTutar_bakiyeArtar() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any())).thenReturn(testUser);

        BigDecimal result = walletService.deposit("test@test.com", new BigDecimal("50.00"));

        assertEquals(new BigDecimal("150.00"), result);
        verify(transactionRepository, times(1)).save(any());
    }

    @Test
    void deposit_minimumAltindaTutar_hataFirlatir() {
        assertThrows(RuntimeException.class,
                () -> walletService.deposit("test@test.com", new BigDecimal("5.00")));

        verify(userRepository, never()).save(any());
    }

    @Test
    void deposit_nullTutar_hataFirlatir() {
        assertThrows(RuntimeException.class,
                () -> walletService.deposit("test@test.com", null));
    }

    @Test
    void deposit_tam10TL_basarili() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any())).thenReturn(testUser);

        BigDecimal result = walletService.deposit("test@test.com", new BigDecimal("10.00"));

        assertEquals(new BigDecimal("110.00"), result);
    }

    // ── CHARGE TESTLERİ ──────────────────────────────────────────────────────

    @Test
    void charge_yeterliBakiye_ucretKesilir() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(userRepository.save(any())).thenReturn(testUser);

        BigDecimal result = walletService.charge("test@test.com", new BigDecimal("50.00"), 1L);

        assertEquals(new BigDecimal("50.00"), result);
        verify(transactionRepository, times(1)).save(any());
    }

    @Test
    void charge_yetersizBakiye_hataFirlatir() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));

        RuntimeException ex = assertThrows(RuntimeException.class,
                () -> walletService.charge("test@test.com", new BigDecimal("200.00"), 1L));

        assertTrue(ex.getMessage().contains("Yetersiz bakiye"));
    }

    @Test
    void charge_sifirTutar_islemYapilmaz() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));

        walletService.charge("test@test.com", BigDecimal.ZERO, 1L);

        verify(transactionRepository, never()).save(any());
    }

    // ── BALANCE TESTİ ────────────────────────────────────────────────────────

    @Test
    void getBalance_dogru_bakiyeDoner() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));

        BigDecimal balance = walletService.getBalance("test@test.com");

        assertEquals(new BigDecimal("100.00"), balance);
    }

    @Test
    void getBalance_olmayankKullanici_hataFirlatir() {
        when(userRepository.findByEmail(any())).thenReturn(Optional.empty());

        assertThrows(RuntimeException.class,
                () -> walletService.getBalance("yok@test.com"));
    }
}