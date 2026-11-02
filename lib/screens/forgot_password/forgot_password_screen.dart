import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/validators/validators.dart';
import '../../providers/forgot_password_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  var _autovalidateMode = AutovalidateMode.disabled;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Errors update live from now on, as the user fixes them.
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final provider = context.read<ForgotPasswordProvider>();
    final succeeded = await provider.sendResetLink(
      _emailController.text.trim(),
    );
    if (mounted && !succeeded) {
      showErrorSnackBar(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();
    final successMessage = provider.successMessage;

    return AuthLayout(
      icon: Icons.key_outlined,
      title: 'Forgot password?',
      subtitle: "Enter your email and we'll send you a reset link.",
      showBackButton: true,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: successMessage != null
            ? _buildConfirmation(successMessage)
            : _buildForm(provider.isLoading),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      autovalidateMode: _autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Email address',
            hint: 'you@example.com',
            controller: _emailController,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: Validators.email,
            enabled: !isLoading,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Send reset link',
            isLoading: isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation(String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.mark_email_read_outlined,
                color: AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.success),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
