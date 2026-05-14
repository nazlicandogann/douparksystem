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
  final List<String> _tabs = ['Dashboard', 'Kullanıcılar', 'Rezervasyonlar', 'Otoparklar', 'Raporlar', 'Yaptırımlar'];

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
      case 4: return const _ReportsTab();
      case 5: return const _SanctionsTab();
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
              childAspectRatio: 1.4,
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
                      color: sel ? AppColors.primary : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(f, style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
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
// ─── RAPORLAR ─────────────────────────────────────────────────────────────────

class _ReportsTab extends StatefulWidget {
  const _ReportsTab();
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  Map<String, dynamic>? _stats;
  List<dynamic> _reservations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final stats = await ApiService.getAdminStats();
    final reservations = await ApiService.getAdminReservations();
    if (mounted) {
      setState(() {
        _stats = stats;
        _reservations = reservations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final total = _reservations.length;
    final done = _reservations.where((r) => r['status'] == 'DONE').length;
    final cancelled = _reservations.where((r) => r['status'] == 'CANCELLED').length;
    final pending = _reservations.where((r) => r['status'] == 'PENDING_ENTRY').length;
    final parked = _reservations.where((r) => r['status'] == 'PARKED').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sistem Raporları',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),

          // Rezervasyon dağılımı
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rezervasyon Dağılımı',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                _ReportRow('Toplam Rezervasyon', '$total', Colors.white),
                _ReportRow('Tamamlanan', '$done', Colors.green),
                _ReportRow('İptal Edilen', '$cancelled', Colors.red),
                _ReportRow('Giriş Bekliyor', '$pending', Colors.orange),
                _ReportRow('Park Halinde', '$parked', Colors.blue),
                const SizedBox(height: 12),
                if (total > 0) ...[
                  const Text('Tamamlanma Oranı',
                      style: TextStyle(fontSize: 12, color: Colors.white54)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: done / total,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '%${(done / total * 100).toStringAsFixed(1)} tamamlandı',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Sistem bilgisi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sistem Bilgileri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                _ReportRow('Toplam Kullanıcı', '${_stats?['totalUsers'] ?? '-'}', Colors.blue),
                _ReportRow('Toplam Otopark', '${_stats?['totalParkings'] ?? '-'}', AppColors.primary),
                _ReportRow('Aktif Rezervasyon', '${_stats?['activeReservations'] ?? '-'}', Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Hızlı eylemler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hızlı Eylemler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                _ActionButton(
                  icon: Icons.refresh,
                  label: 'Verileri Yenile',
                  color: Colors.blue,
                  onTap: () { setState(() => _loading = true); _load(); },
                ),
                const SizedBox(height: 8),
                _ActionButton(
                  icon: Icons.cleaning_services_outlined,
                  label: 'İptal Rezervasyonları Temizle',
                  color: Colors.orange,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Emin misiniz?', style: TextStyle(color: Colors.white)),
                        content: const Text('Tüm iptal edilmiş rezervasyonlar silinecek.',
                            style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Vazgeç', style: TextStyle(color: Colors.grey))),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                            child: const Text('Temizle'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      final cancelled = _reservations.where((r) => r['status'] == 'CANCELLED').toList();
                      int deleted = 0;
                      for (final r in cancelled) {
                        final id = r['id'];
                        if (id != null) {
                          final ok = await ApiService.deleteReservation(int.tryParse(id.toString()) ?? 0);
                          if (ok) deleted++;
                        }
                      }
                      setState(() => _loading = true);
                      _load();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$deleted iptal rezervasyon silindi'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ReportRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── YAPTIRIMLAR ──────────────────────────────────────────────────────────────

class _SanctionsTab extends StatefulWidget {
  const _SanctionsTab();
  @override
  State<_SanctionsTab> createState() => _SanctionsTabState();
}

class _SanctionsTabState extends State<_SanctionsTab> {
  List<dynamic> _allUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final users = await ApiService.getAdminUsers();
    if (mounted) {
      setState(() {
        _allUsers = users;
        _loading = false;
      });
    }
  }

  Future<void> _unban(dynamic user) async {
    final id = int.tryParse(user['id'].toString()) ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yasağı Kaldır', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '${user['email']} kullanıcısının rezervasyon yasağı kaldırılsın mı?\nNo-show sayacı da sıfırlanacak.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Yasağı Kaldır'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await ApiService.unbanUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Rezervasyon yasağı kaldırıldı ✓' : 'İşlem başarısız'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ));
        _load();
      }
    }
  }

  Future<void> _ban(dynamic user) async {
    final id = int.tryParse(user['id'].toString()) ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rezervasyon Yasağı Uygula', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '${user['email']} kullanıcısına rezervasyon yasağı uygulanmak istediğinize emin misiniz?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Vazgeç', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Yasak Uygula'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await ApiService.banUser(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok ? 'Rezervasyon yasağı uygulandı' : 'İşlem başarısız'),
          backgroundColor: ok ? Colors.orange : Colors.red,
        ));
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));

    final banned = _allUsers.where((u) => u['reservationBanned'] == true).toList();
    final warned = _allUsers.where((u) => 
        u['reservationBanned'] != true && 
        (u['noShowCount'] ?? 0) > 0).toList();
    final clean = _allUsers.where((u) => 
        u['reservationBanned'] != true && 
        (u['noShowCount'] ?? 0) == 0).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özet
          Row(children: [
            _SummaryChip(label: 'Toplam', count: _allUsers.length, color: Colors.blue),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Yasaklı', count: banned.length, color: Colors.red),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Uyarılı', count: warned.length, color: Colors.orange),
            const SizedBox(width: 10),
            _SummaryChip(label: 'Temiz', count: clean.length, color: Colors.green),
          ]),
          const SizedBox(height: 20),

          // Yasaklı kullanıcılar
          if (banned.isNotEmpty) ...[
            _SectionHeader(
              title: '🚫 Yasaklı Kullanıcılar',
              subtitle: 'Rezervasyon yapma yetkisi kaldırıldı',
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            ...banned.map((u) => _UserSanctionCard(
              user: u,
              onUnban: () => _unban(u),
              onBan: null,
            )),
            const SizedBox(height: 20),
          ],

          // Uyarılı kullanıcılar
          if (warned.isNotEmpty) ...[
            _SectionHeader(
              title: '⚠️ Uyarılı Kullanıcılar',
              subtitle: 'Gelmeme sayısı 1-2 arası',
              color: Colors.orange,
            ),
            const SizedBox(height: 10),
            ...warned.map((u) => _UserSanctionCard(
              user: u,
              onUnban: null,
              onBan: () => _ban(u),
            )),
            const SizedBox(height: 20),
          ],

          // Temiz kullanıcılar
          _SectionHeader(
            title: '✅ Temiz Kullanıcılar',
            subtitle: 'No-show kaydı yok',
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          if (clean.isEmpty)
            const Center(child: Text('Henüz veri yok', style: TextStyle(color: Colors.white38)))
          else
            ...clean.map((u) => _UserSanctionCard(
              user: u,
              onUnban: null,
              onBan: () => _ban(u),
            )),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _SummaryChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$count', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const _SectionHeader({required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
    ]);
  }
}

