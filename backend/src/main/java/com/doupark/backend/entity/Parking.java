package com.doupark.backend.entity;

import jakarta.persistence.*;

@Entity
public class Parking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String location;
    private int totalSpots;
    private int availableSpots;

    public Parking() {}

    public Parking(String location, int totalSpots, int availableSpots) {
        this.location = location;
        this.totalSpots = totalSpots;
        this.availableSpots = availableSpots;
    }

    public Long getId() {
        return id;
    }

    public String getLocation() {
        return location;
    }

    public int getTotalSpots() {
        return totalSpots;
    }

    public int getAvailableSpots() {
        return availableSpots;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public void setTotalSpots(int totalSpots) {
        this.totalSpots = totalSpots;
    }

    public void setAvailableSpots(int availableSpots) {
        this.availableSpots = availableSpots;
    }
}