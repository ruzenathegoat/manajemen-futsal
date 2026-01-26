import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/field_model.dart';
import '../../models/booking_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class BookingScreen extends StatefulWidget {
  final FieldModel field;
  const BookingScreen({super.key, required this.field});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int? _selectedTimeSlot;
  int _selectedDuration = 1;
  bool _isProcessing = false;

  late BookingProvider _bookingProvider;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();

    // Initialize booking provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      _bookingProvider.startListening(widget.field, _selectedDay!);
    });
  }

  @override
  void dispose() {
    // Clean up listener when screen is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) return;
      _bookingProvider.stopListening();
    });
    super.dispose();
  }

  int get _currentPrice {
    if (_selectedDay == null) {
      return widget.field.basePrice * _selectedDuration;
    }
    final isWeekend =
        _selectedDay!.weekday == 6 || _selectedDay!.weekday == 7;
    final base = isWeekend
        ? (widget.field.basePrice * 1.1).round()
        : widget.field.basePrice;
    return base * _selectedDuration;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking ${widget.field.name}'),
        elevation: 0,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          final bookedSlots = bookingProvider.bookedSlots;
          final isLoading = bookingProvider.isLoading;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Real-time sync indicator
                if (isLoading)
                  Container(
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
                else
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.green.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync,
                          size: 14,
                          color: Colors.green[700],
                        ),
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

                // Calendar
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 30)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!isSameDay(_selectedDay, selectedDay)) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _selectedTimeSlot = null;
                      });
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
                ),

                const Divider(),

                // Duration selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        "Durasi: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(value: 1, label: Text('1 Jam')),
                            ButtonSegment(value: 2, label: Text('2 Jam')),
                            ButtonSegment(value: 3, label: Text('3 Jam')),
                          ],
                          selected: {_selectedDuration},
                          onSelectionChanged: (v) {
                            setState(() {
                              _selectedDuration = v.first;
                              _selectedTimeSlot = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Time slot header with legend
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pilih Jam Mulai:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildLegendItem(
                            Colors.grey[300]!,
                            'Tidak tersedia',
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            Colors.orange[100]!,
                            'Durasi tumpang tindih',
                            isDark,
                          ),
                          const SizedBox(width: 12),
                          _buildLegendItem(
                            theme.primaryColor,
                            'Dipilih',
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Time slots grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final hour = 10 + index;
                    final isBooked = bookedSlots.contains(hour);
                    final isSelected = _selectedTimeSlot == hour;

                    bool canSelect = !isBooked;
                    for (int i = 0; i < _selectedDuration && canSelect; i++) {
                      if (bookedSlots.contains(hour + i) || hour + i >= 22) {
                        canSelect = false;
                      }
                    }

                    return _TimeSlotTile(
                      hour: hour,
                      isBooked: isBooked,
                      isSelected: isSelected,
                      canSelect: canSelect,
                      duration: _selectedDuration,
                      onTap: canSelect
                          ? () => setState(() => _selectedTimeSlot = hour)
                          : null,
                    );
                  },
                ),

                // Bottom pricing and confirmation
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Harga:",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            currencyFormat.format(_currentPrice),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedTimeSlot != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            "Durasi: $_selectedDuration jam ($_selectedTimeSlot:00 - ${_selectedTimeSlot! + _selectedDuration}:00)",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_selectedTimeSlot == null ||
                                  !bookingProvider.areSlotsAvailable(
                                    _selectedTimeSlot!,
                                    _selectedDuration,
                                  ) ||
                                  _isProcessing)
                              ? null
                              : _processBooking,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "KONFIRMASI BOOKING",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _processBooking() async {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel!;
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    setState(() => _isProcessing = true);

    try {
      final booking = await bookingProvider.createBookingWithValidation(
        userId: user.uid,
        userName: user.name,
        field: widget.field,
        date: _selectedDay!,
        timeSlot: _selectedTimeSlot!,
        duration: _selectedDuration,
        totalCost: _currentPrice,
      );

      if (!mounted) return;
      
      // Reset processing state before showing dialog
      setState(() => _isProcessing = false);
      
      // Small delay to ensure state is settled before showing dialog
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      _showSuccessDialog(booking);
    } on BookingConflictException catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showErrorDialog('Terjadi kesalahan: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Booking Gagal"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showSuccessDialog(BookingModel booking) {
    // Stop listening to prevent stream updates from interfering
    _bookingProvider.stopListening();
    
    // Use Navigator to push a new page instead of dialog to avoid widget issues
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _BookingSuccessPage(booking: booking),
      ),
    );
  }
}

/// Time slot tile widget with visual states
class _TimeSlotTile extends StatelessWidget {
  final int hour;
  final bool isBooked;
  final bool isSelected;
  final bool canSelect;
  final int duration;
  final VoidCallback? onTap;

  const _TimeSlotTile({
    required this.hour,
    required this.isBooked,
    required this.isSelected,
    required this.canSelect,
    required this.duration,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isBooked) {
      bgColor = Colors.grey[300]!;
      borderColor = Colors.grey;
      textColor = Colors.grey[600]!;
    } else if (isSelected) {
      bgColor = theme.primaryColor;
      borderColor = theme.primaryColor;
      textColor = Colors.white;
    } else if (!canSelect) {
      bgColor = Colors.orange[100]!;
      borderColor = Colors.orange;
      textColor = Colors.orange[800]!;
    } else {
      bgColor = theme.cardColor;
      borderColor = Colors.grey;
      textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "$hour:00",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            if (isSelected && duration > 1)
              Text(
                "- ${hour + duration}:00",
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            if (isBooked)
              Icon(
                Icons.block,
                size: 12,
                color: textColor,
              ),
          ],
        ),
      ),
    );
  }
}

/// Separate page for booking success - avoids dialog widget issues
class _BookingSuccessPage extends StatelessWidget {
  final BookingModel booking;

  const _BookingSuccessPage({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text('Booking Berhasil'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Success icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),

              // Success message
              const Text(
                'Booking Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tunjukkan QR code ini saat check-in',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),

              // QR Code card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: booking.qrCode,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QR Code text
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        booking.qrCode,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Booking details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.stadium,
                      'Lapangan',
                      booking.fieldName,
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Tanggal',
                      DateFormat('EEEE, d MMMM yyyy', 'id_ID')
                          .format(booking.date),
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.access_time,
                      'Waktu',
                      '${booking.timeSlot}:00 - ${booking.timeSlot + booking.duration}:00',
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.timer,
                      'Durasi',
                      '${booking.duration} jam',
                      isDark,
                    ),
                    const Divider(height: 16),
                    _buildDetailRow(
                      Icons.payments,
                      'Total',
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(booking.totalCost),
                      isDark,
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'KEMBALI KE BERANDA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isHighlighted ? Colors.green : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                  color: isHighlighted
                      ? Colors.green
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
