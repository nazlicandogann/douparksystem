package com.doupark.backend.dto;

public class ReservationDTO {
    private Long parkingId;
    private String plateNumber;
    private String startTime;
    private String endTime;
    private Integer selectedSpotIndex; // Eksik olan alan buydu

    // Getter ve Setter metotlarını ekle (Lombok kullanıyorsan @Data ekle)
    public Long getParkingId() { return parkingId; }
    public void setParkingId(Long parkingId) { this.parkingId = parkingId; }

    public String getPlateNumber() { return plateNumber; }
    public void setPlateNumber(String plateNumber) { this.plateNumber = plateNumber; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public Integer getSelectedSpotIndex() { return selectedSpotIndex; }
    public void setSelectedSpotIndex(Integer selectedSpotIndex) { this.selectedSpotIndex = selectedSpotIndex; }
}