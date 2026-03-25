class ParkingApiModel {
  final int id;
  final String location;
  final int totalSpots;
  final int availableSpots;

  const ParkingApiModel({
    required this.id,
    required this.location,
    required this.totalSpots,
    required this.availableSpots,
  });

  factory ParkingApiModel.fromJson(Map<String, dynamic> json) {
    return ParkingApiModel(
      id: json['id'] ?? 0,
      location: json['location'] ?? '',
      totalSpots: json['totalSpots'] ?? 0,
      availableSpots: json['availableSpots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
    };
  }

  @override
  String toString() {
    return 'ParkingApiModel(id: $id, location: $location, totalSpots: $totalSpots, availableSpots: $availableSpots)';
  }
}