import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _nameController.text = user.name;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 20),
              
              // Avatar (without photo upload - no Firebase Storage)
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Name field
              CustomTextField(
                label: 'Nama',
                controller: _nameController,
                onSubmitted: (_) => _updateName(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _updateName,
                  child: const Text('Simpan Nama'),
                ),
              ),
              const SizedBox(height: 12),
              
              // Email field (read-only)
              CustomTextField(
                label: 'Email',
                initialValue: user.email,
                readOnly: true,
                enabled: false,
              ),
              const SizedBox(height: 24),
              
              // Theme section
              _buildSectionTitle('Tema', isDark),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Light',
                      variant: themeProvider.themeMode == ThemeMode.light
                          ? ButtonVariant.primary
                          : ButtonVariant.outline,
                      onPressed: () => _setThemePreference(
                        themeProvider,
                        ThemeMode.light,
                        'light',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Dark',
                      variant: themeProvider.themeMode == ThemeMode.dark
                          ? ButtonVariant.primary
                          : ButtonVariant.outline,
                      onPressed: () => _setThemePreference(
                        themeProvider,
                        ThemeMode.dark,
                        'dark',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'System',
                variant: themeProvider.themeMode == ThemeMode.system
                    ? ButtonVariant.primary
                    : ButtonVariant.outline,
                onPressed: () => _setThemePreference(
                  themeProvider,
                  ThemeMode.system,
                  'system',
                ),
                isFullWidth: true,
              ),
              const SizedBox(height: 24),
              
              // Account section
              _buildSectionTitle('Akun', isDark),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Ubah Password',
                variant: ButtonVariant.outline,
                isFullWidth: true,
                onPressed: () => _showChangePasswordDialog(context),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Logout',
                isFullWidth: true,
                onPressed: () => authProvider.logout(),
                customColor: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Future<void> _updateName() async {
    final authProvider = context.read<AuthProvider>();
    if (_nameController.text.trim().isEmpty) return;
    
    final success = await authProvider.updateProfile(name: _nameController.text.trim());
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Nama berhasil diperbarui' : 'Gagal memperbarui nama'),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _setThemePreference(
    ThemeProvider themeProvider,
    ThemeMode mode,
    String preference,
  ) async {
    final authProvider = context.read<AuthProvider>();
    await themeProvider.setTheme(mode);
    if (!mounted) return;
    await authProvider.updateProfile(themePreference: preference);
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final authProvider = context.read<AuthProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubah Password'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Password Saat Ini',
                  controller: currentController,
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Password Baru',
                  controller: newController,
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      if (!mounted) return;
      
      final success = await authProvider.changePassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
      );
      
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(success ? 'Password berhasil diubah' : (authProvider.error ?? 'Gagal mengubah password')),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
