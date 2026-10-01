import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/supabase_config.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import 'demo_repository.dart';
import 'emr_repository.dart';

/// Hybrid: [DemoRepository] for UX + Hive offline; persists to Supabase when reachable.
class SupabaseRepository extends ChangeNotifier implements EmrRepository {
  SupabaseRepository({required HiveDraftStore hive}) : _local = DemoRepository(hive);

  final DemoRepository _local;
  final _uuid = const Uuid();

  bool _connected = false;
  String _connectionLabel = 'Demo local';

  bool get isConnected => _connected;
  String get connectionLabel => _connectionLabel;

  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> initialize() async {
    await _local.initialize();
    await _probeAndBootstrap();
    _local.addListener(notifyListeners);
    notifyListeners();
  }

  Future<void> _probeAndBootstrap() async {
    final client = _client;
    if (client == null || !SupabaseConfig.isConfigured) {
      _connected = false;
      _connectionLabel = 'Demo local';
      return;
    }
    try {
      await client.from('parties').select('id').limit(1);
      _connected = true;
      _connectionLabel = 'Connected to Supabase';
      await _upsertDemoProfiles(client);
    } catch (e, st) {
      debugPrint('Supabase probe failed: $e\n$st');
      _connected = false;
      _connectionLabel = 'Demo local';
    }
  }

  Future<void> _upsertDemoProfiles(SupabaseClient client) async {
    try {
      final rows = _local.demoUsers
          .map((u) => {
                'id': u.id,
                'email': u.email,
                'full_name': u.fullName,
                'role': u.role,
                'state_id': u.stateId,
                'lga_id': u.lgaId,
                'ward_id': u.wardId,
              })
          .toList();
      await client.from('profiles').upsert(rows, onConflict: 'id');
    } catch (e) {
      debugPrint('Profile upsert skipped: $e');
    }
  }

  @override
  List<StateGeo> get states => _local.states;
  @override
  List<Party> get parties => _local.parties;
  @override
  ElectionInfo get election => _local.election;
  @override
  List<DemoUser> get demoUsers => _local.demoUsers;
  @override
  DemoUser? get currentUser => _local.currentUser;

  @override
  Future<void> loginAs(DemoUser user) => _local.loginAs(user);
  @override
  Future<void> logout() => _local.logout();

  @override
  List<PollingUnitGeo> assignedUnitsFor(DemoUser user) => _local.assignedUnitsFor(user);
  @override
  PollingUnitGeo? findPu(String id) => _local.findPu(id);
  @override
  ({StateGeo state, LgaGeo lga, WardGeo ward, PollingUnitGeo pu})? resolvePu(String puId) =>
      _local.resolvePu(puId);

  @override
  List<PollingResult> results(
          {String? status, String? submittedBy, String? wardId, String? lgaId, String? stateId}) =>
      _local.results(
          status: status, submittedBy: submittedBy, wardId: wardId, lgaId: lgaId, stateId: stateId);
  @override
  List<Incident> incidents({String? reporterId}) => _local.incidents(reporterId: reporterId);
  @override
  List<OpeningReport> openingReports({String? reporterId}) =>
      _local.openingReports(reporterId: reporterId);
  @override
  List<ApprovalRecord> approvalsFor(String resultId) => _local.approvalsFor(resultId);
  @override
  List<AuditEntry> auditLog() => _local.auditLog();
  @override
  List<SyncQueueItem> syncQueue() => _local.syncQueue();

  @override
  Future<PollingResult> submitResult(PollingResult result, {bool offline = false}) async {
    final saved = await _local.submitResult(result, offline: offline);
    if (!offline && _connected) {
      await _tryPersistResult(saved);
    }
    return saved;
  }

