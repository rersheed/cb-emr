import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/providers/providers.dart';

class SituationRoomScreen extends ConsumerWidget {
  const SituationRoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(resultsTickProvider);
    final repo = ref.watch(repositoryProvider);
    final verified = repo.results(status: ResultStatus.stateVerified);
    final user = repo.currentUser;

    return Scaffold(
      backgroundColor: ApcColors.surface,
      appBar: AppBar(
        title: const Text('Situation Room'),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () => ref.read(sessionProvider.notifier).logout(),
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ApcColors.greenDark, ApcColors.green],
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
              boxShadow: softShadow(blur: 18, y: 8, opacity: 0.14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(AppConstants.apcLogo, height: 36),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Read-only · STATE VERIFIED results only',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(repo.election.name,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: verified.isEmpty
                ? const Center(
                    child: Text('No state-verified results yet. Approve up the chain.',
                        style: TextStyle(color: ApcColors.muted)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: verified.length,
                    itemBuilder: (_, i) {
                      final r = verified[i];
                      return SoftCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: ApcColors.green, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.puName ?? r.pollingUnitId,
                                      style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(
                                    'APC ${r.partyVotes['apc'] ?? 0} · PDP ${r.partyVotes['pdp'] ?? 0} · '
                                    'NNPP ${r.partyVotes['nnpp'] ?? 0} · LP ${r.partyVotes['lp'] ?? 0}',
                                    style: const TextStyle(fontSize: 12, color: ApcColors.muted),
                                  ),
                                  Text(
                                    'Total ${r.totalPartyVotes} · Accredited ${r.accreditedVoters}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
