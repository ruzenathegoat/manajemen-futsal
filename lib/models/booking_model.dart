class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String fieldId;
  final String fieldName;
  final DateTime date; // Hanya tanggal (tanpa jam)
  final int timeSlot; // Jam booking mulai (misal: 10, 11, ... 21)
  final int duration; // Durasi dalam jam (default: 1)
  final int totalCost;
  final String status; // 'booked', 'completed', 'cancelled', 'approved'
  final String qrCode; // String unik untuk QR

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.fieldId,
    required this.fieldName,
    required this.date,
    required this.timeSlot,
    this.duration = 1, // Default 1 jam
    required this.totalCost,
    this.status = 'booked',
    required this.qrCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'fieldId': fieldId,
      'fieldName': fieldName,
      // Simpan tanggal sebagai string YYYY-MM-DD agar mudah di-query
      'date': date.toIso8601String().split('T')[0], 
      'timeSlot': timeSlot,
      'duration': duration,
      'totalCost': totalCost,
      'status': status,
      'qrCode': qrCode,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> data, String id) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      fieldId: data['fieldId'] ?? '',
      fieldName: data['fieldName'] ?? '',
      date: DateTime.parse(data['date']), // Parsing string YYYY-MM-DD kembali ke DateTime
      timeSlot: data['timeSlot'] ?? 0,
      duration: data['duration'] ?? 1,
      totalCost: data['totalCost'] ?? 0,
      status: data['status'] ?? 'booked',
      qrCode: data['qrCode'] ?? '',
    );
  }

  // Helper method to get all time slots covered by this booking
  List<int> get timeSlots {
    return List.generate(duration, (index) => timeSlot + index);
  }
}