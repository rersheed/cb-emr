import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final queue = repo.syncQueue();
    return Scaffold(
      backgroundColor: ApcColors.surface,
      appBar: AppBar(title: const Text('Offline sync queue')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: Text('${queue.length} pending upload(s)',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  FilledButton.icon(
                    onPressed: queue.isEmpty
                        ? null
                        : () async {
                            final n = await repo.syncPending();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Synced $n item(s) into demo store')),
                              );
                            }
                          },
                    icon: const Icon(Icons.cloud_done_rounded),
                    label: const Text('Sync now'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: queue.isEmpty
                ? const Center(
                    child: Text('Queue empty — drafts sync here when offline.',
                        style: TextStyle(color: ApcColors.muted)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: queue.length,
                    itemBuilder: (_, i) {
                      final item = queue[i];
                      return SoftCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: EdgeInsets.zero,
                        child: ListTile(
                          leading: Icon(
                            item.type == 'result'
                                ? Icons.how_to_vote
                                : item.type == 'incident'
                                    ? Icons.warning
                                    : Icons.door_front_door,
                            color: ApcColors.blue,
                          ),
                          title: Text(item.type, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text(item.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
