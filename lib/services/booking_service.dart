import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/booking_model.dart';
import '../models/field_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_formatter.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create a new booking
  Future<BookingModel> createBooking({
    required UserModel user,
    required FieldModel field,
    required DateTime date,
    required String timeSlot,
  }) async {
    // Check if slot is available
    final isAvailable = await checkSlotAvailability(
      fieldId: field.fieldId,
      date: date,
      timeSlot: timeSlot,
    );

    if (!isAvailable) {
      throw 'Slot waktu tidak tersedia';
    }

    // Calculate price
    final basePrice = field.basePrice;
    final finalPrice = AppConstants.calculatePrice(basePrice, date);

    // Generate QR code data
    final bookingId = _uuid.v4();
    final qrCodeData = 'FUTSAL-$bookingId';

    final booking = BookingModel(
      bookingId: bookingId,
      userId: user.uid,
      userName: user.name,
      userEmail: user.email,
      fieldId: field.fieldId,
      fieldName: field.name,
      date: date,
      timeSlot: timeSlot,
      basePrice: basePrice,
      finalPrice: finalPrice,
      status: AppConstants.statusConfirmed,
      qrCodeData: qrCodeData,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .set(booking.toFirestore());

    return booking;
  }

  // Check slot availability
  Future<bool> checkSlotAvailability({
    required String fieldId,
    required DateTime date,
    required String timeSlot,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('fieldId', isEqualTo: fieldId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('timeSlot', isEqualTo: timeSlot)
        .where('status', whereIn: [
          AppConstants.statusPending,
          AppConstants.statusConfirmed,
          AppConstants.statusCheckedIn,
        ])
        .get();

    return query.docs.isEmpty;
  }

  // Get booked slots for a field on a specific date
  Future<List<String>> getBookedSlots({
    required String fieldId,
    required DateTime date,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final query = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('fieldId', isEqualTo: fieldId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .where('status', whereIn: [
          AppConstants.statusPending,
          AppConstants.statusConfirmed,
          AppConstants.statusCheckedIn,
        ])
        .get();

    return query.docs.map((doc) => doc.data()['timeSlot'] as String).toList();
  }

  // Get user bookings
  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get upcoming bookings for user
  Stream<List<BookingModel>> getUpcomingBookings(String userId) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(today))
        .where('status', whereIn: [
          AppConstants.statusConfirmed,
          AppConstants.statusCheckedIn,
        ])
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get all bookings (admin)
  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get bookings for a specific date (admin calendar view)
  Stream<List<BookingModel>> getBookingsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromFirestore(doc))
            .toList());
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    final doc = await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .get();

    if (doc.exists) {
      return BookingModel.fromFirestore(doc);
    }
    return null;
  }

  // Get booking by QR code
  Future<BookingModel?> getBookingByQR(String qrCodeData) async {
    final query = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('qrCodeData', isEqualTo: qrCodeData)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return BookingModel.fromFirestore(query.docs.first);
    }
    return null;
  }

  // Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String? cancelReason,
  }) async {
    final Map<String, dynamic> updates = {'status': status};

    switch (status) {
      case 'checked_in':
        updates['checkedInAt'] = Timestamp.now();
        break;
      case 'completed':
        updates['completedAt'] = Timestamp.now();
        break;
      case 'cancelled':
        updates['cancelledAt'] = Timestamp.now();
        if (cancelReason != null) {
          updates['cancelReason'] = cancelReason;
        }
        break;
    }

    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update(updates);
  }

  // Check-in booking via QR
  Future<BookingModel> checkInBooking(String qrCodeData) async {
    final booking = await getBookingByQR(qrCodeData);

    if (booking == null) {
      throw 'Booking tidak ditemukan';
    }

    if (booking.isCancelled) {
      throw 'Booking telah dibatalkan';
    }

    if (booking.isCheckedIn || booking.isCompleted) {
      throw 'Booking sudah di check-in';
    }

    if (!booking.canCheckIn) {
      throw 'Check-in hanya dapat dilakukan 30 menit sebelum hingga akhir jadwal';
    }

    await updateBookingStatus(
      bookingId: booking.bookingId,
      status: AppConstants.statusCheckedIn,
    );

    return booking.copyWith(
      status: AppConstants.statusCheckedIn,
      checkedInAt: DateTime.now(),
    );
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore.collection(AppConstants.bookingsCollection);

    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();
    final bookings = snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();

    int totalBookings = bookings.length;
    int completedBookings = bookings.where((b) => b.isCompleted || b.isCheckedIn).length;
    int cancelledBookings = bookings.where((b) => b.isCancelled).length;
    double totalRevenue = bookings
        .where((b) => !b.isCancelled)
        .fold(0.0, (total, b) => total + b.finalPrice);

    // Calculate bookings by day
    Map<String, int> bookingsByDay = {};
    for (var booking in bookings.where((b) => !b.isCancelled)) {
      final dayKey = DateFormatter.getDayName(booking.date.weekday);
      bookingsByDay[dayKey] = (bookingsByDay[dayKey] ?? 0) + 1;
    }

    // Calculate bookings by hour
    Map<int, int> bookingsByHour = {};
    for (var booking in bookings.where((b) => !b.isCancelled)) {
      final hour = int.parse(booking.timeSlot.split(':')[0]);
      bookingsByHour[hour] = (bookingsByHour[hour] ?? 0) + 1;
    }

    // Weekend vs Weekday
    int weekendBookings = bookings.where((b) => !b.isCancelled && b.isWeekend).length;
    int weekdayBookings = bookings.where((b) => !b.isCancelled && !b.isWeekend).length;

    return {
      'totalBookings': totalBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
      'bookingsByDay': bookingsByDay,
      'bookingsByHour': bookingsByHour,
      'weekendBookings': weekendBookings,
      'weekdayBookings': weekdayBookings,
    };
  }
}
