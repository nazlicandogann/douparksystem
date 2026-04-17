import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'create_reservation_screen.dart';
import '../services/api_service.dart';
import '../models/backend/parking_api_model.dart';
import '../services/auth_service.dart';

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
    final data = await ApiService.getAllParkings();
    setState(() {
      parkings = data;
      isLoading = false;
    });
  }

  // ✅ _getColor is now properly inside the class
  Color _getColor(double percent) {
    if (percent > 0.6) return Colors.green;    // çok boş
    if (percent > 0.3) return Colors.blue;  // orta
    return Colors.red;                        // dolu
  }

  Widget buildTab(String text, int index) {
    final isActive = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          if (isActive)
            Container(
              height: 3,
              width: 40,
              color: const Color(0xFFD32F2F),
            ),
        ],
      ),
    );
  }

  Widget buildContent() {
    switch (selectedTab) {
      case 0:
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "DouPark ile QR giriş, anlık doluluk ve rezervasyon yapabilirsiniz.",
          ),
        );

      case 1:
        // ✅ Loading state
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // ✅ Single merged case 1 — progress bar view
        return Column(
          children: parkings.map((p) {
            const int total = 100; // SABİT kapasite
            final int empty = p.availableSpots;
            final double percent = empty / total;
            final int percentText = (percent * 100).toInt();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ÜST SATIR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        p.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "%$percentText boş",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // BAR
                  Stack(
                    children: [
                      Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percent.clamp(0.0, 1.0), // ✅ güvenli clamp
                        child: Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getColor(percent),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // ALT YAZI
                  Text(
                    "$empty / $total boş",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),

                  const Divider(height: 25),
                ],
              ),
            );
          }).toList(),
        );

      case 2:
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Text("0-60 Dakika: Ücretsiz\n1-3 Saat: 150₺\n3-6 Saat: 250₺\nGün Boyu:300"),
        );

      case 3:
        return Center(
          child: ElevatedButton(
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
            child: const Text("Rezervasyon Yap"),
          ),
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(Icons.qr_code, color: Color(0xFFD32F2F)),
            onPressed: () {
              print("QR açıldı");
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Giriş"),
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
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://images.unsplash.com/photo-1583267746897-2cf415887172",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Text(
                    "DouPark\nAkıllı Otopark Sistemi",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TABS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTab("Bilgi", 0),
                const SizedBox(width: 30),
                buildTab("Uygunluk", 1),
                const SizedBox(width: 30),
                buildTab("Fiyat Listesi", 2),
                const SizedBox(width: 30),
                buildTab("Rezervasyon", 3),
              ],
            ),

            const SizedBox(height: 30),

            // CONTENT
            buildContent(),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}