import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Where the user lands after signing in.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
    authProvider.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    // The user is cleared on sign out, just before this screen is removed.
    if (user == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Hello, ${user.firstName}',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'You are signed in.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _DetailTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Full name',
                        value: user.fullName,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _DetailTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email',
                        value: user.email,
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _DetailTile(
                        icon: Icons.phone_outlined,
                        label: 'Mobile',
                        value: user.mobile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => _logout(context),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      subtitle: Text(value, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
