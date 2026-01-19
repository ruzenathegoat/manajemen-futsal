import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/field_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _bookingService = BookingService();

  List<BookingModel> _userBookings = [];
  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> _allBookings = [];
  List<String> _bookedSlots = [];
  Map<String, dynamic>? _statistics;
  
  bool _isLoading = false;
  String? _error;

  // Booking form state
  FieldModel? _selectedField;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  List<BookingModel> get userBookings => _userBookings;
  List<BookingModel> get upcomingBookings => _upcomingBookings;
  List<BookingModel> get allBookings => _allBookings;
  List<String> get bookedSlots => _bookedSlots;
  Map<String, dynamic>? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FieldModel? get selectedField => _selectedField;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;

  // Subscribe to user bookings
  void subscribeToUserBookings(String userId) {
    _bookingService.getUserBookings(userId).listen((bookings) {
      _userBookings = bookings;
      notifyListeners();
    });

    _bookingService.getUpcomingBookings(userId).listen((bookings) {
      _upcomingBookings = bookings;
      notifyListeners();
    });
  }

  // Subscribe to all bookings (admin)
  void subscribeToAllBookings() {
    _bookingService.getAllBookings().listen((bookings) {
      _allBookings = bookings;
      notifyListeners();
    });
  }

  // Stream bookings by date (admin calendar)
  Stream<List<BookingModel>> streamBookingsByDate(DateTime date) {
    return _bookingService.getBookingsByDate(date);
  }

  // Set selected field
  void setSelectedField(FieldModel? field) {
    _selectedField = field;
    _selectedTimeSlot = null; // Reset time slot when field changes
    notifyListeners();
  }

  // Set selected date and load booked slots
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    _selectedTimeSlot = null;
    notifyListeners();

    if (_selectedField != null) {
      await loadBookedSlots(_selectedField!.fieldId, date);
    }
  }

  // Set selected time slot
  void setSelectedTimeSlot(String? timeSlot) {
    _selectedTimeSlot = timeSlot;
    notifyListeners();
  }

  // Load booked slots for a field on a specific date
  Future<void> loadBookedSlots(String fieldId, DateTime date) async {
    try {
      _bookedSlots = await _bookingService.getBookedSlots(
        fieldId: fieldId,
        date: date,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Create booking
  Future<BookingModel?> createBooking(UserModel user) async {
    if (_selectedField == null || _selectedDate == null || _selectedTimeSlot == null) {
      _error = 'Silakan pilih lapangan, tanggal, dan waktu';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await _bookingService.createBooking(
        user: user,
        field: _selectedField!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
      );

      _isLoading = false;
      clearBookingForm();
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update booking status
  Future<bool> updateBookingStatus({
    required String bookingId,
    required String status,
    String? cancelReason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingService.updateBookingStatus(
        bookingId: bookingId,
        status: status,
        cancelReason: cancelReason,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check-in via QR code
  Future<BookingModel?> checkInWithQR(String qrCodeData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booking = await _bookingService.checkInBooking(qrCodeData);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      return await _bookingService.getBookingById(bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Load statistics
  Future<void> loadStatistics({DateTime? startDate, DateTime? endDate}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _statistics = await _bookingService.getBookingStatistics(
        startDate: startDate,
        endDate: endDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear booking form
  void clearBookingForm() {
    _selectedField = null;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _bookedSlots = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
