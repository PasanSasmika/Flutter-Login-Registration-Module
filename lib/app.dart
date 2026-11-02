import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/forgot_password_provider.dart';
import 'providers/login_provider.dart';
import 'providers/register_provider.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/register/register_screen.dart';
import 'services/auth_service.dart';

class App extends StatelessWidget {
  const App({super.key, required this.authService});

  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authService),
      child: MaterialApp(
        title: 'Login & Registration',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        // Form providers are created per route, so their state is reset
        // whenever the user leaves a screen.
        routes: {
          AppRoutes.login: (_) => ChangeNotifierProvider(
            create: (context) => LoginProvider(context.read<AuthProvider>()),
            child: const LoginScreen(),
          ),
          AppRoutes.register: (_) => ChangeNotifierProvider(
            create: (context) => RegisterProvider(context.read<AuthProvider>()),
            child: const RegisterScreen(),
          ),
          AppRoutes.forgotPassword: (_) => ChangeNotifierProvider(
            create: (context) =>
                ForgotPasswordProvider(context.read<AuthProvider>()),
            child: const ForgotPasswordScreen(),
          ),
          AppRoutes.home: (_) => const HomeScreen(),
        },
      ),
    );
  }
}
