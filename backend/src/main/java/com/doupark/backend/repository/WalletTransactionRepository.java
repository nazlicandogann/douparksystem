package com.doupark.backend.repository;

import com.doupark.backend.entity.WalletTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface WalletTransactionRepository extends JpaRepository<WalletTransaction, Long> {
    List<WalletTransaction> findByUser_EmailOrderByCreatedAtDesc(String email);
    List<WalletTransaction> findByUser_IdOrderByCreatedAtDesc(Long userId);
}
