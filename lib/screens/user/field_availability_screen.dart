import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../models/field_model.dart';
import '../../providers/booking_provider.dart';
import '../../services/firestore_service.dart';

class FieldAvailabilityScreen extends StatefulWidget {
  final FieldModel field;
  const FieldAvailabilityScreen({super.key, required this.field});

  @override
  State<FieldAvailabilityScreen> createState() =>
      _FieldAvailabilityScreenState();
}

class _FieldAvailabilityScreenState extends State<FieldAvailabilityScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<int>> _reservations = {};
  bool _isLoadingCalendar = false;

  final FirestoreService _firestoreService = FirestoreService();
  late BookingProvider _bookingProvider;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadCalendarReservations();
    
    // Initialize real-time booking provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _bookingProvider.startListening(widget.field, _selectedDay!);
    });
  }

  @override
  void dispose() {
    // Clean up listener when screen is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingProvider.stopListening();
    });
    super.dispose();
  }

  /// Load calendar markers (for all dates in range)
  Future<void> _loadCalendarReservations() async {
    setState(() => _isLoadingCalendar = true);
    try {
      final endDate = DateTime.now().add(const Duration(days: 30));
      final reservations = await _firestoreService.getFieldReservations(
        widget.field.id,
        startDate: DateTime.now(),
        endDate: endDate,
      );
      setState(() {
        _reservations = reservations;
      });
    } finally {
      setState(() => _isLoadingCalendar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: Text('Ketersediaan ${widget.field.name}'),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          final bookedSlots = bookingProvider.bookedSlots;
          final isLoading = bookingProvider.isLoading;

          return CustomScrollView(
            slivers: [
              // Real-time sync indicator
              SliverToBoxAdapter(
                child: isLoading
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.blue.withOpacity(0.1),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Memperbarui jadwal...',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.green.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.sync, size: 14, color: Colors.green[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Real-time sync aktif',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              /// CALENDAR
              SliverToBoxAdapter(
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      // Update real-time listener for the new date
                      bookingProvider.startListening(widget.field, selectedDay);
                    }
                  },
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: true,
                    selectedDecoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  eventLoader: (day) {
                    final dateStr = day.toIso8601String().split('T')[0];
                    return _reservations.containsKey(dateStr) ? [1] : [];
                  },
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      if (events.isEmpty) return null;

                      final dateStr = date.toIso8601String().split('T')[0];
                      final calendarBookedSlots = _reservations[dateStr] ?? [];
                      final percentage = calendarBookedSlots.length / 12;

                      Color color;
                      if (percentage > 0.8) {
                        color = Colors.red;
                      } else if (percentage > 0.5) {
                        color = Colors.orange;
                      } else {
                        color = Colors.green;
                      }

                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: Divider()),

              /// TITLE + Legend
              if (_selectedDay != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ketersediaan: ${DateFormat('EEEE, d MMM yyyy', 'id_ID').format(_selectedDay!)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildLegendItem(
                              Colors.green,
                              'Tersedia',
                              isDark,
                            ),
                            const SizedBox(width: 16),
                            _buildLegendItem(
                              Colors.grey,
                              'Sudah dipesan',
                              isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              /// GRID SLOT JAM - Using real-time data
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final hour = 10 + index;
                      // Use real-time bookedSlots from BookingProvider
                      final isBooked = bookedSlots.contains(hour);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? (isDark ? Colors.grey[800] : Colors.grey[300])
                              : (isDark ? Colors.green[900] : Colors.green[100]),
                          border: Border.all(
                            color: isBooked
                                ? (isDark ? Colors.grey[600]! : Colors.grey)
                                : Colors.green,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$hour:00",
                              style: TextStyle(
                                color: isBooked
                                    ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                    : (isDark ? Colors.green[300] : Colors.green[900]),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              isBooked ? Icons.block : Icons.check_circle,
                              color: isBooked
                                  ? (isDark ? Colors.grey[500] : Colors.grey)
                                  : Colors.green,
                              size: 16,
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: 12, // 10:00 - 21:00
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.3 : 0.2),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
