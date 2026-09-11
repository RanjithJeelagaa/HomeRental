class BookingModel {
  final String id;
  final String houseId;
  final String visitorId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;

  BookingModel({
    required this.id,
    required this.houseId,
    required this.visitorId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      houseId: map['houseId'] ?? '',
      visitorId: map['visitorId'] ?? '',
      startDate: (map['startDate'] is Timestamp)
          ? (map['startDate'] as Timestamp).toDate()
          : DateTime.parse(map['startDate']),
      endDate: (map['endDate'] is Timestamp)
          ? (map['endDate'] as Timestamp).toDate()
          : DateTime.parse(map['endDate']),
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'houseId': houseId,
      'visitorId': visitorId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
    };
  }
}
