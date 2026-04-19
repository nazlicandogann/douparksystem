import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/backend/parking_api_model.dart';
import '../services/api_service.dart';
import 'reservations_screen.dart';

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  String selectedFloor = 'A Blok';
  ParkingApiModel? selectedSpot;
  final TextEditingController plateController = TextEditingController();

  List<ParkingApiModel> parkings = [];
  bool isLoading = true;

  final List<String> floors = ['A Blok', 'B Blok', 'Misafir'];

  @override
  void initState() {
    super.initState();
    loadParkings();
  }

  @override
  void dispose() {
    plateController.dispose();
    super.dispose();
  }

  Future<void> loadParkings() async {
    final data = await ApiService.getAllParkings();
    setState(() {
      parkings = data;
      isLoading = false;
    });
  }

  Future<void> createReservation() async {
    if (selectedSpot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen park yeri seçin")),
      );
      return;
    }

    final plate = plateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen plaka girin")),
      );
      return;
    }

    setState(() { isLoading = true; });

    final now = DateTime.now();
    final end = now.add(const Duration(hours: 1));

    final result = await ApiService.createReservation(
      parkingId: selectedSpot!.id,
      plateNumber: plate,
      startTime: now.toIso8601String(),
      endTime: end.toIso8601String(),
    );

    setState(() { isLoading = false; });

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationsScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Rezervasyon başarısız'), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildSpotCard(ParkingApiModel spot) {
    final isSelected = selectedSpot?.id == spot.id;
    final isAvailable = spot.availableSpots > 0;

    return GestureDetector(
      onTap: isAvailable ? () => setState(() { selectedSpot = spot; }) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isAvailable ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.red : (isAvailable ? Colors.green : Colors.red),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_parking),
            Text("P${spot.id}"),
            Text(spot.location, style: const TextStyle(fontSize: 10)),
            Text("Boş: ${spot.availableSpots}", style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = parkings.where((p) => p.location == selectedFloor).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Rezervasyon Oluştur"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : parkings.isEmpty
              ? const Center(child: Text("Park yeri bulunamadı"))
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: floors.map((floor) {
                        return ChoiceChip(
                          label: Text(floor),
                          selected: selectedFloor == floor,
                          onSelected: (_) => setState(() { selectedFloor = floor; selectedSpot = null; }),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: plateController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: "Plaka (örn: 34ABC123)",
                          prefixIcon: const Icon(Icons.directions_car),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text("Bu blokta park yeri yok"))
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (context, index) => buildSpotCard(filtered[index]),
                            ),
                    ),
                    if (selectedSpot != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "Seçilen: ${selectedSpot!.location} - P${selectedSpot!.id}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: selectedSpot == null ? null : createReservation,
                          child: const Text("Rezervasyon Yap"),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
