package com.doupark.backend;

import com.doupark.backend.entity.Parking;
import com.doupark.backend.entity.Reservation;
import com.doupark.backend.entity.User;
import com.doupark.backend.repository.ParkingPricingRuleRepository;
import com.doupark.backend.repository.ParkingRepository;
import com.doupark.backend.repository.ReservationRepository;
import com.doupark.backend.repository.UserRepository;
import com.doupark.backend.service.QrService;
import com.doupark.backend.service.ReservationService;
import com.doupark.backend.service.WalletService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReservationServiceTest {

    @Mock private ReservationRepository reservationRepository;
    @Mock private ParkingRepository parkingRepository;
    @Mock private UserRepository userRepository;
    @Mock private QrService qrService;
    @Mock private WalletService walletService;
    @Mock private ParkingPricingRuleRepository pricingRuleRepository;

    @InjectMocks
    private ReservationService reservationService;

    private User testUser;
    private Parking testParking;
    private Reservation testReservation;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setEmail("test@test.com");
        testUser.setWalletBalance(new BigDecimal("100.00"));

        testParking = new Parking();
        testParking.setId(1L);
        testParking.setTotalSpots(10);

        testReservation = new Reservation();
        
        testReservation.setUser(testUser);
        testReservation.setParking(testParking);
        testReservation.setSelectedSpotIndex(1);
        testReservation.setPlateNumber("34TEST123");
        testReservation.setStatus("PENDING_ENTRY");
        testReservation.setQrToken("test-qr-token");
        testReservation.setQrUsed(false);
    }

    // ── REZERVASYON OLUŞTURMA ────────────────────────────────────────────────

    @Test
    void createReservation_gecerliVeri_basarili() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(parkingRepository.findById(1L)).thenReturn(Optional.of(testParking));
        when(reservationRepository.countByParking_IdAndStatus(any(), any())).thenReturn(0L);
        when(reservationRepository.findByParkingId(any())).thenReturn(List.of());
        when(qrService.generateQrToken()).thenReturn("test-qr-token");
        when(reservationRepository.save(any())).thenReturn(testReservation);

        Reservation result = reservationService.createReservation(testReservation, "test@test.com");

        assertNotNull(result);
        assertEquals("PENDING_ENTRY", result.getStatus());
        verify(reservationRepository, times(1)).save(any());
    }

    @Test
    void createReservation_otoparkDolu_hataFirlatir() {
        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(parkingRepository.findById(1L)).thenReturn(Optional.of(testParking));
        when(reservationRepository.countByParking_IdAndStatus(1L, "PARKED")).thenReturn(5L);
        when(reservationRepository.countByParking_IdAndStatus(1L, "PENDING_ENTRY")).thenReturn(5L);

        assertThrows(RuntimeException.class,
                () -> reservationService.createReservation(testReservation, "test@test.com"));
    }

    @Test
    void createReservation_dolmuSpot_hataFirlatir() {
        Reservation mevcutRezervasyon = new Reservation();
        mevcutRezervasyon.setSelectedSpotIndex(1);
        mevcutRezervasyon.setStatus("PENDING_ENTRY");

        when(userRepository.findByEmail("test@test.com")).thenReturn(Optional.of(testUser));
        when(parkingRepository.findById(1L)).thenReturn(Optional.of(testParking));
        when(reservationRepository.countByParking_IdAndStatus(any(), any())).thenReturn(0L);
        when(reservationRepository.findByParkingId(any())).thenReturn(List.of(mevcutRezervasyon));

        assertThrows(RuntimeException.class,
                () -> reservationService.createReservation(testReservation, "test@test.com"));
    }

    // ── QR GİRİŞ ────────────────────────────────────────────────────────────

    @Test
    void processQrEntry_gecerliToken_basarili() {
        when(reservationRepository.findByQrToken("test-qr-token"))
                .thenReturn(Optional.of(testReservation));
        when(reservationRepository.save(any())).thenReturn(testReservation);

        Reservation result = reservationService.processQrEntry("test-qr-token");

        assertEquals("PARKED", result.getStatus());
        assertTrue(result.isQrUsed());
        assertNotNull(result.getActualEntryTime());
    }

    @Test
    void processQrEntry_kullanilamiQr_hataFirlatir() {
        testReservation.setQrUsed(true);
        when(reservationRepository.findByQrToken("test-qr-token"))
                .thenReturn(Optional.of(testReservation));

        assertThrows(RuntimeException.class,
                () -> reservationService.processQrEntry("test-qr-token"));
    }

    @Test
    void processQrEntry_gecersizToken_hataFirlatir() {
        when(reservationRepository.findByQrToken("yanlis-token"))
                .thenReturn(Optional.empty());

        assertThrows(RuntimeException.class,
                () -> reservationService.processQrEntry("yanlis-token"));
    }

    // ── REZERVASYON İPTALİ ───────────────────────────────────────────────────

    @Test
    void cancelReservation_bekleyenRezervasyon_iptalEdilir() {
        when(reservationRepository.findById(1L)).thenReturn(Optional.of(testReservation));

        reservationService.cancelReservation(1L);

        assertEquals("CANCELLED", testReservation.getStatus());
        verify(reservationRepository, times(1)).save(any());
    }

    @Test
    void cancelReservation_arabaicindeRezervasyon_hataFirlatir() {
        testReservation.setStatus("PARKED");
        when(reservationRepository.findById(1L)).thenReturn(Optional.of(testReservation));

        assertThrows(RuntimeException.class,
                () -> reservationService.cancelReservation(1L));
    }

    // ── KULLANICI REZERVASYONLARI ─────────────────────────────────────────────

    @Test
    void getUserReservations_dogruKullanici_listeDoner() {
        when(reservationRepository.findByUser_Email("test@test.com"))
                .thenReturn(List.of(testReservation));

        List<Reservation> result = reservationService.getUserReservations("test@test.com");

        assertEquals(1, result.size());
        assertEquals("34TEST123", result.get(0).getPlateNumber());
    }
}