import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';

class BookingModel {
  final String bookingId;
  final String userId;
  final String userName;
  final String userEmail;
  final String fieldId;
  final String fieldName;
  final DateTime date;
  final String timeSlot;
  final double basePrice;
  final double finalPrice;
  final String status;
  final String qrCodeData;
  final DateTime createdAt;
  final DateTime? checkedInAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  BookingModel({
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.fieldId,
    required this.fieldName,
    required this.date,
    required this.timeSlot,
    required this.basePrice,
    required this.finalPrice,
    required this.status,
    required this.qrCodeData,
    required this.createdAt,
    this.checkedInAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
  });

  bool get isWeekend => AppConstants.isWeekend(date);
  bool get isPending => status == AppConstants.statusPending;
  bool get isConfirmed => status == AppConstants.statusConfirmed;
  bool get isCheckedIn => status == AppConstants.statusCheckedIn;
  bool get isCompleted => status == AppConstants.statusCompleted;
  bool get isCancelled => status == AppConstants.statusCancelled;

  bool get canCheckIn {
    if (!isConfirmed) return false;
    final now = DateTime.now();
    final bookingDateTime = _getBookingStartTime();
    // Can check in 30 minutes before until end of slot
    final checkInStart = bookingDateTime.subtract(const Duration(minutes: 30));
    final checkInEnd = bookingDateTime.add(const Duration(hours: 1));
    return now.isAfter(checkInStart) && now.isBefore(checkInEnd);
  }

  DateTime _getBookingStartTime() {
    final timeParts = timeSlot.split(' - ')[0].split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      bookingId: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      fieldId: data['fieldId'] ?? '',
      fieldName: data['fieldName'] ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      finalPrice: (data['finalPrice'] ?? 0).toDouble(),
      status: data['status'] ?? AppConstants.statusPending,
      qrCodeData: data['qrCodeData'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      checkedInAt: (data['checkedInAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      cancelReason: data['cancelReason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'fieldId': fieldId,
      'fieldName': fieldName,
      'date': Timestamp.fromDate(date),
      'timeSlot': timeSlot,
      'basePrice': basePrice,
      'finalPrice': finalPrice,
      'status': status,
      'qrCodeData': qrCodeData,
      'createdAt': Timestamp.fromDate(createdAt),
      'checkedInAt': checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'cancelReason': cancelReason,
    };
  }

  BookingModel copyWith({
    String? bookingId,
    String? userId,
    String? userName,
    String? userEmail,
    String? fieldId,
    String? fieldName,
    DateTime? date,
    String? timeSlot,
    double? basePrice,
    double? finalPrice,
    String? status,
    String? qrCodeData,
    DateTime? createdAt,
    DateTime? checkedInAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelReason,
  }) {
    return BookingModel(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      basePrice: basePrice ?? this.basePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      createdAt: createdAt ?? this.createdAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
    );
  }
}
