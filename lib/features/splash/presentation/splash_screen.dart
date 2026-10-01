import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(repoInitProvider.future);
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    final init = ref.watch(repoInitProvider);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [ApcColors.dark, Color(0xFF0F3D24), ApcColors.dark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppConstants.cityBoyLogo, height: 88),
                const SizedBox(width: 16),
                Image.asset(AppConstants.apcLogo, height: 88),
              ],
            ),
            const SizedBox(height: 28),
            Text(AppConstants.appTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ApcColors.white,
                    )),
            const SizedBox(height: 8),
            Text(AppConstants.appSubtitle,
                style: TextStyle(color: ApcColors.blue.withValues(alpha: 0.95))),
            const SizedBox(height: 32),
            init.when(
              data: (_) => const SizedBox.shrink(),
              loading: () => const CircularProgressIndicator(color: ApcColors.green),
              error: (e, _) => Text('Init error: $e', style: const TextStyle(color: ApcColors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
