import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/backend/parking_api_model.dart';
import '../services/api_service.dart';
import 'reservations_screen.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {

  String selectedFloor = 'A Blok';
  ParkingApiModel? selectedSpot;

  List<ParkingApiModel> parkings = [];
  bool isLoading = true;

  final List<String> floors = ['A Blok', 'B Blok', 'Misafir'];

  @override
  void initState() {
    super.initState();
    loadParkings();
  }

  Future<void> loadParkings() async {
    final data = await ApiService.getAllParkings();

    setState(() {
      parkings = data;
      isLoading = false;
    });
  }

  int get totalCount => parkings.length;
  int get emptyCount => parkings.where((p) => p.availableSpots > 0).length;
  int get occupiedCount => 0;
  int get reservedCount => 0;

  Future<void> createReservation() async {
    if (selectedSpot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen park seç")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final now = DateTime.now();
    final end = now.add(const Duration(hours: 1));

    final result = await ApiService.createReservation(
      parkingId: selectedSpot!.id,
      plateNumber: "34ABC123",
      startTime: now.toIso8601String(),
      endTime: end.toIso8601String(),
    );

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ReservationsScreen(),
        ),
      );
    }
  }

Widget buildSpotCard(ParkingApiModel spot) {
  final isSelected = selectedSpot?.id == spot.id;
  final isAvailable = spot.availableSpots > 0;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedSpot = spot;
      });
    },
    child: Container(
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? Colors.red
              : (isAvailable ? Colors.green : Colors.red),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.local_parking),
          Text("P${spot.id}"),
          Text(spot.location),
          Text("Boş: ${spot.availableSpots}"),
        ],
      ),
    ),
  );
}

  Widget buildEmptyState() {
    return const Center(
      child: Text("Park yeri bulunamadı"),
    );
  }

  @override
    Widget build(BuildContext context) {

  final filtered = parkings
      .where((p) => p.location == selectedFloor)
      .toList();

  return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Rezervasyon Oluştur"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : parkings.isEmpty
              ? buildEmptyState()
              : Column(
                  children: [
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 10,
                      children: floors.map((floor) {
                        return ChoiceChip(
                          label: Text(floor),
                          selected: selectedFloor == floor,
                          onSelected: (_) {
                            setState(() {
                              selectedFloor = floor;
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

Expanded(
  child: GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: filtered.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemBuilder: (context, index) {
      return buildSpotCard(filtered[index]);
    },
  ),
),

                    if (selectedSpot != null)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Seçilen: P${selectedSpot!.id}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: selectedSpot == null ? null : createReservation,
                        child: const Text("Rezervasyon Yap"),
                      ),
                    ),
                  ],
                ),
    );
  }
}