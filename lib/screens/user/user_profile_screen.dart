import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/widgets.dart';

/// FutsalPro User Profile Screen
/// Redesigned profile with modern dark theme
class UserProfileScreen extends StatefulWidget {
  final bool embedded;
  
  const UserProfileScreen({super.key, this.embedded = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    _nameController.text = user?.name ?? '';
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.userModel;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: widget.embedded ? null : const ProAppBar(title: 'Profil'),
      body: SafeArea(
        top: widget.embedded,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.embedded)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Profil',
                        style: AppTypography.headlineMedium(AppColors.textPrimaryDark),
                      ),
                      // Theme toggle
                      GestureDetector(
                        onTap: () => themeProvider.toggleTheme(),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: AppSpacing.borderRadiusMd,
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Icon(
                            themeProvider.isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Profile header card
              _buildProfileHeader(user),
              const SizedBox(height: 16),

              // Menu items
              _buildMenuSection(),
              const SizedBox(height: 16),

              // Settings section
              _buildSettingsSection(themeProvider),
              const SizedBox(height: 16),

              // Logout button
              _buildLogoutButton(authProvider),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceDark,
            AppColors.surfaceLightDark,
          ],
        ),
        borderRadius: AppSpacing.borderRadiusXl,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              ProAvatar(
                imageUrl: user?.photoUrl,
                name: user?.name ?? 'User',
                size: ProAvatarSize.xxl,
                showBorder: true,
                borderColor: AppColors.primary,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name with edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user?.name ?? 'User',
                style: AppTypography.headlineSmall(AppColors.textPrimaryDark),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showEditNameDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 12),

          // Role badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: AppSpacing.borderRadiusRound,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
              ),
            ),
            child: Text(
              user?.role?.toUpperCase() ?? 'USER',
              style: AppTypography.labelSmall(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun anda',
            onTap: _showChangePasswordDialog,
          ),
          _MenuDivider(),
          _MenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'FAQ dan kontak support',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          _MenuItemSwitch(
            icon: Icons.dark_mode_outlined,
            title: 'Mode Gelap',
            subtitle: 'Aktifkan tampilan gelap',
            value: themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
          _MenuDivider(),
          _MenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifikasi',
            subtitle: 'Atur preferensi notifikasi',
            onTap: () {},
          ),
          _MenuDivider(),
          _MenuItem(
            icon: Icons.info_outline,
            title: 'Tentang Aplikasi',
            subtitle: 'Versi 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ProButton(
        text: 'Keluar',
        variant: ProButtonVariant.outlined,
        leadingIcon: Icons.logout,
        isExpanded: true,
        onPressed: () => _showLogoutDialog(authProvider),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textTertiaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _PhotoOption(
              icon: Icons.photo_library,
              title: 'Pilih dari Galeri',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            _PhotoOption(
              icon: Icons.camera_alt,
              title: 'Ambil Foto',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            _PhotoOption(
              icon: Icons.link,
              title: 'Masukkan URL',
              onTap: () {
                Navigator.pop(context);
                _showPhotoUrlDialog();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        _showPhotoUrlDialog();
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showPhotoUrlDialog() {
    final photoUrlController = TextEditingController();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    photoUrlController.text = user?.photoUrl ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Update Foto Profil',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: ProTextField(
          controller: photoUrlController,
          label: 'URL Foto',
          hint: 'https://example.com/photo.jpg',
          prefixIcon: Icons.link,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (photoUrlController.text.isNotEmpty) {
                await _updatePhoto(photoUrlController.text);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePhoto(String url) async {
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      if (user != null) {
        await _firestoreService.updateUserProfile(user.uid, {'photoUrl': url});
        await Provider.of<AuthProvider>(context, listen: false).checkCurrentUser();
        _showSuccess('Foto profil berhasil diperbarui');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showEditNameDialog() {
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    _nameController.text = user?.name ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Edit Nama',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: Form(
          key: _nameFormKey,
          child: ProTextField(
            controller: _nameController,
            label: 'Nama',
            hint: 'Masukkan nama anda',
            prefixIcon: Icons.person_outline,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: _updateName,
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateName() async {
    if (_nameController.text.isEmpty) return;
    
    try {
      final user = Provider.of<AuthProvider>(context, listen: false).userModel;
      if (user != null) {
        await _firestoreService.updateUserProfile(user.uid, {
          'name': _nameController.text.trim(),
        });
        await Provider.of<AuthProvider>(context, listen: false).checkCurrentUser();
        if (mounted) {
          Navigator.pop(context);
          _showSuccess('Nama berhasil diperbarui');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Ubah Password',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProTextField(
                  controller: _currentPasswordController,
                  label: 'Password Saat Ini',
                  hint: 'Masukkan password saat ini',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ProPasswordField(
                  controller: _newPasswordController,
                  label: 'Password Baru',
                  hint: 'Masukkan password baru',
                  showStrengthIndicator: true,
                ),
                const SizedBox(height: 16),
                ProTextField(
                  controller: _confirmPasswordController,
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password baru',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showError('Semua field harus diisi');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showError('Password baru tidak sama');
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cred = firebase_auth.EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(_newPasswordController.text);
        
        if (mounted) {
          Navigator.pop(context);
          _showSuccess('Password berhasil diperbarui');
        }
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLogoutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusXl,
        ),
        title: Text(
          'Keluar?',
          style: AppTypography.titleLarge(AppColors.textPrimaryDark),
        ),
        content: Text(
          'Apakah anda yakin ingin keluar dari aplikasi?',
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tidak',
              style: AppTypography.buttonMedium(AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLightDark,
                borderRadius: AppSpacing.borderRadiusMd,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
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
                  Text(
                    subtitle,
                    style: AppTypography.caption(AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
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

class _MenuItemSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MenuItemSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightDark,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
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
                Text(
                  subtitle,
                  style: AppTypography.caption(AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 68),
      color: AppColors.borderDark,
    );
  }
}

class _PhotoOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PhotoOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightDark,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: AppTypography.titleSmall(AppColors.textPrimaryDark),
      ),
      onTap: onTap,
    );
  }
}
