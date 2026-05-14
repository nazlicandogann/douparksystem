package com.doupark.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(unique = true)
    private String email;

    private String password;

    private String role;

    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal walletBalance = BigDecimal.ZERO;

    // Yaptırım sistemi
    @Column(name = "no_show_count", nullable = false)
    private Integer noShowCount = 0;

    @Column(name = "reservation_banned", nullable = false)
    private Boolean reservationBanned = false;

    public User() {}

    public User(String name, String email, String password, String role) {
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.walletBalance = BigDecimal.ZERO;
        this.noShowCount = 0;
        this.reservationBanned = false;
    }

    public Long getId()                      { return id; }
    public String getName()                  { return name; }
    public String getEmail()                 { return email; }
    public String getPassword()              { return password; }
    public String getRole()                  { return role; }
    public BigDecimal getWalletBalance()     { return walletBalance; }
    public Integer getNoShowCount()          { return noShowCount != null ? noShowCount : 0; }
    public Boolean getReservationBanned()    { return reservationBanned != null ? reservationBanned : false; }

    public void setId(Long id)               { this.id = id; }
    public void setName(String name)         { this.name = name; }
    public void setEmail(String email)       { this.email = email; }
    public void setPassword(String password) { this.password = password; }
    public void setRole(String role)         { this.role = role; }
    public void setWalletBalance(BigDecimal walletBalance) { this.walletBalance = walletBalance; }
    public void setNoShowCount(Integer noShowCount)        { this.noShowCount = noShowCount; }
    public void setReservationBanned(Boolean banned)       { this.reservationBanned = banned; }
}
