package com.doupark.backend.service;

import com.doupark.backend.repository.ReservationRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
public class ScheduledTasks {

    private final ReservationRepository reservationRepository;

    public ScheduledTasks(ReservationRepository reservationRepository) {
        this.reservationRepository = reservationRepository;
    }

    // cron = "saniye dakika saat gün ay haftanın_günü"
    // "0 0 0 * * *" -> Her gece saat 00:00:00'da çalışır
    @Scheduled(cron = "0 0 0 * * *")
    @Transactional
    public void resetDailyReservations() {
        try {
            // 1. Seçenek: Tüm rezervasyonları siler (Kesin sıfırlama)
            reservationRepository.deleteAll();
            
            // 2. Seçenek: Silmek yerine statüleri "EXPIRED" yapar (Raporlama için daha iyidir)
            // reservationRepository.updateStatusForAll("EXPIRED");
            
            System.out.println("Sistem Mesajı: Günlük otopark rezervasyonları başarıyla sıfırlandı.");
        } catch (Exception e) {
            System.err.println("Sıfırlama sırasında hata oluştu: " + e.getMessage());
        }
    }
}