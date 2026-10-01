import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';

class SyncQueueScreen extends ConsumerWidget {
  const SyncQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final queue = repo.syncQueue();
    return Scaffold(
      appBar: AppBar(title: const Text('Offline sync queue')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text('${queue.length} pending upload(s)',
                      style: Theme.of(context).textTheme.titleMedium),
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
                  icon: const Icon(Icons.cloud_done),
                  label: const Text('Sync now'),
                ),
              ],
            ),
          ),
          Expanded(
            child: queue.isEmpty
                ? const Center(child: Text('Queue empty — drafts sync here when offline.'))
                : ListView.builder(
                    itemCount: queue.length,
                    itemBuilder: (_, i) {
                      final item = queue[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: Icon(
                            item.type == 'result'
                                ? Icons.how_to_vote
                                : item.type == 'incident'
                                    ? Icons.warning
                                    : Icons.door_front_door,
                            color: ApcColors.blue,
                          ),
                          title: Text(item.type.toUpperCase()),
                          subtitle: Text('Queued ${item.enqueuedAt.toLocal()}\n${item.id}',
                              style: const TextStyle(fontSize: 11)),
                          isThreeLine: true,
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
