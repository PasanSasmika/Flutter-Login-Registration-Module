import 'package:flutter/material.dart';

import 'loading_indicator.dart';

/// Full-width button that shows a spinner and ignores taps while [isLoading].
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isLoading
            ? const LoadingIndicator(color: Colors.white)
            : Text(label),
      ),
    );
  }
}
