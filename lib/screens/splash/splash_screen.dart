import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/app_routes.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/auth_layout.dart';

/// Picks up from the native splash, which shows the same logo on the same
/// colour, then moves on to login when the animation ends.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );

  late final _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
    CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
    ),
  );

  late final _textOpacity = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.3, 0.65, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            const HeroBackground(),
            // Scales down rather than overflowing in very short windows.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: const AppLogo(size: 96),
                  ),
                  const SizedBox(height: 22),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: Column(
                      children: [
                        Text(
                          AppInfo.name,
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppInfo.tagline,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
