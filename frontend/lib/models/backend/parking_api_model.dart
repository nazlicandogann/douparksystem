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
      id:             (json['id']             as num?)?.toInt() ?? 0,
      location:        json['parkingName']?.toString() ??
                       json['location']?.toString() ??
                       'Bilinmeyen Blok',
      totalSpots:     (json['totalSpots']     as num?)?.toInt() ?? 0,
      availableSpots: (json['availableSpots'] as num?)?.toInt() ?? 0,
    );
  }
}
