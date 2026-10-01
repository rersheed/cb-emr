import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class OpeningFormScreen extends ConsumerStatefulWidget {
  const OpeningFormScreen({super.key, required this.puId});
  final String puId;
  @override
  ConsumerState<OpeningFormScreen> createState() => _OpeningFormScreenState();
}

class _OpeningFormScreenState extends ConsumerState<OpeningFormScreen> {
  bool materials = true;
  bool officials = true;
  final notes = TextEditingController();
  double lat = 10.5200;
  double lon = 7.4400;
  bool busy = false;

  @override
  void dispose() {
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final pu = repo.findPu(widget.puId);
    final resolved = repo.resolvePu(widget.puId);
    if (resolved?.ward.lat != null) {
      lat = resolved!.ward.lat!;
      lon = resolved.ward.lon ?? lon;
    }
    return Scaffold(
      backgroundColor: ApcColors.surface,
      appBar: AppBar(title: const Text('Opening report')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SoftCard(
            child: Text(pu?.name ?? widget.puId,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          const SizedBox(height: 12),
          FormSectionCard(
            title: 'Checklist',
            icon: Icons.checklist_rounded,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Materials complete', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: materials,
                  activeThumbColor: ApcColors.green,
                  onChanged: (v) => setState(() => materials = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Officials present', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: officials,
                  activeThumbColor: ApcColors.green,
                  onChanged: (v) => setState(() => officials = v),
                ),
              ],
            ),
          ),
          FormSectionCard(
            title: 'Notes & GPS',
            icon: Icons.notes_rounded,
            accent: ApcColors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notes', alignLabelWithHint: true),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: ApcColors.blueSoft,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed_rounded, color: ApcColors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text('GPS: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
                          style: const TextStyle(color: ApcColors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GradientCtaButton(
            label: 'Submit opening report',
            busy: busy,
            onPressed: busy
                ? null
                : () async {
                    setState(() => busy = true);
                    final user = repo.currentUser!;
                    await repo.submitOpening(OpeningReport(
                      id: const Uuid().v4(),
                      electionId: repo.election.id,
                      pollingUnitId: widget.puId,
                      reporterId: user.id,
                      openedAt: DateTime.now(),
                      materialsComplete: materials,
                      officialsPresent: officials,
                      notes: notes.text,
                      gpsLat: lat,
                      gpsLon: lon,
                      status: 'pending_ward',
                      puName: pu?.name,
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Opening report submitted')));
                      context.pop();
                    }
                  },
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    setState(() => busy = true);
                    final user = repo.currentUser!;
                    await repo.submitOpening(
                      OpeningReport(
                        id: const Uuid().v4(),
                        electionId: repo.election.id,
                        pollingUnitId: widget.puId,
                        reporterId: user.id,
                        openedAt: DateTime.now(),
                        materialsComplete: materials,
                        officialsPresent: officials,
                        notes: notes.text,
                        gpsLat: lat,
                        gpsLon: lon,
                        status: 'draft',
                        puName: pu?.name,
                      ),
                      offline: true,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(content: Text('Saved to offline queue')));
                      context.pop();
                    }
                  },
            child: const Text('Save offline'),
          ),
        ],
      ),
    );
  }
}
