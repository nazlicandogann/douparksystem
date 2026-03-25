package com.doupark.backend.dto;

public class ReservationDTO {

    private Long userId;   
    private Long parkingId;
    private String plateNumber;

    public Long getUserId() {
        return userId;
    }

    public Long getParkingId() {
        return parkingId;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public void setParkingId(Long parkingId) {
        this.parkingId = parkingId;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }
}