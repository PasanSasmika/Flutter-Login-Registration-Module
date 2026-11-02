import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_info.dart';
import '../core/theme/app_colors.dart';
import 'app_logo.dart';

/// Shared page layout: a dark brand header with the content on a white sheet.
/// On tablets and the web the content becomes a centred card instead.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.leading,
    this.showBackButton = false,
    this.canPop = true,
  });

  static const _maxCardWidth = 460.0;
  static const _wideScreenBreakpoint = 600.0;
  static const _heroHeight = 380.0;

  final String title;
  final String subtitle;
  final Widget child;

  /// Shown above the title.
  final Widget? leading;
  final bool showBackButton;

  /// Set to false to hold the user here while a request finishes.
  final bool canPop;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= _wideScreenBreakpoint;

    return PopScope(
      canPop: canPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: isWide ? 0 : null,
                height: isWide ? null : _heroHeight,
                child: const HeroBackground(),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stays put while the form scrolls, so Back is always
                    // reachable.
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 20, 0),
                      child: _BrandRow(showBackButton: showBackButton),
                    ),
                    Expanded(
                      child: isWide
                          ? _CardLayout(
                              title: title,
                              subtitle: subtitle,
                              leading: leading,
                              child: child,
                            )
                          : _SheetLayout(
                              title: title,
                              subtitle: subtitle,
                              leading: leading,
                              child: child,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetLayout extends StatelessWidget {
  const _SheetLayout({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[leading!, const SizedBox(height: 16)],
                Text(
                  title,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _Reveal(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: child,
            ),
          ),
        ),
        // Extends the white sheet to the bottom of tall screens.
        const SliverFillRemaining(
          hasScrollBody: false,
          child: ColoredBox(color: AppColors.background),
        ),
      ],
    );
  }
}

class _CardLayout extends StatelessWidget {
  const _CardLayout({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final card = Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (leading != null) ...[
            Align(alignment: Alignment.centerLeft, child: leading),
            const SizedBox(height: 16),
          ],
          Text(title, style: textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: textTheme.bodyMedium),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AuthLayout._maxCardWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_Reveal(child: card)],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The brand gradient with two soft circles for depth.
class HeroBackground extends StatelessWidget {
  const HeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroStart, AppColors.heroEnd],
        ),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            _circle(top: -70, right: -50, size: 220, alpha: 0.07),
            _circle(top: 150, right: 60, size: 90, alpha: 0.05),
          ],
        ),
      ),
    );
  }

  Widget _circle({
    required double top,
    required double right,
    required double size,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.showBackButton});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          if (showBackButton) ...[
            const BackButton(color: Colors.white),
            const SizedBox(width: 4),
          ],
          const AppLogo(size: 34),
          const SizedBox(width: 10),
          Text(
            AppInfo.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades and slides its child up when the page opens.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 32),
            child: child,
          ),
        );
      },
    );
  }
}

/// "Question? Action" row at the bottom of the auth forms.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.text,
    required this.actionLabel,
    required this.onPressed,
  });

  final String text;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}
