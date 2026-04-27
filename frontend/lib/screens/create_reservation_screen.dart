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
  // --- DEĞİŞKEN TANIMLAMALARI ---
  String selectedFloor = 'A Blok';
  ParkingApiModel? selectedParking;
  final TextEditingController plateController = TextEditingController();
  
  List<ParkingApiModel> parkings = [];
  bool isLoading = true;
  
  // Harita için gerekli yeni değişkenler
  List<int> occupiedSpots = []; // Backend'den gelen dolu spotların listesi
  int? selectedSpotIndex;       // Kullanıcının seçtiği kutucuk
  
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

  // Backend'den otoparka ait dolu spotları çeker
  Future<void> fetchOccupiedSpots(int parkingId) async {
    final spots = await ApiService.getOccupiedSpots(parkingId);
    setState(() {
      occupiedSpots = spots;
    });
  }

  Future<void> loadParkings() async {
    final data = await ApiService.getAllParkings();
    setState(() {
      parkings = data;
      isLoading = false;
      
      // firstOrNull hatasını engellemek için güvenli liste kontrolü:
      final matches = data.where((p) => p.location == selectedFloor).toList();
      selectedParking = matches.isNotEmpty ? matches.first : null;
    });

    // Sayfa ilk yüklendiğinde varsayılan katın (Örn: A Blok) dolu yerlerini çek
    if (selectedParking != null) {
      await fetchOccupiedSpots(selectedParking!.id);
    }
  }

  Future<void> createReservation() async {
    // Giriş kontrolü - rezervasyon yapmak için giriş gerekli
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
      _showSnackBar("Lütfen haritadan bir park yeri (spot) seçin");
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

    // ISO-8601 formatı
    String formatDateTime(DateTime dt) {
      return "${dt.year.toString().padLeft(4,'0')}-"
             "${dt.month.toString().padLeft(2,'0')}-"
             "${dt.day.toString().padLeft(2,'0')}T"
             "${dt.hour.toString().padLeft(2,'0')}:"
             "${dt.minute.toString().padLeft(2,'0')}:"
             "${dt.second.toString().padLeft(2,'0')}";
    }

    // Backend'e gönderim
    final result = await ApiService.createReservation(
      parkingId: selectedParking!.id,
      plateNumber: plate,
      startTime: formatDateTime(now),
      endTime: formatDateTime(end),
      selectedSpotIndex: selectedSpotIndex,
    );

    setState(() { isLoading = false; });

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ReservationsScreen()));
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

  // Seçili blok için dinamik park haritası
  Widget _buildParkingMap(ParkingApiModel parking) {
    final int total = 60; // Görseldeki talebe göre 60 spot
    final int available = 60 - occupiedSpots.length; // Boş yer hesabı düzeltildi

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
              Text(
                "${parking.location} — Park Haritası",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF222222),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Boş Spotu Seçin: $available / $total",
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 14),

          // --- GRID HARITA ---
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.7,
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
                child: Transform.rotate(
                  angle: index % 2 == 0 ? 0.05 : -0.05, // Hafif eğim
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOccupied 
                          ? Colors.red.withOpacity(0.3) 
                          : (isSelected ? Colors.blue : Colors.green.withOpacity(0.15)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade900 : (isOccupied ? Colors.red : Colors.green.withOpacity(0.4)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.directions_car,
                        size: 20, 
                        color: isOccupied ? Colors.red : (isSelected ? Colors.white : Colors.green),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 14),

          // Lejant
          Row(
            children: [
              _legendItem(Colors.green, "Boş"),
              const SizedBox(width: 12),
              _legendItem(Colors.red, "Dolu"),
              const SizedBox(width: 12),
              _legendItem(Colors.blue, "Seçili"),
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
    // firstOrNull kaldırıldı, güvenli filtreleme getirildi
    final currentMatches = parkings.where((p) => p.location == selectedFloor).toList();
    final currentParking = currentMatches.isNotEmpty ? currentMatches.first : null;

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
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Park Bölgesi Seç",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: floors.map((floor) {
                      // firstOrNull kaldırıldı, güvenli filtreleme getirildi
                      final floorMatches = parkings.where((x) => x.location == floor).toList();
                      final p = floorMatches.isNotEmpty ? floorMatches.first : null;
                      final bool isSelected = selectedFloor == floor;

                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedFloor = floor;
                            selectedParking = p;
                            selectedSpotIndex = null; // Kat değişince seçimi sıfırla
                            occupiedSpots = []; // Yeni kat yüklenene kadar dolu yerleri temizle
                          });
                          
                          if (p != null) {
                            await fetchOccupiedSpots(p.id); // Yeni katın dolu spotlarını çek
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: isSelected ? const Color(0xFFD32F2F) : const Color(0xFFE0E0E0)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                floor,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                p != null ? "${p.availableSpots} boş" : "-",
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

                  if (currentParking != null)
                    _buildParkingMap(currentParking),

                  const SizedBox(height: 20),

                  const Text(
                    "Araç Plakası",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF222222)),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "Rezervasyon Yap — $selectedFloor",
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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