  Future<void> _tryPersistResult(PollingResult r) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('polling_results').upsert({
        'id': r.id,
        'election_id': r.electionId,
        'polling_unit_id': r.pollingUnitId,
        'submitted_by': r.submittedBy,
        'accredited_voters': r.accreditedVoters,
        'valid_votes': r.validVotes,
        'invalid_votes': r.invalidVotes,
        'status': r.status,
        'rejection_reason': r.rejectionReason,
        'submitted_at': r.submittedAt?.toIso8601String(),
      }, onConflict: 'election_id,polling_unit_id');
      final details = r.partyVotes.entries
          .map((e) => {
                'result_id': r.id,
                'party_id': e.key,
                'votes': e.value,
              })
          .toList();
      if (details.isNotEmpty) {
        await client.from('result_details').upsert(details, onConflict: 'result_id,party_id');
      }
      await client.from('audit_log').insert({
        'actor_id': r.submittedBy,
        'entity_type': 'polling_result',
        'entity_id': r.id,
        'action': 'submit',
        'meta': {'status': r.status},
      });
    } catch (e) {
      debugPrint('Supabase result persist failed (local kept): $e');
    }
  }

  @override
  Future<OpeningReport> submitOpening(OpeningReport report, {bool offline = false}) async {
    final saved = await _local.submitOpening(report, offline: offline);
    if (!offline && _connected) {
      await _tryPersistOpening(saved);
    }
    return saved;
  }

  Future<void> _tryPersistOpening(OpeningReport o) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('opening_reports').upsert({
        'id': o.id,
        'election_id': o.electionId,
        'polling_unit_id': o.pollingUnitId,
        'reporter_id': o.reporterId,
        'opened_at': o.openedAt.toIso8601String(),
        'materials_complete': o.materialsComplete,
        'officials_present': o.officialsPresent,
        'notes': o.notes,
        'gps_lat': o.gpsLat,
        'gps_lon': o.gpsLon,
        'status': o.status,
      });
    } catch (e) {
      debugPrint('Supabase opening persist failed (local kept): $e');
    }
  }

  @override
  Future<Incident> submitIncident(Incident incident, {bool offline = false}) async {
    final saved = await _local.submitIncident(incident, offline: offline);
    if (!offline && _connected) {
      await _tryPersistIncident(saved);
    }
    return saved;
  }

  Future<void> _tryPersistIncident(Incident i) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.from('incidents').upsert({
        'id': i.id,
        'election_id': i.electionId,
        'polling_unit_id': i.pollingUnitId,
        'reporter_id': i.reporterId,
        'category': i.category,
        'description': i.description,
        'photo_path': i.photoPath,
        'gps_lat': i.gpsLat,
        'gps_lon': i.gpsLon,
        'severity': i.severity,
        'status': i.status,
        'created_at': i.createdAt.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase incident persist failed (local kept): $e');
    }
  }

  @override
  Future<PollingResult> approveResult(String resultId, {String? note}) async {
    final updated = await _local.approveResult(resultId, note: note);
    if (_connected) {
      await _tryPersistApproval(updated, note: note, rejected: false);
    }
    return updated;
  }

  @override
  Future<PollingResult> rejectResult(String resultId, {required String reason}) async {
    final updated = await _local.rejectResult(resultId, reason: reason);
    if (_connected) {
      await _tryPersistApproval(updated, note: reason, rejected: true);
    }
    return updated;
  }

  Future<void> _tryPersistApproval(PollingResult r, {String? note, required bool rejected}) async {
    final client = _client;
    final user = currentUser;
    if (client == null || user == null) return;
    try {
      await client.from('polling_results').update({
        'status': r.status,
        'rejection_reason': r.rejectionReason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', r.id);
      await client.from('approvals').insert({
        'id': _uuid.v4(),
        'result_id': r.id,
        'actor_id': user.id,
        'from_status': rejected ? 'pending' : 'pending',
        'to_status': r.status,
        'reason': note,
      });
    } catch (e) {
      debugPrint('Supabase approval persist failed (local kept): $e');
    }
  }

  @override
  Future<int> syncPending() async {
    final n = await _local.syncPending();
    // After local sync, best-effort push remaining to Supabase is already attempted
    // inside submit* when offline:false.
    return n;
  }
}
