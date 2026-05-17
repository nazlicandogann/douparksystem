import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_store.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

// Web için dosya seçici
import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = UserStore.fullName;
    _phoneCtrl.text = UserStore.phone;
    _loadReservationCount();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final plates = await StorageService.loadVehicles(UserStore.email);
    final phone = UserStore.email.isNotEmpty
        ? await StorageService.loadPhone(UserStore.email)
        : '';
    final imgBase64 = UserStore.email.isNotEmpty
        ? await StorageService.loadProfileImage(UserStore.email)
        : null;
    if (mounted) setState(() {
      UserStore.vehicles = plates;
      if (phone.isNotEmpty) UserStore.phone = phone;
      if (imgBase64 != null) {
        _pickedImageBytes = base64Decode(imgBase64);
      }
    });
  }

  Future<void> _loadReservationCount() async {
    final reservations = await ApiService.getMyReservations();
    if (mounted) {
      setState(() {
        UserStore.reservationCount = reservations.length;
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        // Base64 olarak kalıcı kaydet
        if (UserStore.email.isNotEmpty) {
          final base64Str = base64Encode(bytes);
          await StorageService.saveProfileImage(UserStore.email, base64Str);
        }
        if (mounted) {
          setState(() {
            _pickedImageBytes = bytes;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı güncellendi ✓'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fotoğraf seçilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad soyad boş bırakılamaz'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      UserStore.fullName = name;
      UserStore.phone = phone;
      _editing = false;
    });

    // Kalıcı kaydet
    if (UserStore.email.isNotEmpty) {
      await StorageService.savePhone(UserStore.email, phone);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil güncellendi ✓'), backgroundColor: Colors.green),
    );
  }

  Future<void> _addVehicle() async {
    final plate = _plateCtrl.text.trim().toUpperCase();
    if (plate.isEmpty) return;
    setState(() {
      UserStore.addVehicle(plate);
      _plateCtrl.clear();
    });
    await StorageService.saveVehicles(UserStore.email, UserStore.vehicles);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$plate eklendi'), backgroundColor: Colors.green),
    );
  }

  void _showAddVehicleDialog() {
    _plateCtrl.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Araç Ekle',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _plateCtrl,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
              color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.bold),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: 'Örn: 34ABC123',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.directions_car, color: AppColors.red),
            filled: true,
            fillColor: const Color(0xFF2A2A2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _addVehicle,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(UserBadge badge, bool earned) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(badge.title,
                style: TextStyle(
                  color: earned ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description,
                style: TextStyle(color: earned ? Colors.white70 : Colors.white38)),
            if (!earned && badge.requiredCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Kazanmak için: ${badge.requiredCount} rezervasyon gerekli',
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (UserStore.reservationCount / badge.requiredCount).clamp(0.0, 1.0),
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
              const SizedBox(height: 4),
              Text(
                '${UserStore.reservationCount}/${badge.requiredCount}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    ApiService.logout();
    AuthService.logout();
    UserStore.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final earned = UserStore.earnedBadges;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Profilim', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
            onPressed: () => setState(() {
              _editing = !_editing;
              if (_editing) {
                _nameCtrl.text = UserStore.fullName;
                _phoneCtrl.text = UserStore.phone;
              }
            }),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ── AVATAR ─────────────────────────────────────────────────────
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.red, Color(0xFF880000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.red.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: _pickedImageBytes != null
                        ? ClipOval(
                            child: Image.memory(_pickedImageBytes!,
                                fit: BoxFit.cover, width: 100, height: 100))
                        : Center(
                            child: Text(
                              UserStore.fullName.isNotEmpty
                                  ? UserStore.fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF111111), width: 2),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(Icons.camera_alt, size: 15, color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              UserStore.fullName.isNotEmpty ? UserStore.fullName : 'Kullanıcı',
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),

            // Rozet sayısı
            if (earned.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...earned.take(3).map((b) => Text(b.emoji,
                      style: const TextStyle(fontSize: 18))),
                  if (earned.length > 3)
                    Text(' +${earned.length - 3}',
                        style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            const SizedBox(height: 6),

            // Rol rozeti
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: UserStore.isAdmin
                    ? Colors.amber.withOpacity(0.15)
                    : AppColors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: UserStore.isAdmin
                      ? Colors.amber.withOpacity(0.4)
                      : AppColors.red.withOpacity(0.4),
                ),
              ),
              child: Text(
                UserStore.isAdmin ? '👑 Admin' : '🚗 Sürücü',
                style: TextStyle(
                  color: UserStore.isAdmin ? Colors.amber : AppColors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── KİŞİSEL BİLGİLER ───────────────────────────────────────────
            _SectionTitle(title: 'Kişisel Bilgiler'),
            const SizedBox(height: 12),

            if (_editing) ...[
              _EditField(
                label: 'Ad Soyad',
                icon: Icons.person_outline,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 12),
              // Telefon - sadece rakam, otomatik format
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  _PhoneNumberFormatter(),
                ],
                decoration: InputDecoration(
                  labelText: 'Telefon (05XX XXX XX XX)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.red),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.red),
                  ),
                  hintText: '0538 455 99 55',
                  hintStyle: const TextStyle(color: Colors.white24),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ] else ...[
              _InfoCard(icon: Icons.person_outline, label: 'Ad Soyad',
                  value: UserStore.fullName.isNotEmpty ? UserStore.fullName : '-'),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.email_outlined, label: 'E-posta',
                  value: UserStore.email.isNotEmpty ? UserStore.email : '-'),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.phone_outlined, label: 'Telefon',
                  value: UserStore.phone.isNotEmpty ? UserStore.phone : 'Eklenmedi'),
              const SizedBox(height: 10),
              _InfoCard(icon: Icons.local_parking_rounded, label: 'Toplam Rezervasyon',
                  value: '${UserStore.reservationCount} rezervasyon'),
            ],

            const SizedBox(height: 24),

            // ── ROZETLER ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Rozetlerim'),
                Text('${earned.length}/${UserStore.allBadges.length}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
              children: UserStore.allBadges.map((badge) {
                final isEarned = earned.contains(badge);
                return GestureDetector(
                  onTap: () => _showBadgeDetail(badge, isEarned),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isEarned
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isEarned
                            ? AppColors.red.withOpacity(0.4)
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          badge.emoji,
                          style: TextStyle(
                            fontSize: 28,
                            color: isEarned ? null : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          badge.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: isEarned ? Colors.white70 : Colors.white24,
                            fontWeight: isEarned ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (!isEarned)
                          const Icon(Icons.lock_outline,
                              size: 12, color: Colors.white24),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── ARAÇLARIM ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle(title: 'Araçlarım'),
                TextButton.icon(
                  onPressed: _showAddVehicleDialog,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.red),
                  label: const Text('Ekle',
                      style: TextStyle(color: AppColors.red, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (UserStore.vehicles.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.directions_car_outlined,
                        color: Colors.white24, size: 36),
                    SizedBox(height: 8),
                    Text('Araç eklenmedi',
                        style: TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              )
            else
              ...UserStore.vehicles.map((plate) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car,
                            color: AppColors.red, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          plate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 15,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          onPressed: () async {
                                setState(() => UserStore.removeVehicle(plate));
                                await StorageService.saveVehicles(UserStore.email, UserStore.vehicles);
                              },
                        ),
                      ],
                    ),
                  )),

            const SizedBox(height: 28),

            // ── ÇIKIŞ ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Çıkış Yap',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── TELEFON FORMAT ────────────────────────────────────────────────────────────
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i == 4 || i == 7 || i == 9) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// ── YARDIMCI WİDGET'LAR ──────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white70)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.red, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _EditField({
    required this.label,
    required this.icon,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: AppColors.red),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
      ),
    );
  }
}
