package com.doupark.backend.dto;

import com.doupark.backend.entity.Reservation;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class ReservationResponseDTO {
    private Long id;
    private Long parkingId;
    private String parkingName;
    private String parkingCode;
    private String parkingStatus;
    private Integer parkingTotalSpots;
    private Long userId;
    private String userName;
    private String userEmail;
    private String userRole;
    private String plateNumber;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private String status;
    private Integer selectedSpotIndex;
    private String qrToken;
    private boolean qrUsed;
    private LocalDateTime actualEntryTime;
    private LocalDateTime actualExitTime;
    private BigDecimal chargedAmount;

    public static ReservationResponseDTO from(Reservation r) {
        ReservationResponseDTO dto = new ReservationResponseDTO();
        dto.id = r.getId();
        if (r.getParking() != null) {
            dto.parkingId = r.getParking().getId();
            dto.parkingName = r.getParking().getParkingName();
            dto.parkingCode = r.getParking().getCode();
            dto.parkingStatus = r.getParking().getStatus();
            dto.parkingTotalSpots = r.getParking().getTotalSpots();
        }
        if (r.getUser() != null) {
            dto.userId = r.getUser().getId();
            dto.userName = r.getUser().getName();
            dto.userEmail = r.getUser().getEmail();
            dto.userRole = r.getUser().getRole();
            // password KASITLI olarak dahil edilmedi - Bug #6 düzeltmesi
        }
        dto.plateNumber = r.getPlateNumber();
        dto.startTime = r.getStartTime();
        dto.endTime = r.getEndTime();
        dto.status = r.getStatus();
        dto.selectedSpotIndex = r.getSelectedSpotIndex();
        dto.qrToken = r.getQrToken();
        dto.qrUsed = r.isQrUsed();
        dto.actualEntryTime = r.getActualEntryTime();
        dto.actualExitTime = r.getActualExitTime();
        dto.chargedAmount = r.getChargedAmount();
        return dto;
    }

    public Long getId() { return id; }
    public Long getParkingId() { return parkingId; }
    public String getParkingName() { return parkingName; }
    public String getParkingCode() { return parkingCode; }
    public String getParkingStatus() { return parkingStatus; }
    public Integer getParkingTotalSpots() { return parkingTotalSpots; }
    public Long getUserId() { return userId; }
    public String getUserName() { return userName; }
    public String getUserEmail() { return userEmail; }
    public String getUserRole() { return userRole; }
    public String getPlateNumber() { return plateNumber; }
    public LocalDateTime getStartTime() { return startTime; }
    public LocalDateTime getEndTime() { return endTime; }
    public String getStatus() { return status; }
    public Integer getSelectedSpotIndex() { return selectedSpotIndex; }
    public String getQrToken() { return qrToken; }
    public boolean isQrUsed() { return qrUsed; }
    public LocalDateTime getActualEntryTime() { return actualEntryTime; }
    public LocalDateTime getActualExitTime() { return actualExitTime; }
    public BigDecimal getChargedAmount() { return chargedAmount; }
}
