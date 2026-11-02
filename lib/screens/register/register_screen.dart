import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validators/validators.dart';
import '../../providers/register_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/password_strength_meter.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  var _autovalidateMode = AutovalidateMode.disabled;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Errors update live from now on, as the user fixes them.
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final provider = context.read<RegisterProvider>();
    final email = _emailController.text.trim();
    final succeeded = await provider.register(
      fullName: _nameController.text.trim(),
      email: email,
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (succeeded) {
      showSuccessSnackBar(context, provider.successMessage!);
      // Login prefills this email so the user can sign in straight away.
      Navigator.pop(context, email);
    } else {
      showErrorSnackBar(context, provider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegisterProvider>();
    final isLoading = provider.isLoading;

    return AuthLayout(
      title: 'Create account',
      subtitle: 'Fill in your details to get started.',
      showBackButton: true,
      // Leaving mid-request would let the success handler pop a second route.
      canPop: !isLoading,
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Full name',
                hint: 'Your full name',
                controller: _nameController,
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                validator: Validators.fullName,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email address',
                hint: 'you@example.com',
                controller: _emailController,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: Validators.email,
                errorText: provider.fieldError('email'),
                enabled: !isLoading,
                onChanged: (_) => provider.clearFieldError('email'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Mobile number',
                hint: '0771234567',
                controller: _mobileController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: Validators.mobile,
                errorText: provider.fieldError('mobile'),
                enabled: !isLoading,
                onChanged: (_) => provider.clearFieldError('mobile'),
              ),
              const SizedBox(height: 16),
              PasswordField(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordController,
                helperText:
                    'At least ${Validators.minPasswordLength} characters with '
                    'upper and lower case letters, a number and a symbol.',
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: Validators.newPassword,
                enabled: !isLoading,
              ),
              PasswordStrengthMeter(controller: _passwordController),
              const SizedBox(height: 16),
              PasswordField(
                label: 'Confirm password',
                hint: 'Re-enter your password',
                controller: _confirmPasswordController,
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Create account',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              AuthFooterLink(
                text: 'Already have an account?',
                actionLabel: 'Sign in',
                onPressed: isLoading ? null : () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
