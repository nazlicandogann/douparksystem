class UserStore {
  static String fullName = '';
  static String email = '';
  static String phone = '';
  static String userType = 'Standart Kullanıcı';
  static String savedCard = 'Henüz eklenmedi';

  static List<String> vehicles = [];

  // Login sonrası backend'den gelen bilgilerle doldur
  static void setFromLogin({required String name, required String userEmail}) {
    fullName = name;
    email = userEmail;
  }

  static void clear() {
    fullName = '';
    email = '';
    phone = '';
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
