// Renders the launcher icon and splash images from the ShieldMark widget.
// Run with: flutter test tool/generate_brand_assets.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_login_registration/core/theme/app_colors.dart';
import 'package:flutter_login_registration/widgets/app_logo.dart';
import 'package:flutter_test/flutter_test.dart';

const canvasSize = 1024.0;

Widget centred(double size, Widget child) {
  return Center(
    child: SizedBox.square(dimension: size, child: child),
  );
}

Future<void> render(WidgetTester tester, String name, Widget child) async {
  final boundary = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: RepaintBoundary(key: boundary, child: child),
    ),
  );

  await tester.runAsync(() async {
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(
      'assets/brand/$name.png',
    ).writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('generate brand assets', (tester) async {
    tester.view.physicalSize = const Size.square(canvasSize);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const whiteShield = ShieldMark(
      shieldColor: Colors.white,
      tickColor: AppColors.primary,
    );

    await render(
      tester,
      'app_icon',
      DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.heroStart, AppColors.heroEnd],
          ),
        ),
        child: centred(600, whiteShield),
      ),
    );

    // Android crops adaptive icons, so this one needs a wider margin.
    await render(tester, 'app_icon_foreground', centred(440, whiteShield));

    // Same margin rule for the Android 12 splash, which crops to a circle.
    await render(tester, 'splash_logo', centred(500, const AppLogo(size: 500)));
  });
}
