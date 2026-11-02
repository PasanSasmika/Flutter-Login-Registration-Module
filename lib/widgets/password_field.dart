import 'package:flutter/material.dart';

import 'custom_text_field.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.helperText,
    this.textInputAction = TextInputAction.done,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final String? helperText;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isHidden = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      icon: Icons.lock_outline_rounded,
      validator: widget.validator,
      helperText: widget.helperText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      obscureText: _isHidden,
      enabled: widget.enabled,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _isHidden ? 'Show password' : 'Hide password',
        icon: Icon(
          _isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          size: 20,
        ),
        onPressed: () => setState(() => _isHidden = !_isHidden),
      ),
    );
  }
}
