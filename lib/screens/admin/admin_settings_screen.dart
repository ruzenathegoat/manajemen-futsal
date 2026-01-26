import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/widgets.dart';

/// FutsalPro Admin Settings Screen
class AdminSettingsScreen extends StatelessWidget {
  final bool embedded;
  
  const AdminSettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: embedded ? null : const ProAppBar(title: 'Pengaturan'),
      body: SafeArea(
        top: embedded,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (embedded) ...[
              Text(
                'Pengaturan',
                style: AppTypography.headlineSmall(AppColors.textPrimaryDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola preferensi aplikasi',
                style: AppTypography.bodySmall(AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 24),
            ],
            
            // Appearance Section
            _buildSectionHeader('Tampilan'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _SettingItem(
                icon: Icons.dark_mode_outlined,
                title: 'Mode Gelap',
                subtitle: 'Aktifkan tampilan gelap',
                trailing: Consumer<ThemeProvider>(
                  builder: (context, theme, _) {
                    return Switch(
                      value: theme.isDarkMode,
                      onChanged: (value) => theme.toggleTheme(),
                    );
                  },
                ),
              ),
              _SettingItem(
                icon: Icons.color_lens_outlined,
                title: 'Warna Aksen',
                subtitle: 'Hijau Neon',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // Notification Section
            _buildSectionHeader('Notifikasi'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _SettingItem(
                icon: Icons.notifications_outlined,
                title: 'Push Notification',
                subtitle: 'Terima notifikasi booking baru',
                trailing: Switch(value: true, onChanged: (_) {}),
              ),
              _SettingItem(
                icon: Icons.email_outlined,
                title: 'Email Notification',
                subtitle: 'Terima ringkasan harian',
                trailing: Switch(value: false, onChanged: (_) {}),
              ),
            ]),
            const SizedBox(height: 24),

            // General Section
            _buildSectionHeader('Umum'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _SettingItem(
                icon: Icons.language,
                title: 'Bahasa',
                subtitle: 'Indonesia',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.access_time,
                title: 'Zona Waktu',
                subtitle: 'WIB (UTC+7)',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.attach_money,
                title: 'Mata Uang',
                subtitle: 'IDR - Rupiah',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('Tentang'),
            const SizedBox(height: 8),
            _buildSettingsCard([
              _SettingItem(
                icon: Icons.info_outline,
                title: 'Versi Aplikasi',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan',
                onTap: () {},
              ),
              _SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Kebijakan Privasi',
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTypography.labelMedium(AppColors.textSecondaryDark),
    );
  }

  Widget _buildSettingsCard(List<_SettingItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Container(
              height: 1,
              margin: const EdgeInsets.only(left: 56),
              color: AppColors.borderDark,
            );
          }
          return items[index ~/ 2];
        }),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLightDark,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall(AppColors.textPrimaryDark),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.caption(AppColors.textSecondaryDark),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: AppColors.textTertiaryDark,
              ),
          ],
        ),
      ),
    );
  }
}
