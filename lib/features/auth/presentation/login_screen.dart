import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(repoInitProvider);
    final connected = ref.watch(connectionConnectedProvider);
    final connLabel = ref.watch(connectionStatusProvider);
    return Scaffold(
      body: SafeArea(
        child: init.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (repo) {
            final users = repo.demoUsers;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(AppConstants.cityBoyLogo, height: 56),
                    const SizedBox(width: 12),
                    Image.asset(AppConstants.apcLogo, height: 56),
                  ],
                ),
                const SizedBox(height: 16),
                Text(AppConstants.appTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text(AppConstants.appSubtitle, textAlign: TextAlign.center, style: const TextStyle(color: ApcColors.blue)),
                const SizedBox(height: 8),
                Center(
                  child: Chip(
                    avatar: Icon(
                      connected ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: connected ? ApcColors.green : ApcColors.brown,
                    ),
                    label: Text(connLabel, style: const TextStyle(fontSize: 12)),
                    backgroundColor: (connected ? ApcColors.green : ApcColors.brown).withValues(alpha: 0.15),
                    side: BorderSide(color: connected ? ApcColors.green : ApcColors.brown),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Demo login — pick a role (passwordless)',
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                ...users.map((u) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ApcColors.green.withValues(alpha: 0.3),
                          child: Text(u.fullName.characters.first,
                              style: const TextStyle(color: ApcColors.green, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(u.fullName),
                        subtitle: Text('${AppRoles.label(u.role)}\n${u.email}',
                            style: const TextStyle(fontSize: 12)),
                        isThreeLine: true,
                        trailing: const Icon(Icons.login, color: ApcColors.blue),
                        onTap: () async {
                          await ref.read(sessionProvider.notifier).login(u);
                        },
                      ),
                    )),
                TextButton(
                  onPressed: () => context.push('/forgot'),
                  child: const Text('Forgot password?', style: TextStyle(color: ApcColors.brown)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
