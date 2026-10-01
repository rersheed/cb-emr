import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class AgentShell extends ConsumerStatefulWidget {
  const AgentShell({super.key});

  @override
  ConsumerState<AgentShell> createState() => _AgentShellState();
}

class _AgentShellState extends ConsumerState<AgentShell> {
  int navIndex = 0;
  final searchCtrl = TextEditingController();
  String query = '';

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final user = repo.currentUser;
    if (user == null) return const SizedBox.shrink();

    final units = repo.assignedUnitsFor(user);
    final filtered = query.trim().isEmpty
        ? units
        : units
            .where((pu) =>
                pu.name.toLowerCase().contains(query.toLowerCase()) ||
                pu.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
    final mine = repo.results(submittedBy: user.id);
    final submitted = mine.where((r) => r.status != ResultStatus.draft).length;
    final pending = mine
        .where((r) =>
            r.status == ResultStatus.pendingWard ||
            r.status == ResultStatus.pendingLga ||
            r.status == ResultStatus.pendingState)
        .length;
    final approved = mine.where((r) => r.status == ResultStatus.stateVerified).length;
    final syncCount = repo.syncQueue().length;
    final primaryPu = units.isNotEmpty ? units.first : null;
    final assignment = primaryPu != null
        ? '${primaryPu.name} · ${primaryPu.code}'
        : 'No PU assigned';

    return Scaffold(
      backgroundColor: ApcColors.surface,
      body: SafeArea(
        child: IndexedStack(
          index: navIndex,
          children: [
            _HomeTab(
              userName: user.fullName,
              roleLabel: AppRoles.label(user.role),
              assignment: assignment,
              searchCtrl: searchCtrl,
              onSearch: (v) => setState(() => query = v),
              submitted: submitted,
              pending: pending,
              approved: approved,
              assignedCount: units.length,
              syncCount: syncCount,
              units: filtered,
              primaryPuId: primaryPu?.id,
              onOpenPu: (id) => context.push('/agent/pu/$id'),
              onOffline: () => context.push('/offline'),
              onLogout: () => ref.read(sessionProvider.notifier).logout(),
            ),
            _UnitsTab(
              units: filtered,
              mine: mine,
              onOpen: (id) => context.push('/agent/pu/$id'),
            ),
            _ActivityTab(results: mine),
            _AccountTab(
              name: user.fullName,
              role: AppRoles.label(user.role),
              email: user.email,
              syncCount: syncCount,
              onOffline: () => context.push('/offline'),
              onLogout: () => ref.read(sessionProvider.notifier).logout(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingPillNav(
        index: navIndex,
        onChanged: (i) => setState(() => navIndex = i),
        items: const [
          (icon: Icons.home_rounded, label: 'Home'),
          (icon: Icons.how_to_vote_rounded, label: 'PUs'),
          (icon: Icons.history_rounded, label: 'History'),
          (icon: Icons.person_rounded, label: 'Account'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.userName,
    required this.roleLabel,
    required this.assignment,
    required this.searchCtrl,
    required this.onSearch,
    required this.submitted,
    required this.pending,
    required this.approved,
    required this.assignedCount,
    required this.syncCount,
    required this.units,
    required this.primaryPuId,
    required this.onOpenPu,
    required this.onOffline,
    required this.onLogout,
  });

  final String userName;
  final String roleLabel;
  final String assignment;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearch;
  final int submitted;
  final int pending;
  final int approved;
  final int assignedCount;
  final int syncCount;
  final List units;
  final String? primaryPuId;
  final ValueChanged<String> onOpenPu;
  final VoidCallback onOffline;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_rounded, color: ApcColors.green, size: 22),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(assignment,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text('$roleLabel · $userName',
                      style: const TextStyle(color: ApcColors.muted, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Offline sync',
              onPressed: onOffline,
              icon: Badge(
                isLabelVisible: syncCount > 0,
                label: Text('$syncCount'),
                child: const Icon(Icons.notifications_none_rounded, color: ApcColors.ink),
              ),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded, color: ApcColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),
        PillSearchField(
          controller: searchCtrl,
          hint: 'Search polling unit or code',
          onChanged: onSearch,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ApcColors.greenDark, ApcColors.green, Color(0xFF58C46F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: softShadow(blur: 22, y: 10, opacity: 0.16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Election day status',
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                '$submitted results submitted · $pending pending approval',
                style: const TextStyle(
                  color: ApcColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture openings, incidents & results — then push up the chain.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: primaryPuId == null
                          ? null
                          : () => onOpenPu(primaryPuId!),
                      style: FilledButton.styleFrom(
                        backgroundColor: ApcColors.white,
                        foregroundColor: ApcColors.greenDark,
                        disabledBackgroundColor: Colors.white54,
                      ),
                      icon: const Icon(Icons.how_to_vote_rounded, size: 18),
                      label: const Text('Enter results'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: primaryPuId == null
                          ? null
                          : () => GoRouter.of(context).push('/agent/incident/$primaryPuId'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ApcColors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      icon: const Icon(Icons.warning_amber_rounded, size: 18),
                      label: const Text('Incident'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _MiniStat(label: 'Assigned', value: '$assignedCount', color: ApcColors.blue),
            const SizedBox(width: 8),
            _MiniStat(label: 'Pending', value: '$pending', color: ApcColors.gold),
            const SizedBox(width: 8),
            _MiniStat(label: 'Approved', value: '$approved', color: ApcColors.green),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Quick actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
          children: [
            ActionGridTile(
              icon: Icons.door_front_door_rounded,
              label: 'Opening\nReport',
              color: ApcColors.blue,
              onTap: () {
                if (primaryPuId != null) {
                  GoRouter.of(context).push('/agent/opening/$primaryPuId');
                }
              },
            ),
            ActionGridTile(
              icon: Icons.warning_amber_rounded,
              label: 'Incident',
              color: ApcColors.red,
              onTap: () {
                if (primaryPuId != null) {
                  GoRouter.of(context).push('/agent/incident/$primaryPuId');
                }
              },
            ),
            ActionGridTile(
              icon: Icons.how_to_vote_rounded,
              label: 'Results',
              color: ApcColors.green,
              onTap: () {
                if (primaryPuId != null) {
                  GoRouter.of(context).push('/agent/result/$primaryPuId');
                }
              },
            ),
            ActionGridTile(
              icon: Icons.inventory_2_outlined,
              label: 'Materials',
              color: ApcColors.brown,
              onTap: () {
                if (primaryPuId != null) {
                  GoRouter.of(context).push('/agent/opening/$primaryPuId');
                }
              },
            ),
            ActionGridTile(
              icon: Icons.verified_outlined,
              label: 'Approvals',
              color: ApcColors.blue,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Approvals are on supervisor logins')),
              ),
            ),
            ActionGridTile(
              icon: Icons.history_rounded,
              label: 'History',
              color: ApcColors.ink,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$submitted submissions in your history')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text('Assigned PUs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            Text('${units.length} units', style: const TextStyle(color: ApcColors.muted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: units.isEmpty
              ? SoftCard(
                  child: const Center(
                    child: Text('No PUs assigned to this demo agent.',
                        style: TextStyle(color: ApcColors.muted)),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: units.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final pu = units[i];
                    return SoftCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () => onOpenPu(pu.id),
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: ApcColors.greenSoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.how_to_vote_rounded,
                                      color: ApcColors.green, size: 18),
                                ),
                                const Spacer(),
                                const Icon(Icons.chevron_right_rounded, color: ApcColors.muted),
                              ],
                            ),
                            const Spacer(),
                            Text(pu.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                            Text('Code ${pu.code}',
                                style: const TextStyle(fontSize: 12, color: ApcColors.muted)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 22),
        StatusTrustRow(syncPending: syncCount),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: ApcColors.muted, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _UnitsTab extends StatelessWidget {
  const _UnitsTab({required this.units, required this.mine, required this.onOpen});
  final List units;
  final List mine;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const Text('Polling units', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        if (units.isEmpty)
          const SoftCard(child: Text('No assigned units.', style: TextStyle(color: ApcColors.muted))),
        for (final pu in units)
          SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.zero,
            onTap: () => onOpen(pu.id),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: ApcColors.greenSoft,
                child: const Icon(Icons.how_to_vote_rounded, color: ApcColors.green),
              ),
              title: Text(pu.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Code ${pu.code}'),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.results});
  final List results;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        const Text('Recent activity', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        if (results.isEmpty)
          const SoftCard(child: Text('No submissions yet.', style: TextStyle(color: ApcColors.muted))),
        for (final r in results.reversed.take(20))
          SoftCard(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ApcColors.blueSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: ApcColors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.puName ?? r.pollingUnitId,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(ResultStatus.label(r.status),
                          style: const TextStyle(fontSize: 12, color: ApcColors.muted)),
                    ],
                  ),
                ),
                Text('${r.totalPartyVotes}',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: ApcColors.green)),
              ],
            ),
          ),
      ],
    );
  }
}

class _AccountTab extends StatelessWidget {
  const _AccountTab({
    required this.name,
    required this.role,
    required this.email,
    required this.syncCount,
    required this.onOffline,
    required this.onLogout,
  });

  final String name;
  final String role;
  final String email;
  final int syncCount;
  final VoidCallback onOffline;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        SoftCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: ApcColors.green,
                child: Text(name.characters.first,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(role, style: const TextStyle(color: ApcColors.green, fontWeight: FontWeight.w600)),
                    Text(email, style: const TextStyle(color: ApcColors.muted, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_upload_outlined, color: ApcColors.blue),
                title: const Text('Offline sync queue'),
                trailing: syncCount > 0
                    ? Chip(label: Text('$syncCount'))
                    : const Icon(Icons.chevron_right_rounded),
                onTap: onOffline,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: ApcColors.red),
                title: const Text('Logout'),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
