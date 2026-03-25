import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/reservation_store.dart';
import '../services/parking_store.dart';
import '../models/reservation_model.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> get activeReservations =>
      ReservationStore.reservations.where((r) => r.status == 'Aktif').toList();

  List<Reservation> get cancelledReservations => ReservationStore.reservations
      .where((r) => r.status == 'İptal Edildi')
      .toList();

  List<Reservation> get pastReservations =>
      ReservationStore.reservations.where((r) => r.status == 'Geçmiş').toList();

  void cancelReservation(Reservation reservation) {
    setState(() {
      reservation.status = 'İptal Edildi';
      ParkingStore.freeSpot(reservation.parkingSpotId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reservation.spotCode} rezervasyonu iptal edildi'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Aktif':
        return Colors.green;
      case 'İptal Edildi':
        return Colors.red;
      case 'Geçmiş':
        return Colors.grey;
      default:
        return AppColors.primary;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Aktif':
        return Icons.check_circle;
      case 'İptal Edildi':
        return Icons.cancel;
      case 'Geçmiş':
        return Icons.history;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyReservation = ReservationStore.reservations.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: hasAnyReservation
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTopSummary(),
                const SizedBox(height: 20),

                if (activeReservations.isNotEmpty) ...[
                  _buildSectionTitle('Aktif Rezervasyonlar'),
                  const SizedBox(height: 10),
                  ...activeReservations.map(
                    (reservation) => _buildReservationCard(
                      reservation,
                      showCancelButton: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (pastReservations.isNotEmpty) ...[
                  _buildSectionTitle('Geçmiş Rezervasyonlar'),
                  const SizedBox(height: 10),
                  ...pastReservations.map(
                    (reservation) => _buildReservationCard(reservation),
                  ),
                  const SizedBox(height: 20),
                ],

                if (cancelledReservations.isNotEmpty) ...[
                  _buildSectionTitle('İptal Edilenler'),
                  const SizedBox(height: 10),
                  ...cancelledReservations.map(
                    (reservation) => _buildReservationCard(reservation),
                  ),
                ],
              ],
            )
          : _buildEmptyState(),
    );
  }

  Widget _buildTopSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              title: 'Aktif',
              value: activeReservations.length.toString(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryItem(
              title: 'Geçmiş',
              value: pastReservations.length.toString(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSummaryItem(
              title: 'İptal',
              value: cancelledReservations.length.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReservationCard(
    Reservation reservation, {
    bool showCancelButton = false,
  }) {
    final statusColor = getStatusColor(reservation.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_parking_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.spotCode,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reservation.floor,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      getStatusIcon(reservation.status),
                      size: 15,
                      color: statusColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      reservation.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.calendar_today_rounded, 'Tarih', reservation.date),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.location_on_outlined, 'Kat / Alan', reservation.floor),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.directions_car_outlined, 'Plaka', reservation.plate),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.confirmation_number_outlined,
            'Park Kodu',
            reservation.spotCode,
          ),
          if (showCancelButton) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => cancelReservation(reservation),
                icon: const Icon(Icons.close_rounded),
                label: const Text('Rezervasyonu İptal Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 70,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Henüz rezervasyon yok',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rezervasyon oluşturduğunda burada listelenecek.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}