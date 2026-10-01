import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../data/models/models.dart';
import '../../../data/providers/providers.dart';

class IncidentFormScreen extends ConsumerStatefulWidget {
  const IncidentFormScreen({super.key, required this.puId});
  final String puId;
  @override
  ConsumerState<IncidentFormScreen> createState() => _IncidentFormScreenState();
}

class _IncidentFormScreenState extends ConsumerState<IncidentFormScreen> {
  String category = 'Security';
  String severity = 'medium';
  final description = TextEditingController();
  String? photoPath;
  double lat = 10.52;
  double lon = 7.44;
  bool busy = false;

  static const categories = ['Security', 'Logistics', 'Violence', 'Malpractice', 'Other'];

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) setState(() => photoPath = file.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery pick unavailable — photo path stubbed.')),
      );
      setState(() => photoPath = 'stub://demo-photo.jpg');
    }
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
      appBar: AppBar(title: const Text('Incident report')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          SoftCard(
            color: ApcColors.redSoft,
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: ApcColors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(pu?.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: ApcColors.red)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FormSectionCard(
            title: 'Incident details',
            icon: Icons.report_gmailerrorred_rounded,
            accent: ApcColors.red,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => category = v ?? category),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: severity,
                  decoration: const InputDecoration(labelText: 'Severity'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'critical', child: Text('Critical')),
                  ],
                  onChanged: (v) => setState(() => severity = v ?? severity),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: description,
                  decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          FormSectionCard(
            title: 'Evidence',
            icon: Icons.photo_camera_outlined,
            accent: ApcColors.blue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.photo_camera, color: ApcColors.blue),
                  label: Text(photoPath == null ? 'Add photo (gallery / stub)' : 'Photo attached'),
                ),
                const SizedBox(height: 10),
                Text('GPS stub: ${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}',
                    style: const TextStyle(color: ApcColors.blue, fontSize: 12)),
              ],
            ),
          ),
          GradientCtaButton(
            label: 'Submit incident',
            colors: const [ApcColors.red, Color(0xFFB71C1C)],
            busy: busy,
            onPressed: busy || description.text.trim().isEmpty
                ? null
                : () async {
                    setState(() => busy = true);
                    await repo.submitIncident(Incident(
                      id: const Uuid().v4(),
                      electionId: repo.election.id,
                      pollingUnitId: widget.puId,
                      reporterId: repo.currentUser!.id,
                      category: category,
                      description: description.text.trim(),
                      photoPath: photoPath,
                      gpsLat: lat,
                      gpsLon: lon,
                      severity: severity,
                      status: 'open',
                      createdAt: DateTime.now(),
                      puName: pu?.name,
                    ));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Incident submitted')));
                    context.pop();
                  },
          ),
        ],
      ),
    );
  }
}
