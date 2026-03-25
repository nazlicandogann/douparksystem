class UserStore {
  static String fullName = 'Ceren İmat';
  static String email = 'ceren@example.com';
  static String phone = '+90 5xx xxx xx xx';
  static String userType = 'Standart Kullanıcı';
  static String savedCard = 'Henüz eklenmedi';

  static List<String> vehicles = ['34 ABC 123'];

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