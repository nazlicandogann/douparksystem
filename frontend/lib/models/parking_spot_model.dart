class ParkingSpot {
  final int id;
  final String parkingName;
  final String code;
  final String status; // bos, dolu, rezerve

  const ParkingSpot({
    required this.id,
    required this.parkingName,
    required this.code,
    required this.status,
  });

  bool get isAvailable => status == 'bos';
  bool get isOccupied => status == 'dolu';
  bool get isReserved => status == 'rezerve';

  ParkingSpot copyWith({
    int? id,
    String? parkingName,
    String? code,
    String? status,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      parkingName: parkingName ?? this.parkingName,
      code: code ?? this.code,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ParkingSpot(id: $id, parkingName: $parkingName, code: $code, status: $status)';
  }
}