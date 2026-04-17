class ParkingApiModel {
  final int id;
  final String location;
  final int totalSpots;
  final int availableSpots;

  ParkingApiModel({
    required this.id,
    required this.location,
    required this.totalSpots,
    required this.availableSpots,
  });

  factory ParkingApiModel.fromJson(Map<String, dynamic> json) {
    return ParkingApiModel(
      id: json['id'],
      location: json['location'],
      totalSpots: json['totalSpots'],
      availableSpots: json['availableSpots'],
    );
  }
}