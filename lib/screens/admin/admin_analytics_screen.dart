import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';

/// FutsalPro Admin Analytics Screen
class AdminAnalyticsScreen extends StatefulWidget {
  final bool embedded;
  
  const AdminAnalyticsScreen({super.key, this.embedded = false});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _analyticsData;
  bool _isLoading = true;

  late TabController _tabController;

  // Filter state
  String _selectedPeriod = 'week'; // day, week, month, year
  DateTimeRange? _customRange;

  // Period options
  final Map<String, String> _periodOptions = {
    'day': 'Harian (7 hari)',
    'week': 'Mingguan (30 hari)',
    'month': 'Bulanan (90 hari)',
    'year': 'Tahunan (365 hari)',
    'custom': 'Custom',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      DateTime startDate;
      final DateTime endDate = _customRange?.end ?? DateTime.now();

      if (_customRange != null) {
        startDate = _customRange!.start;
      } else {
        switch (_selectedPeriod) {
          case 'day':
            startDate = DateTime.now().subtract(const Duration(days: 7));
            break;
          case 'week':
            startDate = DateTime.now().subtract(const Duration(days: 30));
            break;
          case 'month':
            startDate = DateTime.now().subtract(const Duration(days: 90));
            break;
          case 'year':
            startDate = DateTime.now().subtract(const Duration(days: 365));
            break;
          default:
            startDate = DateTime.now().subtract(const Duration(days: 30));
        }
      }

      final data = await _firestoreService.getAnalyticsData(
        startDate: startDate,
        endDate: endDate,
      );

      if (mounted) {
        setState(() => _analyticsData = data);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.show_chart), text: 'Trends'),
            Tab(icon: Icon(Icons.grid_view), text: 'Heatmap'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter bar
          _buildFilterBar(isDark),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadAnalytics,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(isDark),
                        _buildTrendsTab(isDark),
                        _buildHeatmapTab(isDark),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _periodOptions.entries.map((entry) {
                  final isSelected =
                      (_customRange != null && entry.key == 'custom') ||
                          (_customRange == null &&
                              _selectedPeriod == entry.key);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                      onSelected: (_) => _onPeriodSelected(entry.key),
                      selectedColor: Theme.of(context).primaryColor,
                      checkmarkColor: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPeriodSelected(String period) async {
    if (period == 'custom') {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 2)),
        lastDate: DateTime.now(),
        initialDateRange: _customRange ??
            DateTimeRange(
              start: DateTime.now().subtract(const Duration(days: 30)),
              end: DateTime.now(),
            ),
      );

      if (picked != null) {
        setState(() {
          _customRange = picked;
        });
        _loadAnalytics();
      }
    } else {
      setState(() {
        _selectedPeriod = period;
        _customRange = null;
      });
      _loadAnalytics();
    }
  }

