class Reservation {
  final String id;
  final String parkingName;
  final String parkingSpotId;
  final String spotCode;
  final String plate;
  final String date;
  final String startTime;
  final String endTime;
  String status;

  Reservation({
    required this.id,
    required this.parkingName,
    required this.parkingSpotId,
    required this.spotCode,
    required this.plate,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'Aktif',
  });

  String get floor => parkingName;
}