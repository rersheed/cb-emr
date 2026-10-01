import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
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
      appBar: AppBar(title: const Text('Opening report')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(pu?.name ?? widget.puId, style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            title: const Text('Materials complete'),
            value: materials,
            activeThumbColor: ApcColors.green,
            onChanged: (v) => setState(() => materials = v),
          ),
          SwitchListTile(
            title: const Text('Officials present'),
            value: officials,
            activeThumbColor: ApcColors.green,
            onChanged: (v) => setState(() => officials = v),
          ),
          TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes'), maxLines: 3),
          const SizedBox(height: 12),
          Text('GPS (stub): ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
              style: const TextStyle(color: ApcColors.blue)),
          const SizedBox(height: 20),
          FilledButton(
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening report submitted')));
                      context.pop();
                    }
                  },
            child: const Text('Submit opening report'),
          ),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to offline queue')));
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