  // ============== OVERVIEW TAB ==============
  Widget _buildOverviewTab(bool isDark) {
    final totalBookings =
        (_analyticsData?['totalBookings'] as num?)?.toInt() ?? 0;
    final totalRevenue =
        (_analyticsData?['totalRevenue'] as num?)?.toInt() ?? 0;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // Calculate additional metrics
    final avgRevenue = totalBookings > 0 ? totalRevenue ~/ totalBookings : 0;
    final hourlyBookings =
        _analyticsData?['hourlyBookings'] as Map<String, dynamic>? ?? {};
    final peakHour = _findPeakHour(hourlyBookings);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards Row
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'Total Booking',
                  totalBookings.toString(),
                  Icons.calendar_today,
                  const Color(0xFF6366F1),
                  '+12%',
                  true,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  'Total Revenue',
                  currencyFormat.format(totalRevenue),
                  Icons.payments,
                  const Color(0xFF10B981),
                  '+8%',
                  true,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  'Rata-rata/Booking',
                  currencyFormat.format(avgRevenue),
                  Icons.trending_up,
                  const Color(0xFFF59E0B),
                  null,
                  null,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  'Jam Tersibuk',
                  peakHour != null ? '$peakHour:00' : '-',
                  Icons.access_time,
                  const Color(0xFFEC4899),
                  null,
                  null,
                  isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue Pie Chart
          _buildSectionCard(
            'Distribusi Revenue per Field',
            _buildRevenuePieChart(isDark),
            isDark,
          ),

          const SizedBox(height: 16),

          // Hourly Distribution Bar Chart
          _buildSectionCard(
            'Distribusi Booking per Jam',
            _buildHourlyBarChart(isDark),
            isDark,
          ),
        ],
      ),
    );
  }

  int? _findPeakHour(Map<String, dynamic> hourlyBookings) {
    if (hourlyBookings.isEmpty) return null;

    int maxBookings = 0;
    int? peakHour;

    hourlyBookings.forEach((hourStr, count) {
      final bookingCount = (count as num?)?.toInt() ?? 0;
      if (bookingCount > maxBookings) {
        maxBookings = bookingCount;
        peakHour = int.tryParse(hourStr);
      }
    });

    return peakHour;
  }

  Widget _buildKPICard(
    String title,
    String value,
    IconData icon,
    Color color,
    String? change,
    bool? isPositive,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (change != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ?? false)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: (isPositive ?? false) ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }

  Widget _buildRevenuePieChart(bool isDark) {
    final dailyRevenue =
        _analyticsData?['dailyRevenue'] as Map<String, dynamic>? ?? {};

    if (dailyRevenue.isEmpty) {
      return _buildEmptyState('Tidak ada data revenue');
    }

    // Group by day of week for pie chart
    Map<String, int> weekdayRevenue = {
      'Senin': 0,
      'Selasa': 0,
      'Rabu': 0,
      'Kamis': 0,
      'Jumat': 0,
      'Sabtu': 0,
      'Minggu': 0,
    };

    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu'
    ];

    dailyRevenue.forEach((dateStr, revenue) {
      try {
        final date = DateTime.parse(dateStr);
        final dayIndex = date.weekday - 1;
        weekdayRevenue[dayNames[dayIndex]] =
            (weekdayRevenue[dayNames[dayIndex]] ?? 0) +
                ((revenue as num?)?.toInt() ?? 0);
      } catch (_) {}
    });

    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFEF4444),
    ];

    final sections = <PieChartSectionData>[];
    int colorIndex = 0;

    weekdayRevenue.forEach((day, revenue) {
      if (revenue > 0) {
        sections.add(
          PieChartSectionData(
            value: revenue.toDouble(),
            title: day.substring(0, 3),
            color: colors[colorIndex % colors.length],
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      colorIndex++;
    });

    if (sections.isEmpty) {
      return _buildEmptyState('Tidak ada data revenue');
    }

    return PieChart(
      PieChartData(
        sections: sections,
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildHourlyBarChart(bool isDark) {
    final hourlyBookings =
        _analyticsData?['hourlyBookings'] as Map<String, dynamic>? ?? {};

    if (hourlyBookings.isEmpty) {
      return _buildEmptyState('Tidak ada data booking');
    }

    final List<BarChartGroupData> barGroups = [];

    for (int hour = 10; hour <= 21; hour++) {
      final count =
          (hourlyBookings[hour.toString()] as num?)?.toDouble() ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: hour,
          barRods: [
            BarChartRodData(
              toY: count,
              color: const Color(0xFF6366F1),
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        ),
      );
    }

    final maxY = hourlyBookings.values
            .fold<double>(0, (max, v) => ((v as num?)?.toDouble() ?? 0) > max ? (v as num).toDouble() : max) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 1 ? 1 : maxY,
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${value.toInt()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ============== TRENDS TAB ==============
  Widget _buildTrendsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            'Trend Revenue Mingguan',
            _buildWeeklyRevenueLineChart(isDark),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Trend Revenue Bulanan',
            _buildMonthlyRevenueLineChart(isDark),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Trend Booking Mingguan',
            _buildWeeklyBookingLineChart(isDark),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyRevenueLineChart(bool isDark) {
    final raw =
        _analyticsData?['weeklyRevenue'] as Map<String, dynamic>? ?? {};
    final Map<String, int> weeklyRevenue =
        raw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0));

    if (weeklyRevenue.isEmpty) {
      return _buildEmptyState('Tidak ada data');
    }

    final keys = weeklyRevenue.keys.toList()..sort();
    final maxRevenue = weeklyRevenue.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxRevenue == 0 ? 1 : maxRevenue * 1.1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                if (value <= 0) return const Text('');
                return Text(
                  _formatCurrency(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= keys.length) return const Text('');
                final parts = keys[i].split('-W');
                return parts.length == 2
                    ? Text(
                        'W${parts[1]}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      )
                    : const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: keys
                .asMap()
                .entries
                .map((e) =>
                    FlSpot(e.key.toDouble(), weeklyRevenue[e.value]!.toDouble()))
                .toList(),
            isCurved: true,
            color: const Color(0xFF6366F1),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF6366F1),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.3),
                  const Color(0xFF6366F1).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildMonthlyRevenueLineChart(bool isDark) {
    final raw =
        _analyticsData?['monthlyRevenue'] as Map<String, dynamic>? ?? {};
    final Map<String, int> monthlyRevenue =
        raw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0));

    if (monthlyRevenue.isEmpty) {
      return _buildEmptyState('Tidak ada data');
    }

    final keys = monthlyRevenue.keys.toList()..sort();
    final maxRevenue = monthlyRevenue.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxRevenue == 0 ? 1 : maxRevenue * 1.1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, _) {
                if (value <= 0) return const Text('');
                return Text(
                  _formatCurrency(value),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= keys.length) return const Text('');
                final parts = keys[i].split('-');
                return Text(
                  '${parts[1]}/${parts[0].substring(2)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: keys
                .asMap()
                .entries
                .map((e) => FlSpot(
                    e.key.toDouble(), monthlyRevenue[e.value]!.toDouble()))
                .toList(),
            isCurved: true,
            color: const Color(0xFF10B981),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF10B981),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF10B981).withOpacity(0.3),
                  const Color(0xFF10B981).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildWeeklyBookingLineChart(bool isDark) {
    final raw =
        _analyticsData?['weeklyBookings'] as Map<String, dynamic>? ?? {};
    final Map<String, int> weeklyBookings =
        raw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0));

    if (weeklyBookings.isEmpty) {
      return _buildEmptyState('Tidak ada data');
    }

    final keys = weeklyBookings.keys.toList()..sort();
    final maxBookings = weeklyBookings.values.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxBookings == 0 ? 1 : maxBookings * 1.1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= keys.length) return const Text('');
                final parts = keys[i].split('-W');
                return parts.length == 2
                    ? Text(
                        'W${parts[1]}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      )
                    : const Text('');
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: keys
                .asMap()
                .entries
                .map((e) => FlSpot(
                    e.key.toDouble(), weeklyBookings[e.value]!.toDouble()))
                .toList(),
            isCurved: true,
            color: const Color(0xFFF59E0B),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFFF59E0B),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF59E0B).withOpacity(0.3),
                  const Color(0xFFF59E0B).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ============== HEATMAP TAB ==============
  Widget _buildHeatmapTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            'Heatmap Jam Booking',
            _buildHourlyHeatmap(isDark),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            'Heatmap Booking Mingguan',
            _buildWeeklyHeatmap(isDark),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildHeatmapLegend(isDark),
        ],
      ),
    );
  }

  Widget _buildHourlyHeatmap(bool isDark) {
    final raw =
        _analyticsData?['hourlyBookings'] as Map<String, dynamic>? ?? {};

    if (raw.isEmpty) {
      return _buildEmptyState('Tidak ada data');
    }

    final maxBookings = raw.values
        .fold<int>(0, (max, v) => ((v as num?)?.toInt() ?? 0) > max ? (v as num).toInt() : max);

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(12, (index) {
        final hour = 10 + index;
        final count = (raw[hour.toString()] as num?)?.toInt() ?? 0;
        final intensity = maxBookings > 0 ? count / maxBookings : 0.0;

        return Tooltip(
          message: '$hour:00 - $count booking',
          child: Container(
            width: 60,
            height: 50,
            decoration: BoxDecoration(
              color: _getHeatmapColor(intensity),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$hour:00',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: intensity > 0.5 ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    color: intensity > 0.5 ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWeeklyHeatmap(bool isDark) {
    final raw =
        _analyticsData?['weeklyBookings'] as Map<String, dynamic>? ?? {};

    if (raw.isEmpty) {
      return _buildEmptyState('Tidak ada data');
    }

    final keys = raw.keys.toList()..sort();
    final maxBookings = raw.values
        .fold<int>(0, (max, v) => ((v as num?)?.toInt() ?? 0) > max ? (v as num).toInt() : max);

    return Column(
      children: keys.map((week) {
        final count = (raw[week] as num?)?.toInt() ?? 0;
        final intensity = maxBookings > 0 ? count / maxBookings : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  week,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: intensity,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getHeatmapColor(intensity),
                              _getHeatmapColor(intensity * 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          '$count booking',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
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
      }).toList(),
    );
  }

  Widget _buildHeatmapLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legenda Intensitas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem('Rendah', _getHeatmapColor(0.2), isDark),
              _legendItem('Sedang', _getHeatmapColor(0.5), isDark),
              _legendItem('Tinggi', _getHeatmapColor(0.8), isDark),
              _legendItem('Sangat Tinggi', _getHeatmapColor(1.0), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
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

  Color _getHeatmapColor(double intensity) {
    if (intensity > 0.8) return const Color(0xFFDC2626);
    if (intensity > 0.6) return const Color(0xFFF97316);
    if (intensity > 0.4) return const Color(0xFFFBBF24);
    if (intensity > 0.2) return const Color(0xFF84CC16);
    return const Color(0xFF22C55E);
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toInt().toString();
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
