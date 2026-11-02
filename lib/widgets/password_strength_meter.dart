import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/validators/validators.dart';

/// A four-segment bar that updates as the user types a new password.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.controller});

  final TextEditingController controller;

  static const _segments = 4;

  /// Maps the number of rules met (0 to 5) to filled segments and a label.
  static (int, String, Color) _levelFor(int rulesMet) {
    return switch (rulesMet) {
      5 => (4, 'Strong', AppColors.success),
      4 => (3, 'Good', AppColors.info),
      3 => (2, 'Fair', AppColors.warning),
      _ => (1, 'Weak', AppColors.error),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.text.isEmpty) return const SizedBox.shrink();

        final (filled, label, color) = _levelFor(
          Validators.passwordStrength(value.text),
        );

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              for (var i = 0; i < _segments; i++)
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 5,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: i < filled ? color : AppColors.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
