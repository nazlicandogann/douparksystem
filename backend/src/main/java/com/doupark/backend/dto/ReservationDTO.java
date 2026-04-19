package com.doupark.backend.dto;

public class ReservationDTO {

    private Long parkingId;
    private String plateNumber;
    private String startTime;   // ISO-8601 string olarak gelir: "2024-01-01T10:00:00"
    private String endTime;

    public Long getParkingId() { return parkingId; }
    public String getPlateNumber() { return plateNumber; }
    public String getStartTime() { return startTime; }
    public String getEndTime() { return endTime; }

    public void setParkingId(Long parkingId) { this.parkingId = parkingId; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }
    public void setStartTime(String startTime) { this.startTime = startTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }
}
