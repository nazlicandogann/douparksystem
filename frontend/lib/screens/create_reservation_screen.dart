import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/parking_spot_model.dart';
import '../services/parking_store.dart';
import '../services/api_service.dart';
import 'reservations_screen.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen>
    with TickerProviderStateMixin {
  String selectedFloor = 'A Blok';
  ParkingSpot? selectedSpot;
  bool isLoading = false;

  final List<String> floors = ['A Blok', 'B Blok', 'Misafir'];

  List<ParkingSpot> get filteredSpots {
    return ParkingStore.spots
        .where((spot) => spot.parkingName == selectedFloor)
        .toList();
  }

  int get totalCount => filteredSpots.length;

  int get emptyCount => filteredSpots
      .where((spot) => !spot.isOccupied && !spot.isReserved)
      .length;

  int get occupiedCount =>
      filteredSpots.where((spot) => spot.isOccupied).length;

  int get reservedCount =>
      filteredSpots.where((spot) => spot.isReserved).length;

  Future<void> createReservation() async {
    if (selectedSpot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce bir park yeri seçin."),
        ),
      );
      return;
    }

    if (selectedSpot!.isOccupied || selectedSpot!.isReserved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bu park yeri uygun değil."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();
    final end = now.add(const Duration(hours: 1));

    final startTime = now.toIso8601String();
    final endTime = end.toIso8601String();

    final result = await ApiService.createReservation(
      parkingSpotId: selectedSpot!.id,
      startTime: startTime,
      endTime: endTime,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Rezervasyon oluşturuldu'),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReservationsScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Rezervasyon oluşturulamadı'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color getSpotColor(ParkingSpot spot) {
    if (spot.isOccupied) return Colors.red;
    if (spot.isReserved) return Colors.yellow.shade700;
    return Colors.green;
  }

  String getSpotStatus(ParkingSpot spot) {
    if (spot.isOccupied) return "Dolu";
    if (spot.isReserved) return "Rezerve";
    return "Boş";
  }

  Widget buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
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
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.red, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpotCard(ParkingSpot spot) {
    final bool isSelected = selectedSpot?.id == spot.id;
    final bool isAvailable = !spot.isOccupied && !spot.isReserved;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                selectedSpot = spot;
              });
            }
          : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: isSelected ? 1.05 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: getSpotColor(spot).withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.red : getSpotColor(spot),
              width: isSelected ? 2.2 : 1.4,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.18),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_parking_rounded,
                  color: getSpotColor(spot),
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  'P${spot.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  getSpotStatus(spot),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getSpotColor(spot),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 40,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text(
            "Bu alanda gösterilecek park yeri bulunamadı.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Önce backend tarafında bu lokasyon için parking verisi eklemelisin.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Rezervasyon Oluştur"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  buildSummaryCard(
                    "Toplam",
                    totalCount.toString(),
                    Icons.dashboard_outlined,
                  ),
                  const SizedBox(width: 10),
                  buildSummaryCard(
                    "Boş",
                    emptyCount.toString(),
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  buildSummaryCard(
                    "Dolu",
                    occupiedCount.toString(),
                    Icons.cancel_outlined,
                  ),
                  const SizedBox(width: 10),
                  buildSummaryCard(
                    "Rezerve",
                    reservedCount.toString(),
                    Icons.bookmark_border,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Kat / Alan Seç",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: floors.map((floor) {
                        final bool isSelected = selectedFloor == floor;
                        return ChoiceChip(
                          label: Text(floor),
                          selected: isSelected,
                          selectedColor: AppColors.red.withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.red
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.red
                                : AppColors.border,
                          ),
                          onSelected: (_) {
                            setState(() {
                              selectedFloor = floor;
                              selectedSpot = null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        buildLegendItem(Colors.green, "Boş"),
                        buildLegendItem(Colors.red, "Dolu"),
                        buildLegendItem(Colors.yellow.shade700, "Rezerve"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mini Otopark Haritası",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    filteredSpots.isEmpty
                        ? buildEmptyState()
                        : GridView.builder(
                            itemCount: filteredSpots.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemBuilder: (context, index) {
                              final spot = filteredSpots[index];
                              return buildSpotCard(spot);
                            },
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (selectedSpot != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Seçilen Park Yeri",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_parking_rounded,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'P${selectedSpot!.id} - $selectedFloor',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Durum: ${getSpotStatus(selectedSpot!)}",
                        style: TextStyle(
                          fontSize: 13,
                          color: getSpotColor(selectedSpot!),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : createReservation,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.3,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isLoading
                        ? "Rezervasyon oluşturuluyor..."
                        : "Rezervasyon Oluştur",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}