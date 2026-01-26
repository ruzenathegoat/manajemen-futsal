import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/widgets.dart';

/// FutsalPro Register Screen
/// Modern, animated registration with dark theme design
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Nama tidak boleh kosong';
      } else if (value.length < 3) {
        _nameError = 'Nama minimal 3 karakter';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Email tidak boleh kosong';
      } else if (!value.contains('@') || !value.contains('.')) {
        _emailError = 'Format email tidak valid';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Password tidak boleh kosong';
      } else if (value.length < 6) {
        _passwordError = 'Password minimal 6 karakter';
      } else {
        _passwordError = null;
      }
      // Re-validate confirm password if it has value
      if (_confirmPasswordController.text.isNotEmpty) {
        _validateConfirmPassword(_confirmPasswordController.text);
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Konfirmasi password tidak boleh kosong';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Password tidak sama';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _handleRegister() async {
    // Validate all fields
    _validateName(_nameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    if (!_agreeToTerms) {
      _showErrorSnackbar('Anda harus menyetujui syarat dan ketentuan');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Registrasi berhasil! Silakan login.');
      Navigator.pop(context);
    } else {
      _showErrorSnackbar(authProvider.errorMessage ?? 'Registrasi gagal');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              _buildAppBar(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? size.width * 0.2 : 24,
                    vertical: 16,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: child,
                          ),
                        );
                      },
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header text
                            _buildHeader(),
                            const SizedBox(height: 32),

                            // Name field
                            ProTextField(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              label: 'Nama Lengkap',
                              hint: 'Masukkan nama lengkap anda',
                              prefixIcon: Icons.person_outline,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              errorText: _nameError,
                              onChanged: _validateName,
                              onSubmitted: (_) {
                                _emailFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 20),

                            // Email field
                            ProTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              label: 'Email',
                              hint: 'Masukkan email anda',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              errorText: _emailError,
                              onChanged: _validateEmail,
                              onSubmitted: (_) {
                                _passwordFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 20),

                            // Password field with strength indicator
                            ProPasswordField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: 'Buat password anda',
                              errorText: _passwordError,
                              showStrengthIndicator: true,
                              textInputAction: TextInputAction.next,
                              onChanged: _validatePassword,
                              onSubmitted: (_) {
                                _confirmPasswordFocusNode.requestFocus();
                              },
                            ),
                            const SizedBox(height: 20),

                            // Confirm password field
                            ProTextField(
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              label: 'Konfirmasi Password',
                              hint: 'Ulangi password anda',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              errorText: _confirmPasswordError,
                              onChanged: _validateConfirmPassword,
                              onSubmitted: (_) => _handleRegister(),
                            ),
                            const SizedBox(height: 24),

                            // Terms and conditions
                            _buildTermsCheckbox(),
                            const SizedBox(height: 24),

                            // Register button
                            ProButton(
                              text: 'DAFTAR',
                              onPressed:
                                  authProvider.isLoading ? null : _handleRegister,
                              isLoading: authProvider.isLoading,
                              isExpanded: true,
                              size: ProButtonSize.large,
                            ),
                            const SizedBox(height: 24),

                            // Login link
                            _buildLoginLink(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimaryDark,
              ),
            ),
          ),
          const Spacer(),
          // Progress indicator
          Row(
            children: [
              _ProgressDot(isActive: true),
              const SizedBox(width: 8),
              _ProgressDot(isActive: false),
            ],
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Akun Baru',
          style: AppTypography.headlineMedium(AppColors.textPrimaryDark),
        ),
        const SizedBox(height: 8),
        Text(
          'Daftar untuk mulai memesan lapangan futsal',
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _agreeToTerms = !_agreeToTerms;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: AppSpacing.durationFast,
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _agreeToTerms ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _agreeToTerms ? AppColors.primary : AppColors.borderDark,
                width: 2,
              ),
            ),
            child: _agreeToTerms
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.black,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'Saya menyetujui ',
                style: AppTypography.bodySmall(AppColors.textSecondaryDark),
                children: [
                  TextSpan(
                    text: 'Syarat & Ketentuan',
                    style: AppTypography.bodySmall(AppColors.primary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' dan '),
                  TextSpan(
                    text: 'Kebijakan Privasi',
                    style: AppTypography.bodySmall(AppColors.primary).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: AppTypography.bodyMedium(AppColors.textSecondaryDark),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Masuk',
            style: AppTypography.bodyMedium(AppColors.primary).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressDot extends StatelessWidget {
  final bool isActive;

  const _ProgressDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppSpacing.durationFast,
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceLightDark,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
