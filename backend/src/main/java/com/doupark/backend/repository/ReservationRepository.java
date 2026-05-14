package com.doupark.backend.repository;

import com.doupark.backend.entity.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, Long> {

    Optional<Reservation> findByQrToken(String qrToken);
    Optional<Reservation> findByPlateNumberAndStatus(String plateNumber, String status);
    long countByParking_IdAndStatus(Long parkingId, String status);
    List<Reservation> findByUser_Email(String email);
    List<Reservation> findByParkingId(Long parkingId);

    // Bug #3 Düzeltme: Kullanıcı ID'sine göre rezervasyon getir (silme için)
    List<Reservation> findByUser_Id(Long userId);

    // 15dk expire: belirli status ve createdAt'tan önce olanlar
    List<Reservation> findByStatusAndCreatedAtBefore(String status, LocalDateTime cutoff);
}
