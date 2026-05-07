import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
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
  ParkingApiModel? selectedParking;
  final TextEditingController plateController = TextEditingController();

  List<ParkingApiModel> parkings = [];
  bool isLoading = true;

  // Park haritası için değişkenler
  List<int> occupiedSpots = [];
  int? selectedSpotIndex;

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

  Future<void> fetchOccupiedSpots(int parkingId) async {
    final spots = await ApiService.getOccupiedSpots(parkingId);
    if (!mounted) return;
    setState(() {
      occupiedSpots = spots;
    });
  }

  Future<void> loadParkings() async {
    final data = await ApiService.getAllParkings();
    if (!mounted) return;
    // Sadece A Blok, B Blok, Misafir goster
    final allowed = ['A Blok', 'B Blok', 'Misafir'];
    final filtered = data.where((p) =>
      allowed.any((a) => p.location.toLowerCase().contains(a.toLowerCase()))
    ).toList();

    setState(() {
      parkings = filtered.isNotEmpty ? filtered : data;
      isLoading = false;
      if (parkings.isNotEmpty) {
        selectedParking = parkings.first;
      }
    });

    if (selectedParking != null) {
      await fetchOccupiedSpots(selectedParking!.id);
    }
  }

  Future<void> createReservation() async {
    if (!AuthService.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (selectedParking == null) {
      _showSnackBar("Park alanı bulunamadı");
      return;
    }

    if (selectedSpotIndex == null) {
      _showSnackBar("Lütfen haritadan bir park yeri seçin");
      return;
    }

    final plate = plateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      _showSnackBar("Lütfen plaka girin");
      return;
    }

    setState(() { isLoading = true; });

    final now = DateTime.now();
    final end = now.add(const Duration(hours: 1));

    String formatDateTime(DateTime dt) {
      return "${dt.year.toString().padLeft(4,'0')}-"
             "${dt.month.toString().padLeft(2,'0')}-"
             "${dt.day.toString().padLeft(2,'0')}T"
             "${dt.hour.toString().padLeft(2,'0')}:"
             "${dt.minute.toString().padLeft(2,'0')}:"
             "${dt.second.toString().padLeft(2,'0')}";
    }

    final result = await ApiService.createReservation(
      parkingId: selectedParking!.id,
      plateNumber: plate,
      startTime: formatDateTime(now),
      endTime: formatDateTime(end),
      selectedSpotIndex: selectedSpotIndex,
    );

    if (!mounted) return;
    setState(() { isLoading = false; });

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReservationsScreen()),
      );
    } else {
      _showSnackBar(result['message'] ?? 'Rezervasyon başarısız', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.black87,
      ),
    );
  }

  Widget _buildParkingMap(ParkingApiModel parking) {
    final int total = parking.totalSpots > 0 ? parking.totalSpots : 20;
    final int available = total - occupiedSpots.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E3E6)),
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
              const Icon(Icons.map_outlined, color: Color(0xFFD32F2F), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "${parking.location} — Park Haritası",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Boş Spot Seçin: $available / $total",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1.1,
            ),
            itemCount: total,
            itemBuilder: (context, index) {
              final bool isOccupied = occupiedSpots.contains(index);
              final bool isSelected = selectedSpotIndex == index;

              return GestureDetector(
                onTap: isOccupied ? null : () {
                  setState(() {
                    selectedSpotIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isOccupied
                        ? Colors.red.withOpacity(0.2)
                        : (isSelected ? const Color(0xFFD32F2F) : Colors.green.withOpacity(0.12)),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD32F2F)
                          : (isOccupied ? Colors.red.shade300 : Colors.green.withOpacity(0.4)),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 11,
                      color: isOccupied
                          ? Colors.red
                          : (isSelected ? Colors.white : Colors.green),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 14),
          Row(
            children: [
              _legendItem(Colors.green, "Boş"),
              const SizedBox(width: 12),
              _legendItem(Colors.red, "Dolu"),
              const SizedBox(width: 12),
              _legendItem(const Color(0xFFD32F2F), "Seçili"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color.withOpacity(0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Rezervasyon Oluştur"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : parkings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_parking_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          "Park alanı bulunamadı",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Backend bağlantısını kontrol edin",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => isLoading = true);
                            loadParkings();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text("Yenile"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Park Bölgesi Seç",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Backend'den gelen gerçek park alanlarını listele
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: parkings.map((p) {
                          final bool isSelected = selectedParking?.id == p.id;
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                selectedParking = p;
                                selectedSpotIndex = null;
                                occupiedSpots = [];
                              });
                              await fetchOccupiedSpots(p.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFD32F2F)
                                      : const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    p.location,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${p.availableSpots} boş",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? Colors.white70 : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      if (selectedParking != null)
                        _buildParkingMap(selectedParking!),

                      const SizedBox(height: 20),

                      const Text(
                        "Araç Plakası",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: plateController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: "Örn: 34ABC123",
                          prefixIcon: const Icon(Icons.directions_car, color: Color(0xFFD32F2F)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: createReservation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            selectedParking != null
                                ? "Rezervasyon Yap — ${selectedParking!.location}"
                                : "Rezervasyon Yap",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}