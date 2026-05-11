import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';

class ReservationsScreen extends StatefulWidget {
  /// MainNavigation içinde tab olarak gösterildiğinde, AppBar'daki geri
  /// butonunun hangi davranışı yapacağını dışarıdan veriyoruz (örn. ana
  /// sekmeye dön). Tab dışında (push edildiğinde) bu null bırakılır ve
  /// klasik Navigator.pop davranışı çalışır.
  final VoidCallback? onBack;

  const ReservationsScreen({super.key, this.onBack});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List reservations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  Future<void> loadReservations() async {
    final data = await ApiService.getMyReservations();
    if (!mounted) return;
    setState(() {
      reservations = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('Rezervasyonlarım'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Geri',
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              loadReservations();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SizedBox(height: 4),
                    ...reservations.map((r) => _buildReservationCard(r)),
                  ],
                ),
    );
  }

  Widget _buildReservationCard(dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
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
              const Icon(Icons.local_parking, color: Color(0xFFE53935), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  r['parking']?['parkingName'] ??
                      r['parking']?['location'] ??
                      'Park ID: ${r['parking']?['id'] ?? '-'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _infoRow(Icons.directions_car_outlined, "Plaka", r['plateNumber'] ?? '-'),
          const SizedBox(height: 8),
          _infoRow(Icons.play_circle_outline, "Giriş", 
            r['actualEntryTime'] != null 
              ? _formatDate(r['actualEntryTime']) 
              : _formatDate(r['startTime'])),
          const SizedBox(height: 8),
          _infoRow(Icons.stop_circle_outlined, "Çıkış", 
            r['actualExitTime'] != null 
              ? _formatDate(r['actualExitTime']) 
              : (r['status'] == 'DONE' ? _formatDate(r['endTime']) : 'Devam ediyor')),
          const SizedBox(height: 10),
          _buildStatusBadge(r['status']),
          if (r['status'] == 'ACTIVE' ||
              r['status'] == 'PENDING' ||
              r['status'] == 'PENDING_ENTRY') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showQrDialog(r['id'] is int ? r['id'] as int : int.parse(r['id'].toString())),
                icon: const Icon(Icons.qr_code_2_rounded),
                label: const Text('QR Kodu Göster'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text('Rezervasyonu İptal Et'),
                      content: const Text('Bu rezervasyonu iptal etmek istediğinize emin misiniz?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Hayır'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('İptal Et'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await ApiService.cancelReservation(r['id'] as int);
                    loadReservations();
                  }
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Rezervasyonu İptal Et'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text("$label: ", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString());
      return "${dt.day.toString().padLeft(2,'0')}.${dt.month.toString().padLeft(2,'0')}.${dt.year}"
          "  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return raw.toString();
    }
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case 'ACTIVE':
        color = Colors.green; label = 'Aktif'; icon = Icons.check_circle_outline; break;
      case 'PENDING':
      case 'PENDING_ENTRY':
        color = Colors.orange; label = 'Giriş Bekliyor'; icon = Icons.hourglass_top_outlined; break;
      case 'PARKED':
        color = Colors.green; label = 'Park Halinde'; icon = Icons.local_parking; break;
      case 'CANCELLED':
        color = Colors.red; label = 'İptal Edildi'; icon = Icons.cancel_outlined; break;
      case 'DONE':
        color = Colors.blueGrey; label = 'Tamamlandı'; icon = Icons.done_all_rounded; break;
      default:
        color = Colors.grey; label = status ?? '-'; icon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _showQrDialog(int reservationId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      ),
    );

    final data = await ApiService.getQrToken(reservationId);
    if (!mounted) return;
    Navigator.pop(context);

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR kodu alınamadı. Lütfen tekrar deneyin.'), backgroundColor: Colors.red),
      );
      return;
    }

    final bool qrUsed = data['qrUsed'] == true;
    final String qrToken = data['qrToken']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.qr_code_2_rounded, color: Color(0xFFE53935)),
                  const SizedBox(width: 8),
                  Text(
                    qrUsed ? 'QR Kullanıldı' : 'Giriş QR Kodu',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                qrUsed ? 'Bu QR daha önce kullanıldı.' : 'Otoparka girişte okutun.',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (qrUsed)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                )
              else if (qrToken.isNotEmpty)
                QrImageView(
                  data: qrToken,
                  version: QrVersions.auto,
                  size: 220,
                  eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFFE53935)),
                  dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: const Color(0xFFF5F5F5)),
                )
              else
                const Text('QR token boş', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF222222), borderRadius: BorderRadius.circular(22)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.event_busy_rounded, size: 70, color: Colors.grey),
              SizedBox(height: 16),
              Text('Henüz rezervasyon yok',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Rezervasyon oluşturmak için "Oluştur" sekmesine gidin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}