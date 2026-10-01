import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class ResultEntryScreen extends ConsumerStatefulWidget {
  const ResultEntryScreen({super.key, required this.puId});
  final String puId;
  @override
  ConsumerState<ResultEntryScreen> createState() => _ResultEntryScreenState();
}

class _ResultEntryScreenState extends ConsumerState<ResultEntryScreen> {
  final Map<String, TextEditingController> voteCtrls = {};
  final accredited = TextEditingController(text: '300');
  final invalid = TextEditingController(text: '5');
  bool busy = false;
  String? errorText;
  List<String> warnings = [];

  @override
  void dispose() {
    for (final c in voteCtrls.values) {
      c.dispose();
    }
    accredited.dispose();
    invalid.dispose();
    super.dispose();
  }

  int _parse(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(repositoryProvider);
    final parties = repo.parties;
    for (final p in parties) {
      voteCtrls.putIfAbsent(p.id, () => TextEditingController(text: '0'));
    }
    final pu = repo.findPu(widget.puId);
    final total = parties.fold<int>(0, (a, p) => a + _parse(voteCtrls[p.id]!));

    return Scaffold(
      appBar: AppBar(title: const Text('Result entry')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(pu?.name ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            controller: accredited,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Accredited voters'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: invalid,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Invalid ballots'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Party votes', style: Theme.of(context).textTheme.titleSmall),
          ...parties.map((p) {
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(
                controller: voteCtrls[p.id],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '${p.acronym} — ${p.name}',
                  prefixIcon: Icon(Icons.circle, size: 12, color: _color(p.colorHex)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            );
          }),
          const SizedBox(height: 12),
          Card(
            color: ApcColors.green.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('Auto total (party votes): $total',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(errorText!, style: const TextStyle(color: ApcColors.red)),
            ),
          ...warnings.map((w) => Text(w, style: const TextStyle(color: Colors.orangeAccent, fontSize: 12))),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : () => _submit(repo, offline: false),
            child: const Text('Submit for ward approval'),
          ),
          OutlinedButton(
            onPressed: busy ? null : () => _submit(repo, offline: true),
            child: const Text('Save draft offline'),
          ),
        ],
      ),
    );
  }

  Color _color(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  Future<void> _submit(dynamic repo, {required bool offline}) async {
    final partyVotes = <String, int>{};
    for (final e in voteCtrls.entries) {
      partyVotes[e.key] = _parse(e.value);
    }
    final v = validateResultVotes(
      partyVotes: partyVotes,
      accredited: _parse(accredited),
      invalid: _parse(invalid),
    );
    setState(() {
      errorText = v.errors.isEmpty ? null : v.errors.join('\n');
      warnings = v.warnings;
    });
    if (!v.ok) return;
    setState(() => busy = true);
    final total = partyVotes.values.fold(0, (a, b) => a + b);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    await repo.submitResult(
      PollingResult(
        id: const Uuid().v4(),
        electionId: repo.election.id,
        pollingUnitId: widget.puId,
        submittedBy: repo.currentUser!.id,
        accreditedVoters: _parse(accredited),
        validVotes: total,
        invalidVotes: _parse(invalid),
        status: offline ? ResultStatus.draft : ResultStatus.pendingWard,
        submittedAt: DateTime.now(),
        partyVotes: partyVotes,
        puName: repo.findPu(widget.puId)?.name,
      ),
      offline: offline,
    );
    messenger.showSnackBar(SnackBar(
      content: Text(offline ? 'Draft queued offline' : 'Result submitted — pending ward'),
    ));
    router.pop();
  }
}
