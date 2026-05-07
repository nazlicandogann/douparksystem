package com.doupark.backend.controller;

import com.doupark.backend.entity.WalletTransaction;
import com.doupark.backend.service.WalletService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Cüzdan Endpoint'leri
 * GET  /api/wallet/balance        → Güncel bakiye
 * POST /api/wallet/deposit        → Para yükleme
 * GET  /api/wallet/history        → İşlem geçmişi
 */
@RestController
@RequestMapping("/api/wallet")
@CrossOrigin(origins = "*")
public class WalletController {

    private final WalletService walletService;

    public WalletController(WalletService walletService) {
        this.walletService = walletService;
    }

    /**
     * GET /api/wallet/balance
     * Kullanıcının güncel cüzdan bakiyesini döner.
     */
    @GetMapping("/balance")
    public ResponseEntity<Map<String, Object>> getBalance(Authentication auth) {
        BigDecimal balance = walletService.getBalance(auth.getName());
        return ResponseEntity.ok(Map.of(
                "email",   auth.getName(),
                "balance", balance
        ));
    }

    /**
     * POST /api/wallet/deposit
     * Body: { "amount": 50.00 }
     * Cüzdana para yükler. Minimum 10 TL.
     */
    @PostMapping("/deposit")
    public ResponseEntity<?> deposit(@RequestBody Map<String, Object> body,
                                     Authentication auth) {
        try {
            BigDecimal amount = new BigDecimal(body.get("amount").toString());
            BigDecimal newBalance = walletService.deposit(auth.getName(), amount);
            return ResponseEntity.ok(Map.of(
                    "message",    "Para yükleme başarılı",
                    "deposited",  amount,
                    "newBalance", newBalance
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /**
     * GET /api/wallet/history
     * Kullanıcının tüm cüzdan işlemlerini listeler (en yeniden eskiye).
     */
    @GetMapping("/history")
    public ResponseEntity<List<WalletTransaction>> getHistory(Authentication auth) {
        return ResponseEntity.ok(walletService.getHistory(auth.getName()));
    }
}
