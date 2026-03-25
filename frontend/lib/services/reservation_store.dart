import '../models/reservation_model.dart';

class ReservationStore {
  static final List<Reservation> _reservations = [];

  static List<Reservation> get reservations => _reservations;

  static void addReservation(Reservation reservation) {
    _reservations.add(reservation);
  }

  static void removeReservation(String reservationId) {
    _reservations.removeWhere((r) => r.id == reservationId);
  }

  static Reservation? getReservationById(String id) {
    try {
      return _reservations.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}