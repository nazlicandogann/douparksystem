class UserStore {
  static String fullName = '';
  static String email = '';
  static String phone = '';
  static String role = 'USER';
  static String userType = 'Standart Kullanıcı';
  static String savedCard = 'Henüz eklenmedi';

  static List<String> vehicles = [];

  static bool get isAdmin => role == 'ADMIN';

  static void setFromLogin({required String name, required String userEmail, String userRole = 'USER'}) {
    fullName = name;
    email = userEmail;
    role = userRole;
  }

  static void clear() {
    fullName = '';
    email = '';
    phone = '';
    role = 'USER';
    vehicles = [];
  }

  static void addVehicle(String plate) {
    final formattedPlate = plate.trim().toUpperCase();
    if (formattedPlate.isEmpty) return;
    if (!vehicles.contains(formattedPlate)) {
      vehicles.add(formattedPlate);
    }
  }

  static void removeVehicle(String plate) {
    vehicles.remove(plate);
  }

  static String get primaryVehicle {
    if (vehicles.isEmpty) return 'Araç yok';
    return vehicles.first;
  }
}
