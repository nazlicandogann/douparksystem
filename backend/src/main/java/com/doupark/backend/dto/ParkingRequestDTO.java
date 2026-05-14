package com.doupark.backend.dto;

public class ParkingRequestDTO {
    private String name;        // Frontend'den "name" geliyor
    private String parkingName; // Alternatif alan adı
    private String code;
    private String status;
    private int totalSpots;
    private double pricePerHour;

    // name veya parkingName'den birini al - Bug #5 düzeltmesi
    public String getResolvedName() {
        if (parkingName != null && !parkingName.isEmpty()) return parkingName;
        if (name != null && !name.isEmpty()) return name;
        return "Bilinmeyen Otopark";
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getParkingName() { return parkingName; }
    public void setParkingName(String parkingName) { this.parkingName = parkingName; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getTotalSpots() { return totalSpots; }
    public void setTotalSpots(int totalSpots) { this.totalSpots = totalSpots; }
    public double getPricePerHour() { return pricePerHour; }
    public void setPricePerHour(double pricePerHour) { this.pricePerHour = pricePerHour; }
}
