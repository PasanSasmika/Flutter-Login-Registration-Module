import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/validators/validators.dart';
import '../../providers/login_provider.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/auth_layout.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/password_field.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  var _autovalidateMode = AutovalidateMode.disabled;
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillRememberedIdentifier();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fillRememberedIdentifier() async {
    final identifier = await context
        .read<LoginProvider>()
        .loadRememberedIdentifier();
    if (mounted && identifier != null) {
      _identifierController.text = identifier;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      // Errors update live from now on, as the user fixes them.
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    final provider = context.read<LoginProvider>();
    final succeeded = await provider.login(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;

    if (succeeded) {
      showSuccessSnackBar(context, provider.successMessage!);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      showErrorSnackBar(context, provider.errorMessage!);
    }
  }

  Future<void> _openRegister() async {
    final result = await Navigator.pushNamed(context, AppRoutes.register);
    if (result is String) {
      _identifierController.text = result;
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoginProvider>();
    final isLoading = provider.isLoading;

    return AuthLayout(
      icon: Icons.lock_person_outlined,
      title: 'Welcome back',
      subtitle: 'Sign in to your account to continue.',
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Email or mobile number',
                hint: 'you@example.com',
                controller: _identifierController,
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                validator: Validators.emailOrMobile,
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              PasswordField(
                label: 'Password',
                hint: 'Enter your password',
                controller: _passwordController,
                autofillHints: const [AutofillHints.password],
                validator: Validators.requiredPassword,
                enabled: !isLoading,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 4),
              // Wraps onto two lines on narrow screens or with large text.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isLoading
                        ? null
                        : () => provider.setRememberMe(!provider.rememberMe),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: provider.rememberMe,
                          onChanged: isLoading
                              ? null
                              : (value) =>
                                    provider.setRememberMe(value ?? false),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Text('Remember me'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          ),
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              AuthFooterLink(
                text: "Don't have an account?",
                actionLabel: 'Create account',
                onPressed: isLoading ? null : _openRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
