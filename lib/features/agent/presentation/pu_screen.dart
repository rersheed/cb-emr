import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
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
      backgroundColor: ApcColors.surface,
      appBar: AppBar(title: Text(pu.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ApcColors.greenSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.location_on_rounded, color: ApcColors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${resolved.state.name} › ${resolved.lga.name}',
                              style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('Ward: ${resolved.ward.name}',
                              style: const TextStyle(color: ApcColors.muted, fontSize: 13)),
                          Text('PU code: ${pu.code}',
                              style: const TextStyle(color: ApcColors.blue, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('Actions', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.15,
            children: [
              ActionGridTile(
                icon: Icons.door_front_door_rounded,
                label: 'Opening report',
                color: ApcColors.blue,
                onTap: () => context.push('/agent/opening/$puId'),
              ),
              ActionGridTile(
                icon: Icons.warning_amber_rounded,
                label: 'Report incident',
                color: ApcColors.red,
                onTap: () => context.push('/agent/incident/$puId'),
              ),
              ActionGridTile(
                icon: Icons.how_to_vote_rounded,
                label: 'Enter results',
                color: ApcColors.green,
                onTap: () => context.push('/agent/result/$puId'),
              ),
              ActionGridTile(
                icon: Icons.inventory_2_outlined,
                label: 'Materials check',
                color: ApcColors.brown,
                onTap: () => context.push('/agent/opening/$puId'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
