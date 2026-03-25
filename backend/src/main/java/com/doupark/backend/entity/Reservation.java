package com.doupark.backend.entity;

import jakarta.persistence.*;

@Entity
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userEmail; // 🔥 JWT’den gelecek
    private Long parkingId;
    private String plateNumber;

    public Reservation() {}

    public Long getId() {
        return id;
    }

    public String getUserEmail() {
        return userEmail;
    }

    public Long getParkingId() {
        return parkingId;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }

    public void setParkingId(Long parkingId) {
        this.parkingId = parkingId;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }
}