import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'create_reservation_screen.dart';
import '../services/api_service.dart';
import '../models/backend/parking_api_model.dart';
import '../services/auth_service.dart';
import '../services/user_store.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  List<ParkingApiModel> parkings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadParkings();
  }

  Future<void> loadParkings() async {
    try {
      final data = await ApiService.getAllParkings();
      if (!mounted) return;
      setState(() {
        parkings = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Color _getColor(double percent) {
    if (percent > 0.6) return Colors.green;
    if (percent > 0.3) return Colors.orange;
    return Colors.red;
  }

  int get totalAreas => parkings.length;

  int get totalCapacity {
    return parkings.fold(0, (sum, p) => sum + p.totalSpots);
  }

  int get totalAvailable {
    return parkings.fold(0, (sum, p) => sum + p.availableSpots);
  }

  int get totalOccupied {
    return parkings.fold(
      0,
      (sum, p) => sum + ((p.totalSpots - p.availableSpots).clamp(0, p.totalSpots)),
    );
  }

  Widget buildTab(String text, int index) {
    final isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFCEAEA) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: isActive ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFD32F2F) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Icon(icon, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey,
            ),
          ),
          if (buttonText != null && onPressed != null) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/car_banner.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.30),
                ),
              ],
            ),
          ),
          const Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "DouPark",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Akıllı Otopark Sistemi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF222222),
        ),
      ),
    );
  }

  Widget _buildFloorStatusCard({
    required String floorName,
    required String emptyCount,
    required String fullCount,
    required String reservedCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            floorName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatusItem(
                  'Boş',
                  emptyCount,
                  const Color(0xFF34A853),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatusItem(
                  'Dolu',
                  fullCount,
                  const Color(0xFFEA4335),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStatusItem(
                  'Rezerve',
                  reservedCount,
                  const Color(0xFFFBBC05),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatusItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECEC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE53935),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingSpot(String label, Color color) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniParkingGrid() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mini Park Görünümü',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anlık otopark durumunu hızlıca görüntüleyin.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF777777),
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildParkingSpot('A1', const Color(0xFF34A853)),
              _buildParkingSpot('A2', const Color(0xFFEA4335)),
              _buildParkingSpot('A3', const Color(0xFFFBBC05)),
              _buildParkingSpot('A4', const Color(0xFF34A853)),
              _buildParkingSpot('B1', const Color(0xFFEA4335)),
              _buildParkingSpot('B2', const Color(0xFF34A853)),
              _buildParkingSpot('B3', const Color(0xFFFBBC05)),
              _buildParkingSpot('B4', const Color(0xFF34A853)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildLegendItem('Boş', const Color(0xFF34A853)),
              _buildLegendItem('Dolu', const Color(0xFFEA4335)),
              _buildLegendItem('Rezerve', const Color(0xFFFBBC05)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DouPark ile kampüs içi otopark alanlarını daha kolay yönetebilir, doluluk oranını anlık takip edebilir ve hızlıca rezervasyon oluşturabilirsiniz.",
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            if (isMobile) ...[
              Row(
                children: [
                  _buildSummaryCard(
                    title: "Toplam Alan",
                    value: totalAreas.toString(),
                    icon: Icons.local_parking_outlined,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    title: "Toplam Kapasite",
                    value: totalCapacity.toString(),
                    icon: Icons.space_dashboard_outlined,
                    color: Colors.blueGrey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSummaryCard(
                    title: "Boş Yer",
                    value: totalAvailable.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    title: "Dolu Yer",
                    value: totalOccupied.toString(),
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  _buildSummaryCard(
                    title: "Toplam Alan",
                    value: totalAreas.toString(),
                    icon: Icons.local_parking_outlined,
                    color: const Color(0xFFD32F2F),
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    title: "Toplam Kapasite",
                    value: totalCapacity.toString(),
                    icon: Icons.space_dashboard_outlined,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    title: "Boş Yer",
                    value: totalAvailable.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    title: "Dolu Yer",
                    value: totalOccupied.toString(),
                    icon: Icons.cancel_outlined,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            _buildSectionTitle('Kat Bazlı Durum'),
            if (isMobile) ...[
              _buildFloorStatusCard(
                floorName: 'P1 Katı',
                emptyCount: '-',
                fullCount: '-',
                reservedCount: '-',
              ),
              const SizedBox(height: 16),
              _buildFloorStatusCard(
                floorName: 'P2 Katı',
                emptyCount: '-',
                fullCount: '-',
                reservedCount: '-',
              ),
              const SizedBox(height: 16),
              _buildFloorStatusCard(
                floorName: 'P3 Katı',
                emptyCount: '-',
                fullCount: '-',
                reservedCount: '-',
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: _buildFloorStatusCard(
                      floorName: 'P1 Katı',
                      emptyCount: '-',
                      fullCount: '-',
                      reservedCount: '-',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFloorStatusCard(
                      floorName: 'P2 Katı',
                      emptyCount: '-',
                      fullCount: '-',
                      reservedCount: '-',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildFloorStatusCard(
                      floorName: 'P3 Katı',
                      emptyCount: '-',
                      fullCount: '-',
                      reservedCount: '-',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            _buildSectionTitle('Sistem Özellikleri'),
            _buildFeatureCard(
              icon: Icons.local_parking_rounded,
              title: 'Anlık Doluluk Takibi',
              subtitle:
                  'Kat ve alan bazında boş, dolu ve rezerve park yerlerini canlı şekilde takip edebilirsiniz.',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.flash_on_rounded,
              title: 'Hızlı Rezervasyon',
              subtitle:
                  'Uygun park alanını seçerek birkaç adımda kolayca rezervasyon oluşturabilirsiniz.',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.verified_user_rounded,
              title: 'Güvenli Kullanım',
              subtitle:
                  'Kullanıcı giriş sistemiyle rezervasyonlarınızı güvenli biçimde yönetebilirsiniz.',
            ),
            const SizedBox(height: 32),
            _buildMiniParkingGrid(),
          ],
        );
      },
    );
  }

  Widget buildContent() {
    switch (selectedTab) {
      case 0:
        return _buildInfoContent();

      case 1:
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (parkings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.local_parking_outlined,
            title: "Henüz park alanı bulunamadı",
            description:
                "Sistemde görüntülenecek park alanı yok. Daha sonra tekrar kontrol edebilirsin.",
            buttonText: "Yenile",
            onPressed: loadParkings,
          );
        }

        return Column(
          children: parkings.map((p) {
            final int total = p.totalSpots > 0 ? p.totalSpots : 1;
            final int empty = p.availableSpots.clamp(0, total);
            final double percent = empty / total;
            final int percentText = (percent * 100).toInt();

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                      Expanded(
                        child: Text(
                          p.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getColor(percent).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "%$percentText boş",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _getColor(percent),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(_getColor(percent)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$empty / $total boş park yeri",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 2:
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fiyat Listesi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Park süresine göre ücret bilgilerini aşağıdan inceleyebilirsiniz.",
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 18),
        const _PriceCard(
          title: "Kısa Süreli Kullanım",
          duration: "0 - 60 Dakika",
          price: "Ücretsiz",
          highlighted: true,
        ),
        const SizedBox(height: 12),
        const _PriceCard(
          title: "Standart Kullanım",
          duration: "1 - 3 Saat",
          price: "150₺",
        ),
        const SizedBox(height: 12),
        const _PriceCard(
          title: "Orta Süreli Kullanım",
          duration: "3 - 6 Saat",
          price: "250₺",
        ),
        const SizedBox(height: 12),
        const _PriceCard(
          title: "Tam Gün Kullanım",
          duration: "Gün Boyu",
          price: "300₺",
        ),
      ],
    ),
  );

      case 3:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.calendar_month_rounded,
                  size: 46,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Hızlı rezervasyon oluştur",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Uygun park alanını seçerek birkaç adımda rezervasyon oluşturabilirsin.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F7),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0D9D9)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_parking_rounded,
                          color: Color(0xFFD32F2F),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Rezervasyon Özeti",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    _ReservationInfoRow(
                      icon: Icons.layers_outlined,
                      label: "Kat",
                      value: "-",
                    ),
                    SizedBox(height: 12),
                    _ReservationInfoRow(
                      icon: Icons.pin_drop_outlined,
                      label: "Park Alanı",
                      value: "-",
                    ),
                    SizedBox(height: 12),
                    _ReservationInfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: "Tarih",
                      value: "-",
                    ),
                    SizedBox(height: 12),
                    _ReservationInfoRow(
                      icon: Icons.access_time_outlined,
                      label: "Saat",
                      value: "-",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD32F2F),
                        side: const BorderSide(color: Color(0xFFD32F2F)),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Temizle",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!AuthService.isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          ).then((value) {
                            if (value == true) {
                              setState(() {});
                            }
                          });
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateReservationScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        "Rezervasyon Yap",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = AuthService.isLoggedIn;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "DouPark",
          style: TextStyle(
            color: Color(0xFFD32F2F),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2_outlined, color: Color(0xFFD32F2F)),
            onPressed: () {
              debugPrint("QR açıldı");
            },
          ),
          if (loggedIn) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Center(
                child: Text(
                  UserStore.fullName.isNotEmpty ? UserStore.fullName : "Kullanıcı",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                AuthService.logout();
                ApiService.logout();
                UserStore.clear();
                setState(() {});
              },
              child: const Text(
                "Çıkış",
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ).then((value) {
                  if (value == true) setState(() {});
                });
              },
              child: const Text(
                "Giriş",
                style: TextStyle(color: Color(0xFF6F57C8)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                "Kayıt Ol",
                style: TextStyle(color: Color(0xFFD32F2F)),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildBanner(),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFFF7F3F6),
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 12,
                      children: [
                        buildTab("Bilgi", 0),
                        buildTab("Uygunluk", 1),
                        buildTab("Fiyat Listesi", 2),
                        buildTab("Rezervasyon", 3),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F3F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: buildContent(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final String value;

  const _PriceRow({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD32F2F),
          ),
        ),
      ],
    );
  }
}

class _ReservationInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReservationInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFFD32F2F)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
class _PriceCard extends StatelessWidget {
  final String title;
  final String duration;
  final String price;
  final bool highlighted;

  const _PriceCard({
    required this.title,
    required this.duration,
    required this.price,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFDECEC) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? const Color(0xFFD32F2F) : const Color(0xFFE9E3E6),
          width: highlighted ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFD32F2F).withOpacity(0.10)
                  : const Color(0xFFF7F3F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: highlighted ? const Color(0xFFD32F2F) : Colors.grey,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: highlighted
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFFF7F3F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              price,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: highlighted ? Colors.white : const Color(0xFFD32F2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}