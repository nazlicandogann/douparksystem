package com.doupark.backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservation")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "parking_id")
    private Parking parking;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    private String plateNumber;

    private LocalDateTime startTime;
    private LocalDateTime endTime;

    // PENDING_ENTRY → PARKED → DONE / CANCELLED
    private String status;

    private Integer selectedSpotIndex;

    // 🔑 QR kodu değeri (UUID) — tek kullanımlık
    @Column(unique = true)
    private String qrToken;

    // QR kullanıldı mı? (giriş yapıldığında true olur)
    private boolean qrUsed = false;

    // 🚗 Fiili giriş zamanı (QR okutulduğu an)
    private LocalDateTime actualEntryTime;

    // 🚗 Fiili çıkış zamanı (plaka kamera okuyunca)
    private LocalDateTime actualExitTime;

    // 💰 Tahsil edilen ücret (TL)
    @Column(precision = 10, scale = 2)
    private BigDecimal chargedAmount;

    public Reservation() {}

    // GETTERS
    public Long getId()                     { return id; }
    public Parking getParking()             { return parking; }
    public User getUser()                   { return user; }
    public String getPlateNumber()          { return plateNumber; }
    public LocalDateTime getStartTime()     { return startTime; }
    public LocalDateTime getEndTime()       { return endTime; }
    public String getStatus()               { return status; }
    public Integer getSelectedSpotIndex()   { return selectedSpotIndex; }
    public String getQrToken()              { return qrToken; }
    public boolean isQrUsed()              { return qrUsed; }
    public LocalDateTime getActualEntryTime() { return actualEntryTime; }
    public LocalDateTime getActualExitTime()  { return actualExitTime; }
    public BigDecimal getChargedAmount()    { return chargedAmount; }

    // SETTERS
    public void setParking(Parking parking)             { this.parking = parking; }
    public void setUser(User user)                      { this.user = user; }
    public void setPlateNumber(String plateNumber)      { this.plateNumber = plateNumber; }
    public void setStartTime(LocalDateTime startTime)   { this.startTime = startTime; }
    public void setEndTime(LocalDateTime endTime)       { this.endTime = endTime; }
    public void setStatus(String status)                { this.status = status; }
    public void setSelectedSpotIndex(Integer selectedSpotIndex) { this.selectedSpotIndex = selectedSpotIndex; }
    public void setQrToken(String qrToken)              { this.qrToken = qrToken; }
    public void setQrUsed(boolean qrUsed)               { this.qrUsed = qrUsed; }
    public void setActualEntryTime(LocalDateTime actualEntryTime) { this.actualEntryTime = actualEntryTime; }
    public void setActualExitTime(LocalDateTime actualExitTime)   { this.actualExitTime = actualExitTime; }
    public void setChargedAmount(BigDecimal chargedAmount) { this.chargedAmount = chargedAmount; }
}
