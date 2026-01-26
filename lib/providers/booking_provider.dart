import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/field_model.dart';

/// BookingProvider manages real-time booking state to prevent double-booking
/// Uses Firestore streams for live synchronization across all users
class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Current field being viewed
  FieldModel? _currentField;
  DateTime? _selectedDate;

  // Real-time booked slots for current field/date
  List<int> _bookedSlots = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Stream subscription for real-time updates
  StreamSubscription<QuerySnapshot>? _bookingSlotsSubscription;

  // Getters
  FieldModel? get currentField => _currentField;
  DateTime? get selectedDate => _selectedDate;
  List<int> get bookedSlots => List.unmodifiable(_bookedSlots);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize real-time listener for a specific field and date
  void startListening(FieldModel field, DateTime date) {
    // Cancel existing subscription
    _bookingSlotsSubscription?.cancel();

    _currentField = field;
    _selectedDate = date;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final dateString = date.toIso8601String().split('T')[0];

    // Setup real-time stream listener
    _bookingSlotsSubscription = _db
        .collection('bookings')
        .where('fieldId', isEqualTo: field.id)
        .where('date', isEqualTo: dateString)
        .where('status', whereIn: ['booked', 'approved'])
        .snapshots()
        .listen(
      (snapshot) {
        _bookedSlots = _extractBookedSlots(snapshot.docs);
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading booking data: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Extract all booked time slots from documents (considering duration)
  List<int> _extractBookedSlots(List<QueryDocumentSnapshot> docs) {
    final Set<int> slots = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final startSlot = data['timeSlot'] as int;
      final duration = data['duration'] as int? ?? 1;

      for (int i = 0; i < duration; i++) {
        slots.add(startSlot + i);
      }
    }

    return slots.toList()..sort();
  }

  /// Change selected date (triggers new stream subscription)
  void changeDate(DateTime newDate) {
    if (_currentField != null) {
      startListening(_currentField!, newDate);
    }
  }

  /// Create booking with validation to prevent double-booking
  /// Uses optimistic locking with real-time data + server-side re-validation
  Future<BookingModel> createBookingWithValidation({
    required String userId,
    required String userName,
    required FieldModel field,
    required DateTime date,
    required int timeSlot,
    required int duration,
    required int totalCost,
  }) async {
    final dateString = date.toIso8601String().split('T')[0];
    final qrCode = 'BK-${DateTime.now().millisecondsSinceEpoch}-$userId';

    // Step 1: Validate against real-time cached data (optimistic check)
    for (int i = 0; i < duration; i++) {
      final requestedSlot = timeSlot + i;
      if (_bookedSlots.contains(requestedSlot)) {
        throw BookingConflictException(
          'Slot ${requestedSlot}:00 sudah dipesan. Silakan pilih waktu lain.',
        );
      }
      if (requestedSlot >= 22) {
        throw BookingConflictException(
          'Booking melampaui jam operasional (max 22:00).',
        );
      }
    }

    // Step 2: Re-fetch and validate from server (pessimistic check)
    final serverCheck = await _db
        .collection('bookings')
        .where('fieldId', isEqualTo: field.id)
        .where('date', isEqualTo: dateString)
        .where('status', whereIn: ['booked', 'approved'])
        .get();

    final Set<int> serverSlots = {};
    for (var doc in serverCheck.docs) {
      final data = doc.data();
      final existingStart = data['timeSlot'] as int;
      final existingDuration = data['duration'] as int? ?? 1;

      for (int i = 0; i < existingDuration; i++) {
        serverSlots.add(existingStart + i);
      }
    }

    // Validate against server data
    for (int i = 0; i < duration; i++) {
      final requestedSlot = timeSlot + i;
      if (serverSlots.contains(requestedSlot)) {
        // Update local cache
        _bookedSlots = serverSlots.toList()..sort();
        notifyListeners();
        
        throw BookingConflictException(
          'Slot ${requestedSlot}:00 baru saja dipesan user lain. Silakan pilih waktu lain.',
        );
      }
    }

    // Step 3: Create the booking document
    final bookingRef = _db.collection('bookings').doc();
    final booking = BookingModel(
      id: bookingRef.id,
      userId: userId,
      userName: userName,
      fieldId: field.id,
      fieldName: field.name,
      date: date,
      timeSlot: timeSlot,
      duration: duration,
      totalCost: totalCost,
      qrCode: qrCode,
    );

    await bookingRef.set({
      ...booking.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return booking;
  }

  /// Check if specific slots are available (for UI validation)
  bool areSlotsAvailable(int startSlot, int duration) {
    for (int i = 0; i < duration; i++) {
      final slot = startSlot + i;
      if (_bookedSlots.contains(slot) || slot >= 22) {
        return false;
      }
    }
    return true;
  }

  /// Clean up subscriptions
  void stopListening() {
    _bookingSlotsSubscription?.cancel();
    _bookingSlotsSubscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

/// Custom exception for booking conflicts
class BookingConflictException implements Exception {
  final String message;
  BookingConflictException(this.message);

  @override
  String toString() => message;
}
