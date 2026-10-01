import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';

class ApprovalQueueScreen extends ConsumerStatefulWidget {
  const ApprovalQueueScreen({super.key});
  @override
  ConsumerState<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends ConsumerState<ApprovalQueueScreen> {
  final reasonCtrl = TextEditingController();

  @override
  void dispose() {
    reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final user = repo.currentUser;
    if (user == null) return const SizedBox.shrink();

    final queueStatus = ResultStatus.expectedQueueStatusForRole(user.role) ?? ResultStatus.pendingWard;
    List<PollingResult> queue;
    if (user.role == AppRoles.superAdmin) {
      queue = repo.results().where((r) =>
          r.status == ResultStatus.pendingWard ||
          r.status == ResultStatus.pendingLga ||
          r.status == ResultStatus.pendingState).toList();
    } else if (user.role == AppRoles.wardSupervisor) {
      queue = repo.results(status: ResultStatus.pendingWard, wardId: user.wardId);
    } else if (user.role == AppRoles.lgaSupervisor) {
      queue = repo.results(status: ResultStatus.pendingLga, lgaId: user.lgaId);
    } else if (user.role == AppRoles.stateSupervisor) {
      queue = repo.results(status: ResultStatus.pendingState, stateId: user.stateId);
    } else {
      queue = repo.results(status: queueStatus);
    }

    final title = switch (user.role) {
      AppRoles.wardSupervisor => 'Ward approval queue',
      AppRoles.lgaSupervisor => 'LGA approval queue',
      AppRoles.stateSupervisor => 'State approval queue',
      AppRoles.superAdmin => 'Supervisor queue (all pending)',
      _ => 'Approval queue',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (user.role == AppRoles.superAdmin || user.role == AppRoles.stateSupervisor)
            IconButton(
              tooltip: 'Situation Room',
              onPressed: () => context.push('/situation-room'),
              icon: const Icon(Icons.monitor_heart_outlined),
            ),
          IconButton(
            onPressed: () => context.push('/offline'),
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
          IconButton(
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: queue.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox, size: 48, color: Colors.white38),
                  const SizedBox(height: 8),
                  Text('No items in ${ResultStatus.label(queueStatus)}'),
                  const SizedBox(height: 8),
                  Text(user.fullName, style: const TextStyle(color: ApcColors.blue)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: queue.length,
              itemBuilder: (_, i) {
                final r = queue[i];
                final total = r.totalPartyVotes;
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.puName ?? r.pollingUnitId,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('${ResultStatus.label(r.status)} · Total votes: $total · Accredited: ${r.accreditedVoters}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: r.partyVotes.entries
                              .map((e) => Chip(label: Text('${e.key.toUpperCase()}: ${e.value}')))
                              .toList(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () async {
                                  try {
                                    await repo.approveResult(r.id);
                                    // ignore: use_build_context_synchronously
    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Approved → ${ResultStatus.label(ResultStatus.nextOnApprove(r.status) ?? '')}')),
                                      );
                                    }
                                  } catch (e) {
                                    // ignore: use_build_context_synchronously
    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                                    }
                                  }
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _rejectDialog(repo, r),
                                icon: const Icon(Icons.close, color: ApcColors.red),
                                label: const Text('Reject', style: TextStyle(color: ApcColors.red)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _rejectDialog(dynamic repo, PollingResult r) async {
    reasonCtrl.clear();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject result'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason (required)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: ApcColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (ok == true && reasonCtrl.text.trim().isNotEmpty) {
      await repo.rejectResult(r.id, reason: reasonCtrl.text.trim());
      // ignore: use_build_context_synchronously
    if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
      }
    }
  }
}
