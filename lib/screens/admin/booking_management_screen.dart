import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/booking_model.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/cards/booking_card.dart';

class BookingManagementScreen extends StatefulWidget {
  const BookingManagementScreen({super.key});

  @override
  State<BookingManagementScreen> createState() => _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();
    final bookings = bookingProvider.allBookings;

    final filteredBookings = bookings.where((booking) {
      if (_filter == 'all') return true;
      return booking.status == _filter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua', 'all'),
                _buildFilterChip('Pending', AppConstants.statusPending),
                _buildFilterChip('Dikonfirmasi', AppConstants.statusConfirmed),
                _buildFilterChip('Check-in', AppConstants.statusCheckedIn),
                _buildFilterChip('Selesai', AppConstants.statusCompleted),
                _buildFilterChip('Batal', AppConstants.statusCancelled),
              ],
            ),
          ),
        ),
        Expanded(
          child: filteredBookings.isEmpty
              ? Center(
                  child: Text(
                    'Belum ada booking',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          BookingCard(
                            booking: booking,
                            showUserInfo: true,
                            onTap: () => _showBookingActions(context, booking),
                          ),
                          const SizedBox(height: 8),
                          _buildActionRow(context, booking),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, BookingModel booking) {
    final bookingProvider = context.read<BookingProvider>();

    final canCheckIn = booking.canCheckIn;
    final canComplete = booking.isCheckedIn;

    return Row(
      children: [
        if (canCheckIn)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => bookingProvider.updateBookingStatus(
                bookingId: booking.bookingId,
                status: AppConstants.statusCheckedIn,
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: const Text('Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (canCheckIn) const SizedBox(width: 8),
        if (canComplete)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => bookingProvider.updateBookingStatus(
                bookingId: booking.bookingId,
                status: AppConstants.statusCompleted,
              ),
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (!booking.isCancelled && !booking.isCompleted)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _confirmCancel(context, booking),
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Batalkan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
      ],
    );
  }

  void _showBookingActions(BuildContext context, BookingModel booking) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aksi Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 16),
              _actionTile(
                context,
                icon: Icons.login_rounded,
                label: 'Check-in',
                enabled: booking.canCheckIn,
                onTap: () => _updateStatus(
                  context,
                  booking.bookingId,
                  AppConstants.statusCheckedIn,
                ),
              ),
              _actionTile(
                context,
                icon: Icons.verified_rounded,
                label: 'Selesai',
                enabled: booking.isCheckedIn,
                onTap: () => _updateStatus(
                  context,
                  booking.bookingId,
                  AppConstants.statusCompleted,
                ),
              ),
              _actionTile(
                context,
                icon: Icons.close_rounded,
                label: 'Batalkan',
                enabled: !booking.isCancelled && !booking.isCompleted,
                color: AppColors.error,
                onTap: () => _confirmCancel(context, booking),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: enabled ? (color ?? AppColors.primary) : Colors.grey),
      title: Text(label),
      enabled: enabled,
      onTap: () {
        if (!enabled) return;
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    String bookingId,
    String status,
  ) async {
    await context.read<BookingProvider>().updateBookingStatus(
          bookingId: bookingId,
          status: status,
        );
  }

  Future<void> _confirmCancel(BuildContext context, BookingModel booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Booking'),
        content: const Text('Apakah Anda yakin ingin membatalkan booking ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!context.mounted) return;
      await context.read<BookingProvider>().updateBookingStatus(
            bookingId: booking.bookingId,
            status: AppConstants.statusCancelled,
          );
    }
  }
}
