import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/core.dart';

/// FutsalPro Custom Text Field Component
/// Animated text field with focus effects and validation
class ProTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;

  const ProTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<ProTextField> createState() => _ProTextFieldState();
}

class _ProTextFieldState extends State<ProTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  bool _isFocused = false;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.obscureText;

    _animationController = AnimationController(
      duration: AppSpacing.durationNormal,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _focusNode.removeListener(_handleFocusChange);
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label with animation
        if (widget.label != null) ...[
          AnimatedDefaultTextStyle(
            duration: AppSpacing.durationFast,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.errorText != null
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.primary
                      : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
            ),
            child: Text(widget.label!),
          ),
          const SizedBox(height: 8),
        ],

        // Input field with glow effect
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: AppSpacing.borderRadiusMd,
                boxShadow: widget.errorText != null
                    ? [
                        BoxShadow(
                          color: AppColors.error.withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 8 * _glowAnimation.value,
                          spreadRadius: 0,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2 * _glowAnimation.value),
                          blurRadius: 8 * _glowAnimation.value,
                          spreadRadius: 0,
                        ),
                      ],
              ),
              child: child,
            );
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              errorText: widget.errorText,
              counterText: '',
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 22,
                      color: widget.errorText != null
                          ? AppColors.error
                          : _isFocused
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 22,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
            ),
          ),
        ),

        // Helper text
        if (widget.helperText != null && widget.errorText == null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ],
    );
  }
}

/// Password field with strength indicator
class ProPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool showStrengthIndicator;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputAction? textInputAction;

  const ProPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.showStrengthIndicator = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  });

  @override
  State<ProPasswordField> createState() => _ProPasswordFieldState();
}

class _ProPasswordFieldState extends State<ProPasswordField> {
  double _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor = AppColors.error;

  void _calculateStrength(String password) {
    double strength = 0;
    
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _strength = strength;
      if (strength <= 0.25) {
        _strengthLabel = 'Lemah';
        _strengthColor = AppColors.error;
      } else if (strength <= 0.5) {
        _strengthLabel = 'Sedang';
        _strengthColor = AppColors.warning;
      } else if (strength <= 0.75) {
        _strengthLabel = 'Kuat';
        _strengthColor = AppColors.info;
      } else {
        _strengthLabel = 'Sangat Kuat';
        _strengthColor = AppColors.success;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ProTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          errorText: widget.errorText,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: widget.validator,
          textInputAction: widget.textInputAction,
          onChanged: (value) {
            if (widget.showStrengthIndicator) {
              _calculateStrength(value);
            }
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSubmitted,
        ),
        if (widget.showStrengthIndicator && _strength > 0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: AppSpacing.durationNormal,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _strength,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _strengthColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _strengthLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _strengthColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
