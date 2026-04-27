package com.doupark.backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "parking")
public class Parking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // DB'de hem "parkingName" hem "parking_name" kolonu var.
    // Tek bir alana map ediyoruz: "parking_name" (snake_case) kullanılacak.
    @Column(name = "parking_name")
    private String parkingName;

    private String code;
    private String status;

    // DB kolonunun adı "total_spots" (snake_case) — JPA bunu otomatik eşleştirmez,
    // bu yüzden @Column ile açıkça belirtiyoruz.
    @Column(name = "total_spots")
    private int totalSpots;

    public Parking() {}

    public Parking(String parkingName, String code, String status, int totalSpots) {
        this.parkingName = parkingName;
        this.code = code;
        this.status = status;
        this.totalSpots = totalSpots;
    }

    // GETTER & SETTER
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getParkingName() { return parkingName; }
    public void setParkingName(String parkingName) { this.parkingName = parkingName; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getTotalSpots() { return totalSpots; }
    public void setTotalSpots(int totalSpots) { this.totalSpots = totalSpots; }
}