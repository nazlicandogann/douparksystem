import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_navigation.dart';
import '../services/user_store.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../models/backend/parking_api_model.dart';
import '../services/api_service.dart';

enum TimeSlot { morning, afternoon, fullDay }

extension TimeSlotExt on TimeSlot {
  String get label {
    switch (this) {
      case TimeSlot.morning:   return 'Öğleden Önce';
      case TimeSlot.afternoon: return 'Öğleden Sonra';
      case TimeSlot.fullDay:   return 'Tüm Gün';
    }
  }
  String get hours {
    switch (this) {
      case TimeSlot.morning:   return '07:00 – 13:00';
      case TimeSlot.afternoon: return '13:00 – 19:00';
      case TimeSlot.fullDay:   return '07:00 – 19:00';
    }
  }
  String startTime(DateTime d) {
    final h = this == TimeSlot.afternoon ? 13 : 7;
    return '${d.year}-${_p(d.month)}-${_p(d.day)}T${_p(h)}:00:00';
  }
  String endTime(DateTime d) {
    final h = this == TimeSlot.morning ? 13 : 19;
    return '${d.year}-${_p(d.month)}-${_p(d.day)}T${_p(h)}:00:00';
  }
  String _p(int v) => v.toString().padLeft(2, '0');
}

class CreateReservationScreen extends StatefulWidget {
  const CreateReservationScreen({super.key});
  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  // Sadece A Blok ve B Blok - A önce
  static const _allowed = ['a blok', 'b blok'];
  static const _order   = ['a blok', 'b blok'];

  // Adım sistemi: 0=Tarih/Saat, 1=Blok+Harita, 2=Plaka
  int _step = 0;

  ParkingApiModel? _parking;
  final _plateCtrl = TextEditingController();
  List<ParkingApiModel> _parkings = [];
  List<int> _occupied = [];
  int? _spot;
  TimeSlot _slot = TimeSlot.morning;
  DateTime _date = DateTime.now();
  bool _loading = true;
  bool _saving = false;

  // Plaka seçim modu
  bool _useOwnVehicle = true; // true = profildeki araç, false = manuel

  @override
  void initState() {
    super.initState();
    _load();
    _loadSavedVehicles();
  }

  Future<void> _loadSavedVehicles() async {
    final plates = await StorageService.loadVehicles(UserStore.email);
    if (!mounted) return;
    setState(() {
      UserStore.vehicles = plates;
      if (UserStore.vehicles.isNotEmpty) {
        _plateCtrl.text = UserStore.vehicles.first;
        _useOwnVehicle = true;
      }
    });
  }

  @override
  void dispose() { _plateCtrl.dispose(); super.dispose(); }

  bool _isAllowed(ParkingApiModel p) =>
      _allowed.any((b) => p.location.toLowerCase().contains(b));

  Future<void> _load() async {
    final data = await ApiService.getAllParkings();
    if (!mounted) return;
    final filtered = data.where(_isAllowed).toList();
    // A Blok > B Blok sıralaması
    filtered.sort((a, b) {
      int ai = _order.indexWhere((o) => a.location.toLowerCase().contains(o));
      int bi = _order.indexWhere((o) => b.location.toLowerCase().contains(o));
      if (ai == -1) ai = 999;
      if (bi == -1) bi = 999;
      return ai.compareTo(bi);
    });
    setState(() {
      _parkings = filtered;
      _loading = false;
      if (_parkings.isNotEmpty) _parking = _parkings.first;
    });
    if (_parking != null) await _loadSpots(_parking!.id);
  }

