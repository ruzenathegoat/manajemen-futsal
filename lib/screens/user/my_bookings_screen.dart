import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/core.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

/// FutsalPro My Bookings Screen
/// User's booking history with redesigned UI
class MyBookingsScreen extends StatefulWidget {
  final bool embedded;
  
  const MyBookingsScreen({super.key, this.embedded = false});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    if (user == null) {
      return _buildErrorState();
    }

    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: widget.embedded ? null : _buildAppBar(),
      body: SafeArea(
        top: widget.embedded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embedded) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Saya',
                      style: AppTypography.headlineMedium(AppColors.textPrimaryDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kelola semua pesanan anda',
                      style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
                    ),
                  ],
                ),
              ),
            ],
            
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.textSecondaryDark,
                labelStyle: AppTypography.labelMedium(Colors.black),
                unselectedLabelStyle: AppTypography.labelMedium(AppColors.textSecondaryDark),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Aktif'),
                  Tab(text: 'Selesai'),
                  Tab(text: 'Dibatalkan'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab content
            Expanded(
              child: StreamBuilder<List<BookingModel>>(
                stream: firestoreService.getUserBookings(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (snapshot.hasError) {
                    return _buildErrorState(message: snapshot.error.toString());
                  }

                  final allBookings = snapshot.data ?? [];

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Active bookings
                      _buildBookingList(
                        allBookings.where((b) => 
                          b.status == 'booked' || b.status == 'approved'
                        ).toList(),
                        'Tidak ada booking aktif',
                        'Booking anda akan muncul di sini',
                      ),
                      // Completed bookings
                      _buildBookingList(
                        allBookings.where((b) => b.status == 'completed').toList(),
                        'Tidak ada booking selesai',
                        'Riwayat booking selesai akan muncul di sini',
                      ),
                      // Cancelled bookings
                      _buildBookingList(
                        allBookings.where((b) => b.status == 'cancelled').toList(),
                        'Tidak ada booking dibatalkan',
                        'Booking yang dibatalkan akan muncul di sini',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ProAppBar(
      title: 'Booking Saya',
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ProShimmerCard(height: 150, showImage: false, lines: 4),
      ),
    );
  }

  Widget _buildErrorState({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.errorSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: AppTypography.titleMedium(AppColors.textPrimaryDark),
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTypography.bodySmall(AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingList(
    List<BookingModel> bookings,
    String emptyTitle,
    String emptySubtitle,
  ) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: AppColors.textTertiaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              style: AppTypography.titleMedium(AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              style: AppTypography.bodySmall(AppColors.textSecondaryDark),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _BookingCard(
            booking: booking,
            onTap: () => _showBookingDetail(booking),
          ),
        );
      },
    );
  }

  void _showBookingDetail(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BookingDetailSheet(booking: booking),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onTap;

  const _BookingCard({
    required this.booking,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(booking.date),
                      style: AppTypography.bodySmall(AppColors.textSecondaryDark),
                    ),
                  ],
                ),
                ProBookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 12),

            // Field name
            Text(
              booking.fieldName,
              style: AppTypography.titleMedium(AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 8),

            // Time and duration
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondaryDark,
                ),
                const SizedBox(width: 8),
                Text(
                  '${booking.timeSlot}:00 - ${booking.timeSlot + booking.duration}:00',
                  style: AppTypography.bodyMedium(AppColors.textPrimaryDark),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightDark,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    '${booking.duration} jam',
                    style: AppTypography.caption(AppColors.textSecondaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Price and action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(booking.totalCost),
                  style: AppTypography.priceSmall(AppColors.primary),
                ),
                if (booking.status == 'booked' || booking.status == 'approved')
                  Row(
                    children: [
                      Text(
                        'Lihat QR',
                        style: AppTypography.labelMedium(AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.qr_code,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailSheet extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailSheet({required this.booking});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textTertiaryDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content - scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
              child: Column(
                children: [
                  // Field name and status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.fieldName,
                          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
                        ),
                      ),
                      ProBookingStatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(booking.date),
                    style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 24),

                  // QR Code (for active bookings)
                  if (booking.status == 'booked' || booking.status == 'approved') ...[
                    Text(
                      'Tunjukkan QR Code ini ke Admin',
                      style: AppTypography.bodySmall(AppColors.textSecondaryDark),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppSpacing.borderRadiusLg,
                      ),
                      child: QrImageView(
                        data: booking.qrCode,
                        version: QrVersions.auto,
                        size: 180,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLightDark,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: SelectableText(
                        booking.qrCode,
                        style: AppTypography.monospace(AppColors.textSecondaryDark),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: ProButton(
                        text: 'Batalkan Pesanan',
                        variant: ProButtonVariant.danger,
                        leadingIcon: Icons.cancel_outlined,
                        onPressed: () => _cancelBooking(context),
                      ),
                    ),
                  ] else ...[
                    // Status icon for completed/cancelled
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(),
                        size: 64,
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusText(),
                      style: AppTypography.titleMedium(AppColors.textPrimaryDark),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Booking details
                  _buildDetailRow(
                    Icons.access_time,
                    'Waktu',
                    '${booking.timeSlot}:00 - ${booking.timeSlot + booking.duration}:00',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.timer,
                    'Durasi',
                    '${booking.duration} jam',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.payments,
                    'Total',
                    currencyFormat.format(booking.totalCost),
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryDark),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTypography.bodyMedium(
            valueColor ?? AppColors.textPrimaryDark,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (booking.status) {
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText() {
    switch (booking.status) {
      case 'completed':
        return 'Pesanan Selesai';
      case 'cancelled':
        return 'Pesanan Dibatalkan';
      default:
        return booking.status;
    }
  }

  Future<void> _cancelBooking(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Batalkan Pesanan?',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: Text(
          'Apakah anda yakin ingin membatalkan pesanan ini?',
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Tidak',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await FirestoreService().cancelBooking(booking.id);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Pesanan berhasil dibatalkan'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
