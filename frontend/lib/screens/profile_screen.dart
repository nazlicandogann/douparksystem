import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 42,
              backgroundColor: Colors.red,
              child: Icon(Icons.person, size: 42, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ceren İmat",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "ceren",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Card(
              child: ListTile(
                leading: Icon(Icons.directions_car, color: Colors.red),
                title: Text("Plaka"),
                subtitle: Text("34 ABC 123"),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.red),
                title: Text("E-posta"),
                subtitle: Text("ceren@mail.com"),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Çıkış Yap"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}