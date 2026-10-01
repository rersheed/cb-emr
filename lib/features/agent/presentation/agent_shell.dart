import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';

class AgentShell extends ConsumerWidget {
  const AgentShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final user = repo.currentUser;
    if (user == null) return const SizedBox.shrink();
    final units = repo.assignedUnitsFor(user);
    final mine = repo.results(submittedBy: user.id);
    final submitted = mine.where((r) => r.status != ResultStatus.draft).length;
    final pending = mine.where((r) =>
        r.status == ResultStatus.pendingWard ||
        r.status == ResultStatus.pendingLga ||
        r.status == ResultStatus.pendingState).length;
    final approved = mine.where((r) => r.status == ResultStatus.stateVerified).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Offline sync',
            onPressed: () => context.push('/offline'),
            icon: Badge(
              isLabelVisible: repo.syncQueue().isNotEmpty,
              label: Text('${repo.syncQueue().length}'),
              child: const Icon(Icons.cloud_upload_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hello, ${user.fullName}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(AppRoles.label(user.role), style: const TextStyle(color: ApcColors.blue)),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(label: 'Assigned', value: '${units.length}', color: ApcColors.blue),
              _StatCard(label: 'Submitted', value: '$submitted', color: ApcColors.brown),
              _StatCard(label: 'Pending', value: '$pending', color: Colors.orange),
              _StatCard(label: 'Approved', value: '$approved', color: ApcColors.green),
            ],
          ),
          const SizedBox(height: 20),
          Text('Assigned polling units', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...units.map((pu) {
            final r = mine.where((x) => x.pollingUnitId == pu.id).toList();
            final status = r.isEmpty ? 'No result' : ResultStatus.label(r.last.status);
            return Card(
              child: ListTile(
                title: Text(pu.name),
                subtitle: Text('Code ${pu.code} · $status'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/agent/pu/${pu.id}'),
              ),
            );
          }),
          if (units.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No PUs assigned to this demo agent.'),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}
