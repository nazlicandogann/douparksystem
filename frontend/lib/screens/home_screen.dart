import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/parking_store.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onCreateReservationTap;
  final VoidCallback? onReservationsTap;

  const HomeScreen({
    super.key,
    this.onCreateReservationTap,
    this.onReservationsTap,
  });

  @override
  Widget build(BuildContext context) {
    final aAvailable = ParkingStore.getAvailableCount('A Blok');
    final aOccupied = ParkingStore.getOccupiedCount('A Blok');
    final aReserved = ParkingStore.getReservedCount('A Blok');

    final bAvailable = ParkingStore.getAvailableCount('B Blok');
    final bOccupied = ParkingStore.getOccupiedCount('B Blok');
    final bReserved = ParkingStore.getReservedCount('B Blok');

    final cAvailable = ParkingStore.getAvailableCount('C Blok');
    final cOccupied = ParkingStore.getOccupiedCount('C Blok');
    final cReserved = ParkingStore.getReservedCount('C Blok');

    final dAvailable = ParkingStore.getAvailableCount('D Blok');
    final dOccupied = ParkingStore.getOccupiedCount('D Blok');
    final dReserved = ParkingStore.getReservedCount('D Blok');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'DouPark',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            const Text(
              'Otopark Durumu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildParkingCard(
              title: 'A Blok',
              available: aAvailable,
              occupied: aOccupied,
              reserved: aReserved,
            ),
            const SizedBox(height: 12),
            _buildParkingCard(
              title: 'B Blok',
              available: bAvailable,
              occupied: bOccupied,
              reserved: bReserved,
            ),
            const SizedBox(height: 12),
            _buildParkingCard(
              title: 'C Blok',
              available: cAvailable,
              occupied: cOccupied,
              reserved: cReserved,
            ),
            const SizedBox(height: 12),
            _buildParkingCard(
              title: 'D Blok',
              available: dAvailable,
              occupied: dOccupied,
              reserved: dReserved,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateReservationTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Rezervasyon Oluştur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReservationsTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text(
                  'Rezervasyonlarım',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildLegendCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DouPark\'a Hoş Geldin',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Otopark doluluk durumunu görüntüleyebilir ve hızlıca rezervasyon oluşturabilirsin.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingCard({
    required String title,
    required int available,
    required int occupied,
    required int reserved,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatusBox(
                  label: 'Boş',
                  value: available.toString(),
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusBox(
                  label: 'Dolu',
                  value: occupied.toString(),
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusBox(
                  label: 'Rezerve',
                  value: reserved.toString(),
                  color: Colors.yellow.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Renk Açıklaması',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          _LegendItem(color: Colors.green, text: 'Boş park yeri'),
          SizedBox(height: 8),
          _LegendItem(color: Colors.red, text: 'Dolu park yeri'),
          SizedBox(height: 8),
          _LegendItem(color: Colors.orange, text: 'Rezerve park yeri'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}