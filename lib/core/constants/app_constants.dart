// App Constants for Futsal Field Reservation System

class AppConstants {
  // App Info
  static const String appName = 'FutsalPro';
  static const String appVersion = '1.0.0';
  
  // Business Hours
  static const int openingHour = 10; // 10:00 WIB
  static const int closingHour = 21; // 21:00 WIB
  static const int slotDurationMinutes = 60; // 1 hour per slot
  
  // Pricing
  static const double weekendSurchargePercent = 0.10; // 10% weekend surcharge
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String fieldsCollection = 'fields';
  static const String bookingsCollection = 'bookings';
  
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';
  
  // Booking Status
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusCheckedIn = 'checked_in';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  
  // Time Slots (10:00 - 21:00)
  static List<String> get timeSlots {
    List<String> slots = [];
    for (int hour = openingHour; hour < closingHour; hour++) {
      String startTime = '${hour.toString().padLeft(2, '0')}:00';
      String endTime = '${(hour + 1).toString().padLeft(2, '0')}:00';
      slots.add('$startTime - $endTime');
    }
    return slots;
  }
  
  // Weekend days (Saturday = 6, Sunday = 7)
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }
  
  // Calculate price with weekend surcharge
  static double calculatePrice(double basePrice, DateTime date) {
    if (isWeekend(date)) {
      return basePrice * (1 + weekendSurchargePercent);
    }
    return basePrice;
  }
}
