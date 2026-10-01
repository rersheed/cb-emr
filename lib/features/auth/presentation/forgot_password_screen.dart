import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Password reset is not available in the local demo. '
              'Use the role picker on the login screen. When Supabase Auth is wired, '
              'this screen will send a reset email.',
            ),
            const SizedBox(height: 24),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo stub — no email sent.')),
                );
              },
              child: const Text('Send reset link (stub)'),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to login', style: TextStyle(color: ApcColors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
