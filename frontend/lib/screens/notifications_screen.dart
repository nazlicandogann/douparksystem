import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bildirimler"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.red),
              title: Text("Rezervasyon onaylandı"),
              subtitle: Text("AVM otoparkı için rezervasyonunuz oluşturuldu."),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.local_offer, color: Colors.red),
              title: Text("Yeni kampanya"),
              subtitle: Text("Bugün otopark kullanımında %20 indirim var."),
            ),
          ),
        ],
      ),
    );
  }
}