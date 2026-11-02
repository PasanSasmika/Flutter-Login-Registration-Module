import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

void showSuccessSnackBar(BuildContext context, String message) {
  _show(context, message, AppColors.success, Icons.check_circle_outline);
}

void showErrorSnackBar(BuildContext context, String message) {
  _show(context, message, AppColors.error, Icons.error_outline);
}

void _show(BuildContext context, String message, Color color, IconData icon) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
}
