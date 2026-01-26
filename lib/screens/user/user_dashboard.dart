import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/core.dart';
import '../../models/field_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';
import 'user_profile_screen.dart';
import 'field_availability_screen.dart';

/// FutsalPro User Dashboard
/// Modern dashboard with bottom navigation and card-based layout
class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _pages.addAll([
      const _HomeTab(),
      const _ExploreTab(),
      const _BookingsTab(),
      const _ProfileTab(),
    ]);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: ProBottomNav(
          currentIndex: _currentIndex,
          items: const [
            ProNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Beranda',
            ),
            ProNavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Jelajahi',
            ),
            ProNavItem(
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today,
              label: 'Booking',
            ),
            ProNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profil',
            ),
          ],
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
        ),
      ),
    );
  }
}

/// Home Tab - Main dashboard view
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    final firestoreService = FirestoreService();

    return CustomScrollView(
      slivers: [
        // App bar with user greeting
        SliverToBoxAdapter(
          child: ProDashboardAppBar(
            userName: user?.name ?? 'Player',
            userImage: null,
            greeting: _getGreeting(),
            onProfileTap: () {
              // Navigate to profile
            },
            onSearchTap: () {
              // Show search
            },
            onNotificationTap: () {
              // Show notifications
            },
          ),
        ),

        // Quick actions section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mau main di mana hari ini?',
                  style: AppTypography.headlineSmall(AppColors.textPrimaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih lapangan dan langsung booking',
                  style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
        ),

        // Quick stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _QuickStats(),
          ),
        ),

        // Featured fields header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lapangan Tersedia',
                  style: AppTypography.titleMedium(AppColors.textPrimaryDark),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all fields
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lihat Semua',
                        style: AppTypography.bodySmall(AppColors.primary),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Fields list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: StreamBuilder<List<FieldModel>>(
            stream: firestoreService.getFields(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProShimmerCard(height: 280, lines: 3),
                    ),
                    childCount: 3,
                  ),
                );
              }

              final fields = snapshot.data ?? [];
              if (fields.isEmpty) {
                return SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.stadium_outlined,
                    title: 'Tidak ada lapangan',
                    subtitle: 'Belum ada lapangan tersedia saat ini',
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final field = fields[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ProFieldCard(
                        field: field,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(field: field),
                            ),
                          );
                        },
                        onBookPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(field: field),
                            ),
                          );
                        },
                        onSchedulePressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FieldAvailabilityScreen(field: field),
                            ),
                          );
                        },
                      ),
                    );
                  },
                  childCount: fields.length,
                ),
              );
            },
          ),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}

class _QuickStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.sports_soccer,
            value: '0',
            label: 'Booking Aktif',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.history,
            value: '0',
            label: 'Total Booking',
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.titleLarge(AppColors.textPrimaryDark),
              ),
              Text(
                label,
                style: AppTypography.caption(AppColors.textSecondaryDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Explore Tab - Browse all fields
class _ExploreTab extends StatelessWidget {
  const _ExploreTab();

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jelajahi',
                    style: AppTypography.headlineMedium(AppColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Temukan lapangan futsal terbaik',
                    style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 16),
                  // Search bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: AppSpacing.borderRadiusMd,
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors.textTertiaryDark,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari lapangan...',
                              hintStyle: AppTypography.bodyMedium(
                                AppColors.textTertiaryDark,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                            style: AppTypography.bodyMedium(
                              AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category chips
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _CategoryChip(label: 'Semua', isSelected: true),
                  _CategoryChip(label: 'Vinyl'),
                  _CategoryChip(label: 'Sintetis'),
                  _CategoryChip(label: 'Indoor'),
                  _CategoryChip(label: 'Outdoor'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Fields grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: StreamBuilder<List<FieldModel>>(
              stream: firestoreService.getFields(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProShimmerCard(height: 200, lines: 2),
                      childCount: 4,
                    ),
                  );
                }

                final fields = snapshot.data ?? [];
                if (fields.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyState(
                      icon: Icons.search_off,
                      title: 'Tidak ditemukan',
                      subtitle: 'Coba kata kunci lain',
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final field = fields[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ProFieldCard(
                          field: field,
                          isCompact: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookingScreen(field: field),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: fields.length,
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _CategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: AppColors.surfaceDark,
        selectedColor: AppColors.primary.withOpacity(0.2),
        checkmarkColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.borderDark,
        ),
      ),
    );
  }
}

/// Bookings Tab - User's booking history
class _BookingsTab extends StatelessWidget {
  const _BookingsTab();

  @override
  Widget build(BuildContext context) {
    return const MyBookingsScreen(embedded: true);
  }
}

/// Profile Tab - User profile and settings
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const UserProfileScreen(embedded: true);
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                icon,
                size: 48,
                color: AppColors.textTertiaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleMedium(AppColors.textPrimaryDark),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
