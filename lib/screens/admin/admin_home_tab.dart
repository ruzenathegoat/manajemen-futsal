import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/booking_provider.dart';
import '../../services/field_service.dart';
import '../../services/user_service.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/charts/booking_trends_chart.dart';

class AdminHomeTab extends StatelessWidget {
  const AdminHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingProvider = context.watch<BookingProvider>();
    final stats = bookingProvider.statistics;

    return RefreshIndicator(
      onRefresh: () async {
        await bookingProvider.loadStatistics();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 16),
            _buildKpiSection(context, stats),
            const SizedBox(height: 24),
            Text(
              'Tren Booking',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: stats == null
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : BookingTrendsChart(
                      bookingsByDay:
                          Map<String, int>.from(stats['bookingsByDay'] ?? {}),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              'Peak Hours',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: stats == null
                  ? const SizedBox(
                      height: 180,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : PeakHoursChart(
                      bookingsByHour:
                          Map<int, int>.from(stats['bookingsByHour'] ?? {}),
                    ),
            ),
            const SizedBox(height: 24),
            Text(
              'Weekday vs Weekend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: stats == null
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : WeekendWeekdayPieChart(
                      weekendBookings: stats['weekendBookings'] ?? 0,
                      weekdayBookings: stats['weekdayBookings'] ?? 0,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, Map<String, dynamic>? stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Booking',
                value: (stats?['totalBookings'] ?? 0).toString(),
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Revenue',
                value: CurrencyFormatter.formatRupiah(
                  (stats?['totalRevenue'] ?? 0).toDouble(),
                ),
                icon: Icons.payments_rounded,
                iconColor: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FutureBuilder<int>(
                future: FieldService().getFieldCount(),
                builder: (context, snapshot) {
                  return StatCard(
                    title: 'Lapangan Aktif',
                    value: (snapshot.data ?? 0).toString(),
                    icon: Icons.sports_soccer_rounded,
                    iconColor: AppColors.secondary,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<int>(
                future: UserService().getActiveUserCount(),
                builder: (context, snapshot) {
                  return StatCard(
                    title: 'User Aktif',
                    value: (snapshot.data ?? 0).toString(),
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.accent,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
