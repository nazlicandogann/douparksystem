package com.doupark.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Kullanıcı cüzdan işlem geçmişi.
 * Her para yükleme ve otopark ödemesi buraya kaydedilir.
 */
@Entity
@Table(name = "wallet_transaction")
public class WalletTransaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // DEPOSIT (para yükleme) | PAYMENT (otopark ödemesi)
    @Column(nullable = false)
    private String type;

    // Pozitif = yükleme, Negatif = ödeme
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal amount;

    // İşlem sonrası bakiye
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal balanceAfter;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    // Ödeme ise ilgili rezervasyon ID
    private Long reservationId;

    // Kullanıcıya gösterilecek açıklama
    private String description;

    public WalletTransaction() {}

    // GETTERS
    public Long getId()                     { return id; }
    public User getUser()                   { return user; }
    public String getType()                 { return type; }
    public BigDecimal getAmount()           { return amount; }
    public BigDecimal getBalanceAfter()     { return balanceAfter; }
    public LocalDateTime getCreatedAt()     { return createdAt; }
    public Long getReservationId()          { return reservationId; }
    public String getDescription()          { return description; }

    // SETTERS
    public void setUser(User user)                          { this.user = user; }
    public void setType(String type)                        { this.type = type; }
    public void setAmount(BigDecimal amount)                { this.amount = amount; }
    public void setBalanceAfter(BigDecimal balanceAfter)    { this.balanceAfter = balanceAfter; }
    public void setCreatedAt(LocalDateTime createdAt)       { this.createdAt = createdAt; }
    public void setReservationId(Long reservationId)        { this.reservationId = reservationId; }
    public void setDescription(String description)          { this.description = description; }
}
