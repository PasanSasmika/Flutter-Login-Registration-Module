import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The brand mark on a white tile.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: const ShieldMark(),
    );
  }
}

/// A shield with a tick. Drawn in code so the app, the launcher icon and the
/// native splash all use the same shape (see tool/generate_brand_assets.dart).
class ShieldMark extends StatelessWidget {
  const ShieldMark({
    super.key,
    this.shieldColor = AppColors.primary,
    this.tickColor = Colors.white,
  });

  final Color shieldColor;
  final Color tickColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShieldPainter(shieldColor, tickColor));
  }
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter(this.shieldColor, this.tickColor);

  final Color shieldColor;
  final Color tickColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final shield = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.66, h * 0.09, w * 0.82, h * 0.13, w * 0.96, h * 0.14)
      ..lineTo(w * 0.96, h * 0.5)
      ..cubicTo(w * 0.96, h * 0.76, w * 0.74, h * 0.92, w * 0.5, h)
      ..cubicTo(w * 0.26, h * 0.92, w * 0.04, h * 0.76, w * 0.04, h * 0.5)
      ..lineTo(w * 0.04, h * 0.14)
      ..cubicTo(w * 0.18, h * 0.13, w * 0.34, h * 0.09, w * 0.5, 0)
      ..close();
    canvas.drawPath(shield, Paint()..color = shieldColor);

    final tick = Path()
      ..moveTo(w * 0.29, h * 0.5)
      ..lineTo(w * 0.44, h * 0.65)
      ..lineTo(w * 0.72, h * 0.35);
    canvas.drawPath(
      tick,
      Paint()
        ..color = tickColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.1
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter oldDelegate) {
    return shieldColor != oldDelegate.shieldColor ||
        tickColor != oldDelegate.tickColor;
  }
}
