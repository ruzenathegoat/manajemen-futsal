import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';
import 'admin_analytics_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_profile_screen.dart';
import 'field_management_screen.dart';
import 'user_management_screen.dart';
import 'scan_qr_screen.dart';

/// FutsalPro Admin Dashboard
/// Modern admin panel with sidebar navigation
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_NavDestination> _destinations = [
    _NavDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    _NavDestination(
      icon: Icons.stadium_outlined,
      selectedIcon: Icons.stadium,
      label: 'Lapangan',
    ),
    _NavDestination(
      icon: Icons.qr_code_scanner_outlined,
      selectedIcon: Icons.qr_code_scanner,
      label: 'Scan QR',
    ),
    _NavDestination(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'Analytics',
    ),
    _NavDestination(
      icon: Icons.description_outlined,
      selectedIcon: Icons.description,
      label: 'Laporan',
    ),
    _NavDestination(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Pengguna',
    ),
    _NavDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Pengaturan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.backgroundDark,
        drawer: !isDesktop ? _buildDrawer(user) : null,
        body: Row(
          children: [
            // Sidebar for desktop/tablet
            if (isDesktop || isTablet)
              _AdminSidebar(
                selectedIndex: _selectedIndex,
                destinations: _destinations,
                isExpanded: _isSidebarExpanded && isDesktop,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                onToggleExpanded: () {
                  setState(() => _isSidebarExpanded = !_isSidebarExpanded);
                },
                userName: user?.name ?? 'Admin',
                userEmail: user?.email ?? '',
                onLogout: () => authProvider.logout(),
              ),

            // Main content
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  _buildTopBar(user, isDesktop),
                  
                  // Content
                  Expanded(
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(user, bool isDesktop) {
    return Container(
      height: AppSpacing.appBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          // Menu button for mobile
          if (!isDesktop && !context.isTablet)
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textPrimaryDark),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),

          // Page title
          Expanded(
            child: Text(
              _destinations[_selectedIndex].label,
              style: AppTypography.titleLarge(AppColors.textPrimaryDark),
            ),
          ),

          // Actions
          Row(
            children: [
              // Theme toggle
              Consumer<ThemeProvider>(
                builder: (context, theme, _) {
                  return ProIconButton(
                    icon: theme.isDarkMode
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    onPressed: () => theme.toggleTheme(),
                    tooltip: 'Toggle Theme',
                  );
                },
              ),
              const SizedBox(width: 8),
              // Notifications
              ProIconButton(
                icon: Icons.notifications_outlined,
                onPressed: () {},
                tooltip: 'Notifikasi',
              ),
              const SizedBox(width: 8),
              // Profile
              ProAvatar(
                name: user?.name ?? 'Admin',
                size: ProAvatarSize.sm,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(user) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProAvatar(
                    name: user?.name ?? 'Admin',
                    size: ProAvatarSize.lg,
                    showBorder: true,
                    borderColor: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Admin',
                    style: AppTypography.titleMedium(AppColors.textPrimaryDark),
                  ),
                  Text(
                    user?.email ?? '',
                    style: AppTypography.bodySmall(AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderDark),
            
            // Navigation items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _destinations.length,
                itemBuilder: (context, index) {
                  final dest = _destinations[index];
                  final isSelected = _selectedIndex == index;
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? dest.selectedIcon : dest.icon,
                      color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                    ),
                    title: Text(
                      dest.label,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimaryDark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            
            const Divider(color: AppColors.borderDark),
            
            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'Keluar',
                style: AppTypography.titleSmall(AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardOverview();
      case 1:
        return const FieldManagementScreen(embedded: true);
      case 2:
        return const ScanQrScreen(embedded: true);
      case 3:
        return const AdminAnalyticsScreen(embedded: true);
      case 4:
        return const AdminReportsScreen(embedded: true);
      case 5:
        return const UserManagementScreen(embedded: true);
      case 6:
        return const AdminSettingsScreen(embedded: true);
      default:
        return const _DashboardOverview();
    }
  }
}

class _NavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Admin Sidebar Widget
class _AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavDestination> destinations;
  final bool isExpanded;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onToggleExpanded;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const _AdminSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.isExpanded,
    required this.onDestinationSelected,
    required this.onToggleExpanded,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppSpacing.durationNormal,
      width: isExpanded
          ? AppSpacing.sidebarWidthExpanded
          : AppSpacing.sidebarWidthCollapsed,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border(
          right: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Column(
        children: [
          // Logo header
          _buildHeader(),
          
          const Divider(color: AppColors.borderDark, height: 1),
          
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              itemCount: destinations.length,
              itemBuilder: (context, index) => _buildNavItem(index),
            ),
          ),
          
          const Divider(color: AppColors.borderDark, height: 1),
          
          // User section
          _buildUserSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: AppSpacing.appBarHeight,
      padding: EdgeInsets.symmetric(horizontal: isExpanded ? 20 : 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.black,
              size: 24,
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'FutsalPro',
                style: AppTypography.titleMedium(AppColors.primary),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.textSecondaryDark,
              ),
              onPressed: onToggleExpanded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final dest = destinations[index];
    final isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onDestinationSelected(index),
          borderRadius: AppSpacing.borderRadiusMd,
          child: AnimatedContainer(
            duration: AppSpacing.durationFast,
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: AppSpacing.borderRadiusMd,
              border: isSelected
                  ? Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment:
                  isExpanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? dest.selectedIcon : dest.icon,
                  size: 22,
                  color: isSelected ? AppColors.primary : AppColors.textSecondaryDark,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dest.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimaryDark,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLightDark,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Row(
                children: [
                  ProAvatar(
                    name: userName,
                    size: ProAvatarSize.sm,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: AppTypography.titleSmall(AppColors.textPrimaryDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Admin',
                          style: AppTypography.caption(AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      size: 20,
                      color: AppColors.error,
                    ),
                    onPressed: onLogout,
                  ),
                ],
              ),
            )
          else
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.error,
              ),
              onPressed: onLogout,
              tooltip: 'Logout',
            ),
        ],
      ),
    );
  }
}

/// Dashboard Overview Content
class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  Widget _buildStatsGrid(bool isDesktop, bool isTablet) {
    final stats = [
      _StatData('Total Booking', '24', Icons.calendar_today, AppColors.primary, '+12%', true),
      _StatData('Revenue Hari Ini', 'Rp 2.4jt', Icons.payments, AppColors.success, '+8%', true),
      _StatData('Pengguna Aktif', '156', Icons.people, AppColors.info, '+5%', true),
      _StatData('Lapangan Tersedia', '4/6', Icons.stadium, AppColors.warning, null, null),
    ];

    if (isDesktop) {
      // Desktop: 4 columns in a row
      return Row(
        children: stats.map((stat) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _StatCardCompact(stat: stat),
          ),
        )).toList(),
      );
    }

    // Mobile/Tablet: 2 columns using rows
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCardCompact(stat: stats[0])),
            const SizedBox(width: 16),
            Expanded(child: _StatCardCompact(stat: stats[1])),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _StatCardCompact(stat: stats[2])),
            const SizedBox(width: 16),
            Expanded(child: _StatCardCompact(stat: stats[3])),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return SingleChildScrollView(
      padding: context.responsivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Selamat Datang, Admin!',
            style: AppTypography.headlineMedium(AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Berikut ringkasan aktivitas hari ini',
            style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 24),

          // Stats grid - using Wrap for flexible layout
          _buildStatsGrid(isDesktop, context.isTablet),
          const SizedBox(height: 24),

          // Quick actions
          Text(
            'Aksi Cepat',
            style: AppTypography.titleMedium(AppColors.textPrimaryDark),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Scan QR',
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanQrScreen()),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.add_circle_outline,
                label: 'Tambah Lapangan',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FieldManagementScreen()),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.analytics,
                label: 'Lihat Analytics',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminAnalyticsScreen()),
                  );
                },
              ),
              _QuickActionButton(
                icon: Icons.description,
                label: 'Generate Laporan',
                color: AppColors.warning,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminReportsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent bookings section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Booking Terbaru',
                style: AppTypography.titleMedium(AppColors.textPrimaryDark),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Lihat Semua',
                  style: AppTypography.bodySmall(AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent bookings list placeholder
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: AppSpacing.borderRadiusLg,
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 48,
                  color: AppColors.textTertiaryDark,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tidak ada booking baru',
                  style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppSpacing.durationFast,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withOpacity(0.15)
                : AppColors.cardDark,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: _isHovered ? widget.color : AppColors.borderDark,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: AppTypography.labelMedium(
                  _isHovered ? widget.color : AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data class for stat cards
class _StatData {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? change;
  final bool? isPositive;

  const _StatData(this.title, this.value, this.icon, this.color, this.change, this.isPositive);
}

/// Compact stat card that doesn't overflow
class _StatCardCompact extends StatelessWidget {
  final _StatData stat;

  const _StatCardCompact({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          const SizedBox(width: 12),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stat.value,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (stat.change != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: (stat.isPositive ?? false)
                              ? AppColors.successSurface
                              : AppColors.errorSurface,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stat.change!,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: (stat.isPositive ?? false)
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  stat.title,
                  style: AppTypography.caption(AppColors.textSecondaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
