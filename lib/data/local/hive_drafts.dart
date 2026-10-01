import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/models.dart';

class HiveDraftStore {
  Box? _drafts;
  Box? _sync;

  Future<void> init() async {
    await Hive.initFlutter();
    _drafts = await Hive.openBox(AppConstants.hiveDraftsBox);
    _sync = await Hive.openBox(AppConstants.hiveSyncBox);
  }

  Future<void> saveDraft(String key, Map<String, dynamic> data) async {
    await _drafts?.put(key, data);
  }

  Map<String, dynamic>? getDraft(String key) {
    final v = _drafts?.get(key);
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  Future<void> deleteDraft(String key) async {
    await _drafts?.delete(key);
  }

  List<Map<String, dynamic>> allDrafts() {
    final out = <Map<String, dynamic>>[];
    for (final k in _drafts?.keys ?? []) {
      final v = _drafts?.get(k);
      if (v is Map) {
        out.add({'key': k.toString(), ...Map<String, dynamic>.from(v)});
      }
    }
    return out;
  }

  Future<void> enqueue(SyncQueueItem item) async {
    await _sync?.put(item.id, item.toMap());
  }

  List<SyncQueueItem> syncQueue() {
    final out = <SyncQueueItem>[];
    for (final k in _sync?.keys ?? []) {
      final v = _sync?.get(k);
      if (v is Map) out.add(SyncQueueItem.fromMap(v));
    }
    out.sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
    return out;
  }

  Future<void> removeFromQueue(String id) async {
    await _sync?.delete(id);
  }

  Future<void> clearQueue() async {
    await _sync?.clear();
  }
}
