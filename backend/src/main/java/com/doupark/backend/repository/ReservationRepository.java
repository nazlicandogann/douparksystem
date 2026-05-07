package com.doupark.backend.repository;

import com.doupark.backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    // Daha önce eklediğimiz metodlar
    Optional<Reservation> findByQrToken(String qrToken);
    Optional<Reservation> findByPlateNumberAndStatus(String plateNumber, String status);

    // --- YENİ EKLENECEK METODLAR ---

    // 1. Otopark ID ve Durumuna göre sayı sayma (Doluluk kontrolü için)
    // Not: "Parking_Id" yerine "ParkingId" kullanımı Spring versiyonuna göre değişebilir, 
    // hata mesajındaki tam karşılığı şudur:
    long countByParking_IdAndStatus(Long parkingId, String status);

    // 2. Kullanıcı e-posta adresine göre rezervasyonları listeleme
    List<Reservation> findByUser_Email(String email);

    // 3. Otopark ID'sine göre tüm rezervasyonları getirme
    List<Reservation> findByParkingId(Long parkingId);
}