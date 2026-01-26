import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// FutsalPro Page Transitions
/// Custom page route transitions for smooth navigation

/// Fade transition route
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: AppSpacing.durationNormal,
          reverseTransitionDuration: AppSpacing.durationNormal,
        );
}

/// Slide fade transition route (default)
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = _getOffset(direction);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: Curves.easeOutCubic),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );

  static Offset _getOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(-1.0, 0.0);
      case SlideDirection.right:
        return const Offset(1.0, 0.0);
      case SlideDirection.up:
        return const Offset(0.0, 1.0);
      case SlideDirection.down:
        return const Offset(0.0, -1.0);
    }
  }
}

enum SlideDirection { left, right, up, down }

/// Scale fade transition route
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: AppSpacing.durationNormal,
          reverseTransitionDuration: AppSpacing.durationNormal,
        );
}

/// Shared axis transition (Material Design)
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisType type;

  SharedAxisPageRoute({
    required this.page,
    this.type = SharedAxisType.horizontal,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );

            return FadeTransition(
              opacity: curvedAnimation,
              child: _buildSlide(type, curvedAnimation, child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );

  static Widget _buildSlide(
    SharedAxisType type,
    Animation<double> animation,
    Widget child,
  ) {
    Offset begin;
    switch (type) {
      case SharedAxisType.horizontal:
        begin = const Offset(0.1, 0.0);
        break;
      case SharedAxisType.vertical:
        begin = const Offset(0.0, 0.1);
        break;
      case SharedAxisType.scaled:
        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
          child: child,
        );
    }

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(animation),
      child: child,
    );
  }
}

enum SharedAxisType { horizontal, vertical, scaled }

/// Modal page route (slides from bottom)
class ModalPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool fullscreen;

  ModalPageRoute({
    required this.page,
    this.fullscreen = true,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          opaque: fullscreen,
          barrierColor: fullscreen ? null : Colors.black54,
          barrierDismissible: !fullscreen,
        );
}

/// Extension for easy navigation with transitions
extension NavigationExtensions on NavigatorState {
  Future<T?> pushFade<T>(Widget page) {
    return push(FadePageRoute<T>(page: page));
  }

  Future<T?> pushSlide<T>(Widget page, {SlideDirection direction = SlideDirection.right}) {
    return push(SlidePageRoute<T>(page: page, direction: direction));
  }

  Future<T?> pushScale<T>(Widget page) {
    return push(ScalePageRoute<T>(page: page));
  }

  Future<T?> pushModal<T>(Widget page, {bool fullscreen = true}) {
    return push(ModalPageRoute<T>(page: page, fullscreen: fullscreen));
  }
}

/// Extension on BuildContext for even easier navigation
extension ContextNavigationExtensions on BuildContext {
  Future<T?> navigateTo<T>(Widget page, {PageTransitionType type = PageTransitionType.slide}) {
    switch (type) {
      case PageTransitionType.fade:
        return Navigator.of(this).push(FadePageRoute<T>(page: page));
      case PageTransitionType.slide:
        return Navigator.of(this).push(SlidePageRoute<T>(page: page));
      case PageTransitionType.scale:
        return Navigator.of(this).push(ScalePageRoute<T>(page: page));
      case PageTransitionType.modal:
        return Navigator.of(this).push(ModalPageRoute<T>(page: page));
    }
  }

  void goBack<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}

enum PageTransitionType { fade, slide, scale, modal }
