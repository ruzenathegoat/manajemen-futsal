import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/field_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../widgets/common/custom_button.dart';
import 'booking_success_screen.dart';

class BookingReviewScreen extends StatefulWidget {
  final FieldModel field;
  final DateTime date;
  final String timeSlot;

  const BookingReviewScreen({
    super.key,
    required this.field,
    required this.date,
    required this.timeSlot,
  });

  @override
  State<BookingReviewScreen> createState() => _BookingReviewScreenState();
}

class _BookingReviewScreenState extends State<BookingReviewScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();

    final isWeekend = AppConstants.isWeekend(widget.date);
    final finalPrice = AppConstants.calculatePrice(
      widget.field.basePrice,
      widget.date,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Booking'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Detail Lapangan', isDark),
              const SizedBox(height: 12),
              _InfoCard(
                items: [
                  _InfoItem('Nama Lapangan', widget.field.name),
                  _InfoItem('Tanggal', DateFormatter.formatFullDate(widget.date)),
                  _InfoItem('Waktu', widget.timeSlot),
                  _InfoItem(
                    'Harga Dasar',
                    CurrencyFormatter.formatRupiah(widget.field.basePrice),
                  ),
                  _InfoItem(
                    'Jenis Harga',
                    isWeekend ? 'Weekend (+10%)' : 'Weekday',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Detail Pemesan', isDark),
              const SizedBox(height: 12),
              _InfoCard(
                items: [
                  _InfoItem('Nama', authProvider.user?.name ?? '-'),
                  _InfoItem('Email', authProvider.user?.email ?? '-'),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Total Pembayaran', isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatRupiah(finalPrice),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Kembali',
                      variant: ButtonVariant.outline,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Konfirmasi',
                      isLoading: _isSubmitting,
                      onPressed: () => _handleConfirm(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context) async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final bookingProvider = context.read<BookingProvider>();
    final authProvider = context.read<AuthProvider>();

    bookingProvider.setSelectedField(widget.field);
    bookingProvider.setSelectedDate(widget.date);
    bookingProvider.setSelectedTimeSlot(widget.timeSlot);

    final booking = await bookingProvider.createBooking(authProvider.user!);

    setState(() => _isSubmitting = false);
    if (!context.mounted) return;

    if (booking != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(booking: booking),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.error ?? 'Booking gagal'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<_InfoItem> items;

  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    item.value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
