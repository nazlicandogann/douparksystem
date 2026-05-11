import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/user_store.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Dashboard', 'Kullanıcılar', 'Rezervasyonlar', 'Otoparklar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Admin Paneli', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ApiService.logout();
              AuthService.logout();
              UserStore.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final selected = _selectedTab == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: selected ? AppColors.primary : Colors.white54,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: return const _DashboardTab();
      case 1: return const _UsersTab();
      case 2: return const _ReservationsTab();
      case 3: return const _ParkingsTab();
      default: return const SizedBox();
    }
  }
}

// ─── DASHBOARD ────────────────────────────────────────────────────────────────

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await ApiService.getAdminStats();
    if (mounted) setState(() { _stats = stats; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (_stats == null) return const Center(child: Text('İstatistikler yüklenemedi'));

    final cards = [
      {'label': 'Toplam Kullanıcı', 'value': '${_stats!['totalUsers']}', 'icon': Icons.people, 'color': Colors.blue},
      {'label': 'Toplam Rezervasyon', 'value': '${_stats!['totalReservations']}', 'icon': Icons.receipt_long, 'color': Colors.orange},
      {'label': 'Aktif Rezervasyon', 'value': '${_stats!['activeReservations']}', 'icon': Icons.directions_car, 'color': Colors.green},
      {'label': 'Toplam Otopark', 'value': '${_stats!['totalParkings']}', 'icon': Icons.local_parking, 'color': AppColors.primary},
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Genel Bakış', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: cards.map((c) => _StatCard(
                label: c['label'] as String,
                value: c['value'] as String,
                icon: c['icon'] as IconData,
                color: c['color'] as Color,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.white12, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── KULLANICILAR ─────────────────────────────────────────────────────────────

class _UsersTab extends StatefulWidget {
  const _UsersTab();
  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final users = await ApiService.getAdminUsers();
    if (mounted) setState(() { _users = users; _loading = false; });
  }

  Future<void> _toggleRole(dynamic user) async {
    final newRole = user['role'] == 'ADMIN' ? 'USER' : 'ADMIN';
    final ok = await ApiService.updateUserRole(user['id'], newRole);
    if (ok) {
      _snack('${user['email']} → $newRole yapıldı');
      _load();
    } else {
      _snack('Rol güncellenemedi', error: true);
    }
  }

  Future<void> _delete(dynamic user) async {
    final confirm = await _confirm('${user['email']} kullanıcısını silmek istiyor musunuz?');
    if (!confirm) return;
    final ok = await ApiService.deleteUser(user['id']);
    if (ok) { _snack('Kullanıcı silindi'); _load(); }
    else _snack('Silinemedi', error: true);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<bool> _confirm(String msg) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Onay'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İptal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          final isAdmin = u['role'] == 'ADMIN';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? AppColors.primary : Colors.blue,
                child: Text(
                  (u['name'] ?? '?')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(u['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u['email'] ?? '-'),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAdmin ? AppColors.primary.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      u['role'] ?? 'USER',
                      style: TextStyle(
                        color: isAdmin ? AppColors.primary : Colors.blue,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isAdmin ? Icons.person_remove : Icons.admin_panel_settings,
                        color: isAdmin ? Colors.orange : Colors.green, size: 20),
                    tooltip: isAdmin ? 'USER yap' : 'ADMIN yap',
                    onPressed: () => _toggleRole(u),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _delete(u),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── REZERVASYONLAR ──────────────────────────────────────────────────────────

class _ReservationsTab extends StatefulWidget {
  const _ReservationsTab();
  @override
  State<_ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<_ReservationsTab> {
  List<dynamic> _reservations = [];
  bool _loading = true;
  String _filter = 'TÜMÜ';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ApiService.getAdminReservations();
    if (mounted) setState(() { _reservations = res; _loading = false; });
  }

  Future<void> _delete(dynamic r) async {
    final ok = await ApiService.deleteReservation(r['id']);
    if (ok) { _snack('Rezervasyon silindi'); _load(); }
    else _snack('Silinemedi', error: true);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'ACTIVE': return Colors.green;
      case 'WAITING': return Colors.orange;
      case 'DONE': return Colors.blue;
      case 'CANCELLED': return Colors.red;
      default: return Colors.grey;
    }
  }

  List<dynamic> get _filtered {
    if (_filter == 'TÜMÜ') return _reservations;
    return _reservations.where((r) => r['status'] == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final filters = ['TÜMÜ', 'WAITING', 'ACTIVE', 'DONE', 'CANCELLED'];

    return Column(
      children: [
        Container(
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: filters.map((f) {
                final sel = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(f, style: TextStyle(
                      color: sel ? Colors.white : Colors.white54,
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: _filtered.isEmpty
                ? const Center(child: Text('Rezervasyon bulunamadı'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final r = _filtered[i];
                      final status = r['status'] ?? '-';
                      final user = r['user'];
                      final parking = r['parking'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('#${r['id']}  ${parking?['parkingName'] ?? '-'}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _statusColor(status).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(status,
                                            style: TextStyle(color: _statusColor(status),
                                                fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                        onPressed: () => _delete(r),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text('Kullanıcı: ${user?['email'] ?? '-'}',
                                  style: const TextStyle(fontSize: 13, color: Colors.white54)),
                              Text('Plaka: ${r['plateNumber'] ?? '-'}',
                                  style: const TextStyle(fontSize: 13, color: Colors.white54)),
                              Text('Giriş: ${_fmt(r['startTime'])}',
                                  style: const TextStyle(fontSize: 13, color: Colors.white54)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  String _fmt(dynamic dt) {
    if (dt == null) return '-';
    final s = dt.toString();
    if (s.length >= 16) return s.substring(0, 16).replaceAll('T', ' ');
    return s;
  }
}

// ─── OTOPARKLAR ──────────────────────────────────────────────────────────────

class _ParkingsTab extends StatefulWidget {
  const _ParkingsTab();
  @override
  State<_ParkingsTab> createState() => _ParkingsTabState();
}

class _ParkingsTabState extends State<_ParkingsTab> {
  List<dynamic> _parkings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final list = await ApiService.getAllParkings();
    if (mounted) setState(() {
      _parkings = list.map((p) => {
        'id': p.id,
        'parkingName': p.location,
        'totalSpots': p.totalSpots,
        'availableSpots': p.availableSpots,
      }).toList();
      _loading = false;
    });
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : Colors.green,
    ));
  }

  Future<void> _showParkingDialog({Map<String, dynamic>? existing}) async {
    final nameCtrl = TextEditingController(text: existing?['parkingName'] ?? '');
    final codeCtrl = TextEditingController();
    final spotsCtrl = TextEditingController(text: existing?['totalSpots']?.toString() ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Otopark Ekle' : 'Otopark Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Otopark Adı')),
            if (existing == null)
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Kod (örn: A)')),
            TextField(controller: spotsCtrl, decoration: const InputDecoration(labelText: 'Toplam Spot'),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(context);
              final data = {
                'parkingName': nameCtrl.text.trim(),
                'totalSpots': int.tryParse(spotsCtrl.text.trim()) ?? 0,
                'status': 'ACTIVE',
                if (existing == null) 'code': codeCtrl.text.trim(),
              };
              bool ok;
              if (existing == null) {
                ok = await ApiService.addParking(data);
              } else {
                ok = await ApiService.updateParking(existing['id'], data);
              }
              if (ok) { _snack(existing == null ? 'Otopark eklendi' : 'Güncellendi'); _load(); }
              else _snack('İşlem başarısız', error: true);
            },
            child: Text(existing == null ? 'Ekle' : 'Kaydet', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(dynamic p) async {
    final ok = await ApiService.deleteParking(p['id']);
    if (ok) { _snack('Otopark silindi'); _load(); }
    else _snack('Silinemedi', error: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showParkingDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _parkings.isEmpty
            ? const Center(child: Text('Otopark bulunamadı'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _parkings.length,
                itemBuilder: (_, i) {
                  final p = _parkings[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_parking, color: AppColors.primary),
                      ),
                      title: Text(p['parkingName'] ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      subtitle: Text('Toplam: ${p['totalSpots']} spot'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                            onPressed: () => _showParkingDialog(existing: p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            onPressed: () => _delete(p),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}