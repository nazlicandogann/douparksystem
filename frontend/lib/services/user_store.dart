class UserStore {
  static String fullName = '';
  static String email = '';
  static String phone = '';
  static String role = 'USER';
  static String userType = 'Standart Kullanıcı';
  static String savedCard = 'Henüz eklenmedi';
  static String? profileImagePath; // web'de base64, mobilde path
  static int reservationCount = 0;
  static double totalSpent = 0;

  static List<String> vehicles = [];

  static bool get isAdmin => role == 'ADMIN';

  // ── ROZET SİSTEMİ ───────────────────────────────────────────────────────
  static List<UserBadge> get earnedBadges {
    final List<UserBadge> badges = [];
    if (reservationCount >= 1)  badges.add(UserBadge.firstPark);
    if (reservationCount >= 5)  badges.add(UserBadge.regularUser);
    if (reservationCount >= 20) badges.add(UserBadge.vipParker);
    if (reservationCount >= 50) badges.add(UserBadge.campusLegend);
    if (totalSpent >= 100)      badges.add(UserBadge.generousWallet);
    if (totalSpent >= 500)      badges.add(UserBadge.goldWallet);
    return badges;
  }

  static List<UserBadge> get allBadges => UserBadge.values.toList();

  // ── SETTER'LAR ───────────────────────────────────────────────────────────
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
    profileImagePath = null;
    reservationCount = 0;
    totalSpent = 0;
  }

  static void addVehicle(String plate) {
    final formattedPlate = plate.trim().toUpperCase();
    if (formattedPlate.isEmpty) return;
    if (!vehicles.contains(formattedPlate)) vehicles.add(formattedPlate);
  }

  static void removeVehicle(String plate) => vehicles.remove(plate);

  static String get primaryVehicle {
    if (vehicles.isEmpty) return 'Araç yok';
    return vehicles.first;
  }
}

// ── ROZET MODELİ ─────────────────────────────────────────────────────────────
enum UserBadge {
  firstPark,
  regularUser,
  vipParker,
  campusLegend,
  generousWallet,
  goldWallet,
}

extension UserBadgeExtension on UserBadge {
  String get title {
    switch (this) {
      case UserBadge.firstPark:      return 'İlk Park';
      case UserBadge.regularUser:    return 'Düzenli Kullanıcı';
      case UserBadge.vipParker:      return 'VIP Parker';
      case UserBadge.campusLegend:   return 'Kampüs Efsanesi';
      case UserBadge.generousWallet: return 'Cömert Cüzdan';
      case UserBadge.goldWallet:     return 'Altın Cüzdan';
    }
  }

  String get description {
    switch (this) {
      case UserBadge.firstPark:      return 'İlk rezervasyonunu yaptın!';
      case UserBadge.regularUser:    return '5 rezervasyon tamamladın';
      case UserBadge.vipParker:      return '20 rezervasyon tamamladın';
      case UserBadge.campusLegend:   return '50 rezervasyon - Efsane oldun! Kampüsün Sefiri :)';
      case UserBadge.generousWallet: return '100 TL üzeri bakiye yükledin';
      case UserBadge.goldWallet:     return '500 TL üzeri bakiye yükledin';
    }
  }

  String get emoji {
    switch (this) {
      case UserBadge.firstPark:      return '🅿️';
      case UserBadge.regularUser:    return '⭐';
      case UserBadge.vipParker:      return '💎';
      case UserBadge.campusLegend:   return '🏆';
      case UserBadge.generousWallet: return '💰';
      case UserBadge.goldWallet:     return '🥇';
    }
  }

  int get requiredCount {
    switch (this) {
      case UserBadge.firstPark:      return 1;
      case UserBadge.regularUser:    return 5;
      case UserBadge.vipParker:      return 20;
      case UserBadge.campusLegend:   return 50;
      case UserBadge.generousWallet: return 0;
      case UserBadge.goldWallet:     return 0;
    }
  }
}
