import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/field_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FIELD METHODS (ADMIN) ---

  // 1. Get All Fields (Stream agar realtime update)
  Stream<List<FieldModel>> getFields() {
    return _db.collection('fields').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return FieldModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. Add Field
  Future<void> addField(FieldModel field) async {
    // Kita gunakan .add() agar ID digenerate otomatis oleh Firestore
    await _db.collection('fields').add({
      ...field.toMap(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 3. Update Field
  Future<void> updateField(FieldModel field) async {
    await _db.collection('fields').doc(field.id).update(field.toMap());
  }

  // 4. Delete Field
  Future<void> deleteField(String fieldId) async {
    await _db.collection('fields').doc(fieldId).delete();
  }

  // --- BOOKING METHODS ---

  // 1. Create Booking
  Future<void> createBooking(BookingModel booking) async {
    await _db.collection('bookings').add(booking.toMap());
  }

  // 2. Get Booked Slots (Cek jadwal yang sudah terisi pada tanggal tertentu)
  // Returns all time slots that are booked (considering duration)
  Future<List<int>> getBookedSlots(String fieldId, DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0]; // Format YYYY-MM-DD
    
    final snapshot = await _db.collection('bookings')
        .where('fieldId', isEqualTo: fieldId)
        .where('date', isEqualTo: dateString)
        .where('status', whereIn: ['booked', 'approved']) // Include approved bookings
        .get();

    // Ambil semua jam yang sudah di-booking (termasuk durasi)
    List<int> bookedSlots = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final startSlot = data['timeSlot'] as int;
      final duration = data['duration'] as int? ?? 1;
      // Tambahkan semua slot yang ter-cover oleh booking ini
      for (int i = 0; i < duration; i++) {
        if (!bookedSlots.contains(startSlot + i)) {
          bookedSlots.add(startSlot + i);
        }
      }
    }
    return bookedSlots;
  }

  // Get reservation data for a field (all bookings with dates and times)
  Future<Map<String, List<int>>> getFieldReservations(String fieldId, {DateTime? startDate, DateTime? endDate}) async {
    // Get all bookings for this field with valid status
    QuerySnapshot snapshot;
    
    if (startDate != null && endDate != null) {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];
      
      snapshot = await _db.collection('bookings')
          .where('fieldId', isEqualTo: fieldId)
          .where('date', isGreaterThanOrEqualTo: startDateStr)
          .where('date', isLessThanOrEqualTo: endDateStr)
          .get();
    } else {
      snapshot = await _db.collection('bookings')
          .where('fieldId', isEqualTo: fieldId)
          .get();
    }
    
    // Group by date and filter by status
    Map<String, List<int>> reservations = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String? ?? 'booked';
      
      // Only include booked and approved bookings
      if (status == 'booked' || status == 'approved') {
        final date = data['date'] as String;
        final startSlot = data['timeSlot'] as int;
        final duration = data['duration'] as int? ?? 1;
        
        if (!reservations.containsKey(date)) {
          reservations[date] = [];
        }
        
        // Add all time slots for this booking
        for (int i = 0; i < duration; i++) {
          if (!reservations[date]!.contains(startSlot + i)) {
            reservations[date]!.add(startSlot + i);
          }
        }
      }
    }
    
    return reservations;
  }

  // 3. Get User Bookings (Untuk menu "Pesanan Saya")
  Stream<List<BookingModel>> getUserBookings(String uid) {
    return _db.collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true) // Terbaru di atas
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }
  // 4. Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }

  // 5. Update Status (Untuk Admin saat Scan QR)
  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': newStatus,
    });
  }
  
  // 6. Find Booking by QR Code (Untuk Admin Scan)
  Future<BookingModel?> getBookingByQr(String qrCode) async {
    final snapshot = await _db.collection('bookings')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();
        
    if (snapshot.docs.isNotEmpty) {
      return BookingModel.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
    }
    return null;
  }

  // 7. Get All Bookings (Untuk Admin Reports)
  Stream<List<BookingModel>> getAllBookings() {
    return _db.collection('bookings')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          final bookings = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort by date first, then by createdAt for same date
          bookings.sort((a, b) {
            final dateCompare = b.date.compareTo(a.date);
            if (dateCompare != 0) return dateCompare;
            // If dates are equal, we can't sort by createdAt from model
            // So we'll just return 0 (maintain order from Firestore)
            return 0;
          });
          return bookings;
        });
  }

  // 8. Approve Booking (Admin)
  Future<void> approveBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'approved',
      'approvedAt': DateTime.now().toIso8601String(),
    });
  }

  // 9. Get Analytics Data
  Future<Map<String, dynamic>> getAnalyticsData({DateTime? startDate, DateTime? endDate}) async {
    try {
      QuerySnapshot snapshot;
      
      if (startDate != null && endDate != null) {
        final startDateStr = startDate.toIso8601String().split('T')[0];
        final endDateStr = endDate.toIso8601String().split('T')[0];
        
        snapshot = await _db.collection('bookings')
            .where('date', isGreaterThanOrEqualTo: startDateStr)
            .where('date', isLessThanOrEqualTo: endDateStr)
            .get();
      } else if (startDate != null) {
        final startDateStr = startDate.toIso8601String().split('T')[0];
        snapshot = await _db.collection('bookings')
            .where('date', isGreaterThanOrEqualTo: startDateStr)
            .get();
      } else if (endDate != null) {
        final endDateStr = endDate.toIso8601String().split('T')[0];
        snapshot = await _db.collection('bookings')
            .where('date', isLessThanOrEqualTo: endDateStr)
            .get();
      } else {
        snapshot = await _db.collection('bookings').get();
      }
      
      int totalBookings = 0;
      int totalRevenue = 0;
      Map<String, int> dailyBookings = {}; // date -> count
      Map<String, int> dailyRevenue = {}; // date -> revenue
      Map<String, int> hourlyBookings = {}; // hour -> count (as string keys)
      Map<String, int> weeklyBookings = {}; // week -> count
      Map<String, int> weeklyRevenue = {}; // week -> revenue
      Map<String, int> monthlyBookings = {}; // month -> count
      Map<String, int> monthlyRevenue = {}; // month -> revenue
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? 'booked';
        
        // Only count non-cancelled bookings
        if (status != 'cancelled') {
          totalBookings++;
          final cost = data['totalCost'] as int? ?? 0;
          totalRevenue += cost;
          
          final date = data['date'] as String;
          final timeSlot = data['timeSlot'] as int;
          final duration = data['duration'] as int? ?? 1;
          
          // Daily stats
          dailyBookings[date] = (dailyBookings[date] ?? 0) + 1;
          dailyRevenue[date] = (dailyRevenue[date] ?? 0) + cost;
          
          // Hourly stats (for heatmap)
          for (int i = 0; i < duration; i++) {
            final hour = timeSlot + i;
            final hourKey = hour.toString();
            hourlyBookings[hourKey] = (hourlyBookings[hourKey] ?? 0) + 1;
          }
          
          // Weekly stats
          final dateTime = DateTime.parse(date);
          final weekKey = '${dateTime.year}-W${_getWeekNumber(dateTime)}';
          weeklyBookings[weekKey] = (weeklyBookings[weekKey] ?? 0) + 1;
          weeklyRevenue[weekKey] = (weeklyRevenue[weekKey] ?? 0) + cost;
          
          // Monthly stats
          final monthKey = '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}';
          monthlyBookings[monthKey] = (monthlyBookings[monthKey] ?? 0) + 1;
          monthlyRevenue[monthKey] = (monthlyRevenue[monthKey] ?? 0) + cost;
        }
      }
      
      return {
        'totalBookings': totalBookings,
        'totalRevenue': totalRevenue,
        'dailyBookings': dailyBookings,
        'dailyRevenue': dailyRevenue,
        'hourlyBookings': hourlyBookings,
        'weeklyBookings': weeklyBookings,
        'weeklyRevenue': weeklyRevenue,
        'monthlyBookings': monthlyBookings,
        'monthlyRevenue': monthlyRevenue,
      };
    } catch (e) {
      // Return empty data structure on error
      return {
        'totalBookings': 0,
        'totalRevenue': 0,
        'dailyBookings': <String, int>{},
        'dailyRevenue': <String, int>{},
        'hourlyBookings': <String, int>{},
        'weeklyBookings': <String, int>{},
        'weeklyRevenue': <String, int>{},
        'monthlyBookings': <String, int>{},
        'monthlyRevenue': <String, int>{},
      };
    }
  }

  // Helper to get week number (ISO 8601 week)
  int _getWeekNumber(DateTime date) {
    // Get the first Thursday of the year (ISO week starts on Monday)
    final jan4 = DateTime(date.year, 1, 4);
    final jan4Weekday = jan4.weekday; // 1 = Monday, 7 = Sunday
    final firstMonday = jan4.subtract(Duration(days: jan4Weekday - 1));
    
    // Calculate days from first Monday
    final daysSinceFirstMonday = date.difference(firstMonday).inDays;
    
    // If date is before first Monday, it belongs to previous year's last week
    if (daysSinceFirstMonday < 0) {
      return _getWeekNumber(DateTime(date.year - 1, 12, 31));
    }
    
    // Calculate week number (1-based)
    final weekNumber = (daysSinceFirstMonday / 7).floor() + 1;
    return weekNumber;
  }

  // 10. Update User Profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    await _db.collection('users').doc(uid).update(updates);
  }

  // ============== USER MANAGEMENT (ADMIN) ==============

  // 11. Get All Users (Stream for real-time updates)
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _db.collection('users').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    });
  }

  // 12. Get User by ID
  Future<Map<String, dynamic>?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      data['uid'] = doc.id;
      return data;
    }
    return null;
  }

  // 13. Update User (Admin)
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    updates['updatedAt'] = DateTime.now().toIso8601String();
    await _db.collection('users').doc(uid).update(updates);
  }

  // 14. Delete User (Admin) - Only deletes Firestore data, not Auth
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // 15. Create User (Admin) - Creates Firestore user document
  Future<void> createUserDocument(String uid, Map<String, dynamic> userData) async {
    userData['createdAt'] = DateTime.now().toIso8601String();
    await _db.collection('users').doc(uid).set(userData);
  }

  // 16. Get User Statistics
  Future<Map<String, int>> getUserStats() async {
    final snapshot = await _db.collection('users').get();
    
    int totalUsers = 0;
    int adminCount = 0;
    int userCount = 0;

    for (var doc in snapshot.docs) {
      totalUsers++;
      final role = doc.data()['role'] as String? ?? 'user';
      if (role == 'admin') {
        adminCount++;
      } else {
        userCount++;
      }
    }

    return {
      'total': totalUsers,
      'admin': adminCount,
      'user': userCount,
    };
  }

  // 17. Get User Booking Count
  Future<int> getUserBookingCount(String uid) async {
    final snapshot = await _db.collection('bookings')
        .where('userId', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }

  // 18. Check if email exists
  Future<bool> emailExists(String email) async {
    final snapshot = await _db.collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}