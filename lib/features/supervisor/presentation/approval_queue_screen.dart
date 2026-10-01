import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class ApprovalQueueScreen extends ConsumerStatefulWidget {
  const ApprovalQueueScreen({super.key});
  @override
  ConsumerState<ApprovalQueueScreen> createState() => _ApprovalQueueScreenState();
}

class _ApprovalQueueScreenState extends ConsumerState<ApprovalQueueScreen> {
  final reasonCtrl = TextEditingController();
  int navIndex = 0;

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
      AppRoles.superAdmin => 'Supervisor queue',
      _ => 'Approval queue',
    };

    return Scaffold(
      backgroundColor: ApcColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text('${user.fullName} · ${AppRoles.label(user.role)}',
                            style: const TextStyle(color: ApcColors.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (user.role == AppRoles.superAdmin || user.role == AppRoles.stateSupervisor)
                    IconButton(
                      tooltip: 'Situation Room',
                      onPressed: () => context.push('/situation-room'),
                      icon: const Icon(Icons.monitor_heart_outlined, color: ApcColors.green),
                    ),
                  IconButton(
                    onPressed: () => context.push('/offline'),
                    icon: const Icon(Icons.cloud_upload_outlined),
                  ),
                  IconButton(
                    onPressed: () => ref.read(sessionProvider.notifier).logout(),
                    icon: const Icon(Icons.logout_rounded, color: ApcColors.muted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                children: [
                  SoftCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Approval chain',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 12),
                        ApprovalTimeline(currentStatus: queueStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    queue.isEmpty ? 'Queue empty' : '${queue.length} pending item(s)',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (queue.isEmpty)
                    SoftCard(
                      child: Column(
                        children: [
                          Icon(Icons.inbox_rounded, size: 48, color: ApcColors.muted.withValues(alpha: 0.5)),
                          const SizedBox(height: 8),
                          Text('No items in ${ResultStatus.label(queueStatus)}',
                              style: const TextStyle(color: ApcColors.muted)),
                        ],
                      ),
                    ),
                  for (final r in queue)
                    SoftCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.puName ?? r.pollingUnitId,
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: ApcColors.blueSoft,
                                  borderRadius: BorderRadius.circular(AppRadii.pill),
                                ),
                                child: Text(ResultStatus.label(r.status),
                                    style: const TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w700, color: ApcColors.blue)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Total votes: ${r.totalPartyVotes} · Accredited: ${r.accreditedVoters}',
                            style: const TextStyle(color: ApcColors.muted, fontSize: 12),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: r.partyVotes.entries
                                .map((e) => Chip(
                                      label: Text('${e.key.toUpperCase()}: ${e.value}',
                                          style: const TextStyle(fontSize: 11)),
                                      visualDensity: VisualDensity.compact,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 12),
                          ApprovalTimeline(currentStatus: r.status, compact: true),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    try {
                                      await repo.approveResult(r.id);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Approved → ${ResultStatus.label(ResultStatus.nextOnApprove(r.status) ?? '')}',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(content: Text('$e')));
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.check_rounded),
                                  label: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _rejectDialog(repo, r),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: ApcColors.red,
                                    side: const BorderSide(color: ApcColors.red),
                                  ),
                                  icon: const Icon(Icons.close_rounded, color: ApcColors.red),
                                  label: const Text('Reject'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingPillNav(
        index: navIndex,
        onChanged: (i) {
          setState(() => navIndex = i);
          if (i == 1 && (user.role == AppRoles.superAdmin || user.role == AppRoles.stateSupervisor)) {
            context.push('/situation-room');
          } else if (i == 2) {
            context.push('/offline');
          } else if (i == 3) {
            ref.read(sessionProvider.notifier).logout();
          }
        },
        items: const [
          (icon: Icons.fact_check_rounded, label: 'Queue'),
          (icon: Icons.monitor_heart_outlined, label: 'Room'),
          (icon: Icons.cloud_upload_outlined, label: 'Sync'),
          (icon: Icons.logout_rounded, label: 'Logout'),
        ],
      ),
    );
  }

  Future<void> _rejectDialog(dynamic repo, PollingResult r) async {
    reasonCtrl.clear();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected')));
      }
    }
  }
}
