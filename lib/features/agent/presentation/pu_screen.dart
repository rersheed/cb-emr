import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';

class PuScreen extends ConsumerWidget {
  const PuScreen({super.key, required this.puId});
  final String puId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final resolved = repo.resolvePu(puId);
    if (resolved == null) {
      return Scaffold(appBar: AppBar(title: const Text('PU')), body: const Center(child: Text('PU not found')));
    }
    final pu = resolved.pu;
    return Scaffold(
      appBar: AppBar(title: Text(pu.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('${resolved.state.name} › ${resolved.lga.name}'),
              subtitle: Text('Ward: ${resolved.ward.name}\nPU code: ${pu.code}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.door_front_door,
            title: 'Opening report',
            color: ApcColors.blue,
            onTap: () => context.push('/agent/opening/$puId'),
          ),
          _ActionTile(
            icon: Icons.warning_amber,
            title: 'Report incident',
            color: ApcColors.red,
            onTap: () => context.push('/agent/incident/$puId'),
          ),
          _ActionTile(
            icon: Icons.how_to_vote,
            title: 'Enter results',
            color: ApcColors.green,
            onTap: () => context.push('/agent/result/$puId'),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.2), child: Icon(icon, color: color)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