class _UserSanctionCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback? onUnban;
  final VoidCallback? onBan;
  const _UserSanctionCard({required this.user, this.onUnban, this.onBan});

  @override
  Widget build(BuildContext context) {
    final isBanned = user['reservationBanned'] == true;
    final noShow = user['noShowCount'] ?? 0;
    final name = user['name']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final role = user['role']?.toString() ?? 'USER';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBanned 
              ? Colors.red.withOpacity(0.4) 
              : noShow > 0 
                  ? Colors.orange.withOpacity(0.4) 
                  : Colors.white12,
        ),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBanned 
                ? Colors.red.withOpacity(0.2) 
                : noShow > 0 
                    ? Colors.orange.withOpacity(0.2) 
                    : Colors.white12,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: TextStyle(
                color: isBanned ? Colors.red : noShow > 0 ? Colors.orange : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              name.isNotEmpty ? name : email,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(email, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              if (isBanned)
                _Tag('YASAKLI', Colors.red)
              else if (noShow > 0)
                _Tag('UYARI ($noShow gelmeme)', Colors.orange)
              else
                _Tag('TEMİZ', Colors.green),
              const SizedBox(width: 6),
              _Tag(role, Colors.blue),
            ]),
          ]),
        ),
        const SizedBox(width: 8),
        // Aksiyon butonu
        if (onUnban != null)
          ElevatedButton(
            onPressed: onUnban,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yasağı\nKaldır', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          )
        else if (onBan != null)
          ElevatedButton(
            onPressed: onBan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yasak\nUygula', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
