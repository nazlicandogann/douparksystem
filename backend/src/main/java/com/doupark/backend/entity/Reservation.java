package com.doupark.backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 🔥 PARKING RELATION (KRİTİK)
    @ManyToOne
    @JoinColumn(name = "parking_id")
    private Parking parking;

    private String plateNumber;

    private LocalDateTime startTime;
    private LocalDateTime endTime;

    private String status; // ACTIVE / DONE

    // 🔥 USER RELATION
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    public Reservation() {}

    // GETTERS
    public Long getId() {
        return id;
    }

    public Parking getParking() {
        return parking;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public String getStatus() {
        return status;
    }

    public User getUser() {
        return user;
    }

    // SETTERS
    public void setParking(Parking parking) {
        this.parking = parking;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public void setStartTime(LocalDateTime startTime) {
        this.startTime = startTime;
    }

    public void setEndTime(LocalDateTime endTime) {
        this.endTime = endTime;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setUser(User user) {
        this.user = user;
    }
}