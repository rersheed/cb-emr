import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(
        title: const Text('Situation Room'),
        actions: [
          if (user != null)
            IconButton(
              onPressed: () => ref.read(sessionProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: ApcColors.green.withValues(alpha: 0.15),
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
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(repo.election.name, style: const TextStyle(color: ApcColors.blue, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: verified.isEmpty
                ? const Center(child: Text('No state-verified results yet. Approve up the chain.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: verified.length,
                    itemBuilder: (_, i) {
                      final r = verified[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.verified, color: ApcColors.green),
                          title: Text(r.puName ?? r.pollingUnitId),
                          subtitle: Text(
                            'APC ${r.partyVotes['apc'] ?? 0} · PDP ${r.partyVotes['pdp'] ?? 0} · '
                            'NNPP ${r.partyVotes['nnpp'] ?? 0} · LP ${r.partyVotes['lp'] ?? 0}\n'
                            'Total ${r.totalPartyVotes} · Accredited ${r.accreditedVoters}',
                          ),
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
