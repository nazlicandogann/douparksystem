package com.doupark.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

/**
 * Otopark fiyatlandırma kuralı.
 * Her otopark için saatlik ücret ve minimum süre tutulur.
 */
@Entity
@Table(name = "parking_pricing_rule")
public class ParkingPricingRule {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne
    @JoinColumn(name = "parking_id", nullable = false)
    private Parking parking;

    // Saatlik ücret (TL)
    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal pricePerHour;

    // Minimum ücretlendirme süresi (dakika) — ör: 30 dakikadan az kalsın 30dk sayılır
    @Column(nullable = false)
    private int minimumMinutes = 30;

    // İlk N dakika ücretsiz
    @Column(nullable = false)
    private int freeMinutes = 0;

    public ParkingPricingRule() {}

    // GETTERS
    public Long getId()                 { return id; }
    public Parking getParking()         { return parking; }
    public BigDecimal getPricePerHour() { return pricePerHour; }
    public int getMinimumMinutes()      { return minimumMinutes; }
    public int getFreeMinutes()         { return freeMinutes; }

    // SETTERS
    public void setParking(Parking parking)             { this.parking = parking; }
    public void setPricePerHour(BigDecimal pricePerHour){ this.pricePerHour = pricePerHour; }
    public void setMinimumMinutes(int minimumMinutes)   { this.minimumMinutes = minimumMinutes; }
    public void setFreeMinutes(int freeMinutes)         { this.freeMinutes = freeMinutes; }
}
