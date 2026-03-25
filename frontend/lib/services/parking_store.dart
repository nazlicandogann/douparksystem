import '../models/backend/parking_api_model.dart';
import '../models/parking_spot_model.dart';
import 'api_service.dart';

class ParkingStore {
  static List<ParkingSpot> spots = [];
  static bool isLoading = false;
  static String? errorMessage;

  static Future<void> loadFromBackend() async {
    try {
      isLoading = true;
      errorMessage = null;

      final List<ParkingApiModel> parkings = await ApiService.getAllParkings();
      spots = _mapApiToUiSpots(parkings);
    } catch (e) {
      errorMessage = e.toString();
      spots = [];
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  static List<ParkingSpot> _mapApiToUiSpots(List<ParkingApiModel> parkings) {
    final List<ParkingSpot> mapped = [];

    for (final parking in parkings) {
      final int total = parking.totalSpots < 0 ? 0 : parking.totalSpots;
      final int available = parking.availableSpots < 0
          ? 0
          : (parking.availableSpots > total ? total : parking.availableSpots);

      final String prefix = _buildPrefix(parking.location);

      for (int i = 0; i < total; i++) {
        final bool isAvailable = i < available;

        mapped.add(
          ParkingSpot(
            id: (parking.id * 1000) + i + 1,
            parkingName: parking.location,
            code: '$prefix${i + 1}',
            status: isAvailable ? 'bos' : 'dolu',
          ),
        );
      }
    }

    return mapped;
  }

  static String _buildPrefix(String location) {
    final parts = location
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'P';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return parts.map((e) => e.substring(0, 1).toUpperCase()).join();
  }

  static void markSpotReserved(int spotId) {
    final index = spots.indexWhere((spot) => spot.id == spotId);
    if (index == -1) return;

    final current = spots[index];
    spots[index] = current.copyWith(status: 'rezerve');
  }

  static void markSpotAvailable(int spotId) {
    final index = spots.indexWhere((spot) => spot.id == spotId);
    if (index == -1) return;

    final current = spots[index];
    spots[index] = current.copyWith(status: 'bos');
  }

  static List<ParkingSpot> getByParkingName(String parkingName) {
    return spots.where((spot) => spot.parkingName == parkingName).toList();
  }

  static int get totalCount => spots.length;
  static int get availableCount => spots.where((s) => s.status == 'bos').length;
  static int get occupiedCount => spots.where((s) => s.status == 'dolu').length;
  static int get reservedCount => spots.where((s) => s.status == 'rezerve').length;

  // ESKİ EKRANLAR BOZULMASIN DİYE UYUMLULUK METHODLARI
  static int getAvailableCount(String parkingName) {
    return spots
        .where((s) => s.parkingName == parkingName && s.status == 'bos')
        .length;
  }

  static int getOccupiedCount(String parkingName) {
    return spots
        .where((s) => s.parkingName == parkingName && s.status == 'dolu')
        .length;
  }

  static int getReservedCount(String parkingName) {
    return spots
        .where((s) => s.parkingName == parkingName && s.status == 'rezerve')
        .length;
  }

  // ESKİ İSİMLERİ DE DESTEKLE
  static void reserveSpot(int spotId) {
    markSpotReserved(spotId);
  }

  static void freeSpot(dynamic spotId) {
    final int? parsedId = spotId is int ? spotId : int.tryParse(spotId.toString());
    if (parsedId == null) return;
    markSpotAvailable(parsedId);
  }
}