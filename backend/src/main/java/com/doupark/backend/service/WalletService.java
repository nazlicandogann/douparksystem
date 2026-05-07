package com.doupark.backend.service;

import com.doupark.backend.entity.User;
import com.doupark.backend.entity.WalletTransaction;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.repository.WalletTransactionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Cüzdan servisi.
 * Para yükleme ve otopark ödemesi işlemlerini yönetir.
 */
@Service
public class WalletService {

    private final UserRepository userRepository;
    private final WalletTransactionRepository transactionRepository;

    public WalletService(UserRepository userRepository,
                         WalletTransactionRepository transactionRepository) {
        this.userRepository = userRepository;
        this.transactionRepository = transactionRepository;
    }

    /**
     * Kullanıcı cüzdanına para yükler.
     * Minimum yükleme: 10 TL
     */
    @Transactional
    public BigDecimal deposit(String email, BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.TEN) < 0) {
            throw new RuntimeException("Minimum yükleme tutarı 10 TL'dir.");
        }

        User user = findUser(email);
        BigDecimal newBalance = user.getWalletBalance().add(amount);
        user.setWalletBalance(newBalance);
        userRepository.save(user);

        // İşlem kaydı
        saveTransaction(user, "DEPOSIT", amount, newBalance,
                null, amount + " TL cüzdana yüklendi");

        return newBalance;
    }

    /**
     * Otopark çıkışında kullanıcı cüzdanından ücret çeker.
     * Bakiye yetersizse RuntimeException fırlatır.
     */
    @Transactional
    public BigDecimal charge(String email, BigDecimal amount, Long reservationId) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            return getBalance(email); // sıfır ya da negatif ise işlem yapma
        }

        User user = findUser(email);

        if (user.getWalletBalance().compareTo(amount) < 0) {
            throw new RuntimeException(
                    "Yetersiz bakiye. Mevcut: " + user.getWalletBalance() + " TL, " +
                    "Gereken: " + amount + " TL");
        }

        BigDecimal newBalance = user.getWalletBalance().subtract(amount);
        user.setWalletBalance(newBalance);
        userRepository.save(user);

        saveTransaction(user, "PAYMENT", amount.negate(), newBalance,
                reservationId, "Otopark ücreti: " + amount + " TL");

        return newBalance;
    }

    /**
     * Güncel bakiyeyi döner.
     */
    public BigDecimal getBalance(String email) {
        return findUser(email).getWalletBalance();
    }

    /**
     * Kullanıcının işlem geçmişini döner.
     */
    public List<WalletTransaction> getHistory(String email) {
        return transactionRepository.findByUser_EmailOrderByCreatedAtDesc(email);
    }

    // ── Yardımcı ─────────────────────────────────────────────────────────────

    private User findUser(String email) {
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Kullanıcı bulunamadı: " + email));
    }

    private void saveTransaction(User user, String type, BigDecimal amount,
                                 BigDecimal balanceAfter, Long reservationId, String description) {
        WalletTransaction tx = new WalletTransaction();
        tx.setUser(user);
        tx.setType(type);
        tx.setAmount(amount);
        tx.setBalanceAfter(balanceAfter);
        tx.setCreatedAt(LocalDateTime.now());
        tx.setReservationId(reservationId);
        tx.setDescription(description);
        transactionRepository.save(tx);
    }
}