  Future<void> _loadSpots(int id) async {
    // Seçilen tarih ve saat dilimine göre dolu spotları getir
    String? startTimeStr;
    String? endTimeStr;
    if (_slot != null) {
      startTimeStr = _slot!.startTime(_date);
      endTimeStr = _slot!.endTime(_date);
    }
    final spots = await ApiService.getOccupiedSpots(
      id,
      startTime: startTimeStr,
      endTime: endTimeStr,
    );
    if (!mounted) return;
    setState(() => _occupied = spots);
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _date = p);
  }

  Future<void> _submit() async {
    if (!AuthService.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }
    if (_parking == null) { _snack('Park alanı seçin'); return; }
    if (_spot == null)    { _snack('Haritadan park yeri seçin'); return; }
    final plate = _plateCtrl.text.trim().toUpperCase();
    if (plate.isEmpty)    { _snack('Plaka girin'); return; }

    setState(() => _saving = true);
    final result = await ApiService.createReservation(
      parkingId: _parking!.id,
      plateNumber: plate,
      startTime: _slot.startTime(_date),
      endTime: _slot.endTime(_date),
      selectedSpotIndex: _spot,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (result['success'] == true) {
      UserStore.reservationCount++;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } else {
      _snack(result['message'] ?? 'Rezervasyon başarısız', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Rezervasyon Oluştur',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _step--),
              )
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _parkings.isEmpty
              ? _empty()
              : Column(
                  children: [
                    _stepIndicator(),
                    Expanded(child: _stepContent()),
                  ],
                ),
    );
  }

  // ── ADIM GÖSTERGESİ ───────────────────────────────────────────────────────
  Widget _stepIndicator() {
    final steps = ['Tarih & Saat', 'Yer Seç', 'Plaka'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? Colors.green : active ? AppColors.primary : const Color(0xFF2A2A2A),
                        border: Border.all(
                          color: done ? Colors.green : active ? AppColors.primary : Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                            : Text('${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: active ? Colors.white : Colors.white38,
                                )),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? Colors.white : Colors.white38,
                          fontWeight: active ? FontWeight.bold : FontWeight.normal,
                        )),
                  ],
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 18),
                      color: done ? Colors.green : const Color(0xFF2A2A2A),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── ADIM İÇERİKLERİ ───────────────────────────────────────────────────────
  Widget _stepContent() {
    switch (_step) {
      case 0: return _step0DateSlot();
      case 1: return _step1Map();
      case 2: return _step2Plate();
      default: return const SizedBox();
    }
  }

  // ADIM 0: Tarih ve Saat Seçimi
  Widget _step0DateSlot() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Tarih Seç'),
      const SizedBox(height: 10),
      _datePicker(),
      const SizedBox(height: 20),
      _label('Zaman Dilimi Seç'),
      const SizedBox(height: 10),
      _timeSlots(),
      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
    ]),
  );

  // ADIM 1: Blok + Harita
  Widget _step1Map() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Seçilen tarih özeti
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            '${_date.day.toString().padLeft(2,'0')}.${_date.month.toString().padLeft(2,'0')}.${_date.year}  •  ${_slot.hours}',
            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _step = 0),
            child: const Text('Değiştir', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ]),
      ),
      const SizedBox(height: 20),
      _label('Park Bölgesi Seç'),
      const SizedBox(height: 10),
      _blockSelector(),
      const SizedBox(height: 20),
      if (_parking != null) _map(),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: _spot == null ? null : () => setState(() => _step = 2),
          style: ElevatedButton.styleFrom(
            backgroundColor: _spot == null ? Colors.white12 : AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text(
            _spot == null ? 'Haritadan yer seçin' : 'Devam Et →',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      const SizedBox(height: 20),
    ]),
  );

  // ADIM 2: Plaka Seçimi
  Widget _step2Plate() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Özet
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        ),
        child: Column(children: [
          Row(children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 14),
            const SizedBox(width: 6),
            Text(
              '${_date.day.toString().padLeft(2,'0')}.${_date.month.toString().padLeft(2,'0')}.${_date.year}  •  ${_slot.hours}',
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ]),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.local_parking, color: AppColors.primary, size: 14),
            const SizedBox(width: 6),
            Text(
              '${_parking?.location ?? '-'}  •  Yer ${(_spot ?? 0) + 1}',
              style: const TextStyle(color: AppColors.primary, fontSize: 12),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 24),
      _label('Araç Plakası'),
      const SizedBox(height: 12),

      // Kendi aracı seçeneği (profilde araç varsa)
      if (UserStore.vehicles.isNotEmpty) ...[
        // Kendi aracım
        GestureDetector(
          onTap: () => setState(() {
            _useOwnVehicle = true;
            _plateCtrl.text = UserStore.vehicles.first;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _useOwnVehicle ? AppColors.primary.withOpacity(0.1) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _useOwnVehicle ? AppColors.primary : Colors.white12,
                width: _useOwnVehicle ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                    _useOwnVehicle ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _useOwnVehicle ? AppColors.primary : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text('Kendi Aracım İçin',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
                // Araç listesi
                if (_useOwnVehicle) ...[
                  const SizedBox(height: 12),
                  ...UserStore.vehicles.map((plate) => GestureDetector(
                    onTap: () => setState(() => _plateCtrl.text = plate),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _plateCtrl.text == plate
                            ? AppColors.primary.withOpacity(0.2)
                            : const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _plateCtrl.text == plate ? AppColors.primary : Colors.transparent,
                        ),
                      ),
                      child: Row(children: [
                        const Icon(Icons.directions_car, color: AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Text(plate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            )),
                        const Spacer(),
                        if (_plateCtrl.text == plate)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                      ]),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Diğer araç
        GestureDetector(
          onTap: () => setState(() {
            _useOwnVehicle = false;
            _plateCtrl.clear();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: !_useOwnVehicle ? AppColors.primary.withOpacity(0.1) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: !_useOwnVehicle ? AppColors.primary : Colors.white12,
                width: !_useOwnVehicle ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(
                    !_useOwnVehicle ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: !_useOwnVehicle ? AppColors.primary : Colors.white38,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Text('Diğer Araç İçin',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ]),
                if (!_useOwnVehicle) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'Örn: 34ABC123',
                      hintStyle: TextStyle(color: Colors.white24, letterSpacing: 1),
                      prefixIcon: Icon(Icons.directions_car, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                    autofocus: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ] else ...[
        // Profilde araç yok, direkt yaz
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _plateCtrl,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              hintText: 'Örn: 34ABC123',
              hintStyle: TextStyle(color: Colors.white24, letterSpacing: 1),
              prefixIcon: Icon(Icons.directions_car, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // Profil sekmesine git
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profilinizden araç ekleyebilirsiniz'),
                backgroundColor: Colors.blue,
              ),
            );
          },
          child: const Text(
            '+ Profilime araç ekle',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ),
      ],

      const SizedBox(height: 28),
      SizedBox(
        width: double.infinity, height: 56,
        child: ElevatedButton(
          onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _saving
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _parking != null
                      ? 'Rezervasyon Yap — ${_parking!.location}'
                      : 'Rezervasyon Yap',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      ),
      const SizedBox(height: 30),
    ]),
  );

  // ── YARDIMCI WİDGET'LAR ───────────────────────────────────────────────────

  Widget _empty() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.local_parking_outlined, size: 64, color: Colors.white38),
    const SizedBox(height: 16),
    const Text('Park alanı bulunamadı',
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Sadece A Blok ve B Blok rezervasyona açıktır.',
        style: TextStyle(color: Colors.white54, fontSize: 13)),
    const SizedBox(height: 24),
    ElevatedButton.icon(
      onPressed: () { setState(() => _loading = true); _load(); },
      icon: const Icon(Icons.refresh), label: const Text('Yenile'),
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, foregroundColor: Colors.white),
    ),
  ]));

  Widget _label(String t) => Text(t,
      style: const TextStyle(color: Colors.white, fontSize: 15,
          fontWeight: FontWeight.w700, letterSpacing: 0.3));

  Widget _blockSelector() => Row(
    children: _parkings.map((p) {
      final sel = _parking?.id == p.id;
      // Dolu yer hesabı
      final dolu = p.totalSpots - p.availableSpots;
      return Expanded(
        child: GestureDetector(
          onTap: () async {
            setState(() { _parking = p; _spot = null; _occupied = []; });
            await _loadSpots(p.id);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: sel ? AppColors.primary : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: sel ? AppColors.primary : Colors.white12, width: 1.5),
            ),
            child: Column(children: [
              Icon(Icons.local_parking,
                  color: sel ? Colors.white : Colors.white38, size: 24),
              const SizedBox(height: 6),
              Text(p.location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 3),
              Text('${p.availableSpots} boş / ${p.totalSpots}',
                  style: TextStyle(
                      color: sel
                          ? Colors.white70
                          : Colors.greenAccent.withOpacity(0.8),
                      fontSize: 11)),
            ]),
          ),
        ),
      );
    }).toList(),
  );

  Widget _map() {
    final p = _parking!;
    final total = p.totalSpots > 0 ? p.totalSpots : 20;
    final avail = p.availableSpots.clamp(0, total);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${p.location} — Harita',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20)),
            child: Text('$avail / $total boş',
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.9),
          itemCount: total,
          itemBuilder: (_, i) {
            final occ = _occupied.contains(i);
            final sel = _spot == i;
            return GestureDetector(
              onTap: occ ? null : () => setState(() => _spot = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: occ
                      ? const Color(0xFF3D1A1A)
                      : sel
                          ? AppColors.primary
                          : const Color(0xFF1A2E1A),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: occ
                        ? Colors.red.shade900
                        : sel
                            ? AppColors.primary
                            : Colors.greenAccent.withOpacity(0.2),
                    width: sel ? 2 : 1,
                  ),
                  boxShadow: sel
                      ? [BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8)]
                      : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(
                    occ ? Icons.directions_car : Icons.directions_car_outlined,
                    size: 11,
                    color: occ
                        ? Colors.red.shade700
                        : sel
                            ? Colors.white
                            : Colors.greenAccent.withOpacity(0.5),
                  ),
                  const SizedBox(height: 2),
                  Text('${i + 1}',
                      style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: occ
                              ? Colors.red.shade700
                              : sel
                                  ? Colors.white
                                  : Colors.greenAccent.withOpacity(0.4))),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Row(children: [
          _leg(Colors.greenAccent, 'Boş'),
          const SizedBox(width: 16),
          _leg(Colors.red, 'Dolu'),
          const SizedBox(width: 16),
          _leg(AppColors.primary, 'Seçili'),
        ]),
      ]),
    );
  }

  Widget _leg(Color c, String l) => Row(children: [
    Container(
        width: 10, height: 10,
        decoration: BoxDecoration(
            color: c.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(l, style: const TextStyle(color: Colors.white38, fontSize: 11)),
  ]);

  Widget _datePicker() => GestureDetector(
    onTap: _pickDate,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(children: [
        const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
        const SizedBox(width: 12),
        Text(
          '${_date.day.toString().padLeft(2,'0')}.${_date.month.toString().padLeft(2,'0')}.${_date.year}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        const Spacer(),
        const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
      ]),
    ),
  );

  Widget _timeSlots() => Column(
    children: TimeSlot.values.map((s) {
      final sel = _slot == s;
      return GestureDetector(
        onTap: () => setState(() => _slot = s),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: sel ? AppColors.primary.withOpacity(0.15) : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: sel ? AppColors.primary : Colors.white12,
                width: sel ? 1.5 : 1),
          ),
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel ? AppColors.primary : Colors.transparent,
                border: Border.all(
                    color: sel ? AppColors.primary : Colors.white30, width: 2),
              ),
              child: sel
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.label,
                  style: TextStyle(
                      color: sel ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(s.hours,
                  style: TextStyle(
                      color: sel ? AppColors.primary : Colors.white30,
                      fontSize: 12)),
            ]),
            const Spacer(),
            if (s == TimeSlot.fullDay)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text('12 saat',
                    style: TextStyle(color: Colors.amber, fontSize: 10)),
              ),
          ]),
        ),
      );
    }).toList(),
  );
}
