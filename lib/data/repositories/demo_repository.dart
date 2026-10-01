import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../demo/demo_seed.dart';
import '../local/hive_drafts.dart';
import '../models/models.dart';
import 'emr_repository.dart';

class DemoRepository extends ChangeNotifier implements EmrRepository {
  final HiveDraftStore _hive;
  final _uuid = const Uuid();

  DemoRepository(this._hive);

  List<StateGeo> _states = [];
  final List<PollingResult> _results = [];
  final List<Incident> _incidents = [];
  final List<OpeningReport> _openings = [];
  final List<ApprovalRecord> _approvals = [];
  final List<AuditEntry> _audit = [];
  List<DemoUser> _users = [];
  DemoUser? _current;
  bool _ready = false;

  // PU lookup indexes
  final Map<String, PollingUnitGeo> _puById = {};
  final Map<String, WardGeo> _wardById = {};
  final Map<String, LgaGeo> _lgaById = {};
  final Map<String, StateGeo> _stateById = {};
  final Map<String, String> _puWard = {};
  final Map<String, String> _wardLga = {};
  final Map<String, String> _lgaState = {};

  @override
  List<StateGeo> get states => _states;
  @override
  List<Party> get parties => kParties;
  @override
  ElectionInfo get election => kDemoElection;
  @override
  List<DemoUser> get demoUsers => _users;
  @override
  DemoUser? get currentUser => _current;

  @override
  Future<void> initialize() async {
    if (_ready) return;
    await _hive.init();
    final raw = await rootBundle.loadString(AppConstants.geographyAsset);
    final list = jsonDecode(raw) as List<dynamic>;
    _states = list.map((s) {
      final sm = s as Map<String, dynamic>;
      final state = StateGeo(
        id: sm['id'] as String,
        name: sm['name'] as String,
        code: sm['code'] as String? ?? '',
        lgas: (sm['lgas'] as List).map((l) {
          final lm = l as Map<String, dynamic>;
          final lga = LgaGeo(
            id: lm['id'] as String,
            name: lm['name'] as String,
            code: lm['code'] as String? ?? '',
            wards: (lm['wards'] as List).map((w) {
              final wm = w as Map<String, dynamic>;
              final ward = WardGeo(
                id: wm['id'] as String,
                name: wm['name'] as String,
                code: wm['code'] as String? ?? '',
                lat: (wm['lat'] as num?)?.toDouble(),
                lon: (wm['lon'] as num?)?.toDouble(),
                pollingUnits: (wm['pollingUnits'] as List).map((p) {
                  final pm = p as Map<String, dynamic>;
                  return PollingUnitGeo(
                    id: pm['id'] as String,
                    name: pm['name'] as String,
                    code: pm['code'] as String? ?? '',
                  );
                }).toList(),
              );
              return ward;
            }).toList(),
          );
          return lga;
        }).toList(),
      );
      return state;
    }).toList();

    for (final st in _states) {
      _stateById[st.id] = st;
      for (final lga in st.lgas) {
        _lgaById[lga.id] = lga;
        _lgaState[lga.id] = st.id;
        for (final ward in lga.wards) {
          _wardById[ward.id] = ward;
          _wardLga[ward.id] = lga.id;
          for (final pu in ward.pollingUnits) {
            _puById[pu.id] = pu;
            _puWard[pu.id] = ward.id;
          }
        }
      }
    }

    // Prefer Kaduna North for demo assignments
    final kd = _states.firstWhere((s) => s.id == 'kd', orElse: () => _states.first);
    LgaGeo demoLga = kd.lgas.firstWhere(
      (l) => l.name.toLowerCase().contains('kaduna north') || l.id.contains('kaduna-north'),
      orElse: () => kd.lgas.first,
    );
    final demoWard = demoLga.wards.isNotEmpty ? demoLga.wards.first : WardGeo(id: 'w', name: 'Demo', code: '', pollingUnits: []);
    final agentPus = demoWard.pollingUnits.take(3).map((p) => p.id).toList();
    if (agentPus.isEmpty && demoWard.pollingUnits.isNotEmpty) {
      agentPus.add(demoWard.pollingUnits.first.id);
    }

    _users = buildDemoUsers(
      kadunaStateId: kd.id,
      kadunaNorthLgaId: demoLga.id,
      demoWardId: demoWard.id,
      agentPuIds: agentPus,
    );

    _seedOperationalData(agentPus, demoWard, demoLga, kd);
    _ready = true;
    notifyListeners();
  }

  void _seedOperationalData(List<String> agentPus, WardGeo ward, LgaGeo lga, StateGeo state) {
    if (agentPus.isEmpty) return;
    final agent = _users.firstWhere((u) => u.role == AppRoles.fieldAgent);
    final elec = election.id;

    // Opening report
    _openings.add(OpeningReport(
      id: _uuid.v4(),
      electionId: elec,
      pollingUnitId: agentPus.first,
      reporterId: agent.id,
      openedAt: DateTime.now().subtract(const Duration(hours: 5)),
      materialsComplete: true,
      officialsPresent: true,
      notes: 'PU opened on time. Materials complete.',
      gpsLat: ward.lat ?? 10.52,
      gpsLon: ward.lon ?? 7.44,
      status: ResultStatus.pendingWard,
      puName: _puById[agentPus.first]?.name,
    ));

    // Incident
    _incidents.add(Incident(
      id: _uuid.v4(),
      electionId: elec,
      pollingUnitId: agentPus.first,
      reporterId: agent.id,
      category: 'Logistics',
      description: 'Ballot papers arrived 20 minutes late; resolved.',
      gpsLat: ward.lat ?? 10.52,
      gpsLon: ward.lon ?? 7.44,
      severity: 'low',
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      puName: _puById[agentPus.first]?.name,
    ));

    // Results in various statuses
    void addResult(String puId, String status, Map<String, int> votes) {
      final total = votes.values.fold(0, (a, b) => a + b);
      _results.add(PollingResult(
        id: _uuid.v4(),
        electionId: elec,
        pollingUnitId: puId,
        submittedBy: agent.id,
        accreditedVoters: total + 12,
        validVotes: total,
        invalidVotes: 3,
        status: status,
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        partyVotes: votes,
        puName: _puById[puId]?.name,
        wardId: ward.id,
        lgaId: lga.id,
        stateId: state.id,
      ));
    }

    if (agentPus.isNotEmpty) {
      addResult(agentPus[0], ResultStatus.pendingWard, {'apc': 120, 'pdp': 88, 'nnpp': 41, 'lp': 15});
    }
    if (agentPus.length > 1) {
      addResult(agentPus[1], ResultStatus.pendingLga, {'apc': 95, 'pdp': 102, 'nnpp': 30, 'lp': 10});
    }
    if (agentPus.length > 2) {
      addResult(agentPus[2], ResultStatus.stateVerified, {'apc': 150, 'pdp': 70, 'nnpp': 25, 'lp': 8});
    } else if (agentPus.length == 1) {
      // ensure situation room has something
      addResult(agentPus[0], ResultStatus.stateVerified, {'apc': 200, 'pdp': 90, 'nnpp': 40, 'lp': 12});
    }

    _audit.add(AuditEntry(
      id: _uuid.v4(),
      actorId: agent.id,
      entityType: 'seed',
      entityId: 'demo',
      action: 'seed_loaded',
      createdAt: DateTime.now(),
      meta: {'results': _results.length},
    ));
  }

  @override
  Future<void> loginAs(DemoUser user) async {
    _current = user;
    _auditAdd(user.id, 'session', user.id, 'login');
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    final id = _current?.id;
    _current = null;
    if (id != null) _auditAdd(id, 'session', id, 'logout');
    notifyListeners();
  }

  @override
  List<PollingUnitGeo> assignedUnitsFor(DemoUser user) {
    if (user.assignedPuIds.isNotEmpty) {
      return user.assignedPuIds.map((id) => _puById[id]).whereType<PollingUnitGeo>().toList();
    }
    if (user.wardId != null) {
      return _wardById[user.wardId!]?.pollingUnits ?? [];
    }
    return [];
  }

  @override
  PollingUnitGeo? findPu(String id) => _puById[id];

  @override
  ({StateGeo state, LgaGeo lga, WardGeo ward, PollingUnitGeo pu})? resolvePu(String puId) {
    final pu = _puById[puId];
    final wardId = _puWard[puId];
    if (pu == null || wardId == null) return null;
    final ward = _wardById[wardId]!;
    final lgaId = _wardLga[wardId]!;
    final lga = _lgaById[lgaId]!;
    final stateId = _lgaState[lgaId]!;
    final state = _stateById[stateId]!;
    return (state: state, lga: lga, ward: ward, pu: pu);
  }

  @override
  List<PollingResult> results({String? status, String? submittedBy, String? wardId, String? lgaId, String? stateId}) {
    return _results.where((r) {
      if (status != null && r.status != status) return false;
      if (submittedBy != null && r.submittedBy != submittedBy) return false;
      if (wardId != null && r.wardId != wardId) return false;
      if (lgaId != null && r.lgaId != lgaId) return false;
      if (stateId != null && r.stateId != stateId) return false;
      return true;
    }).toList();
  }

  @override
  List<Incident> incidents({String? reporterId}) {
    if (reporterId == null) return List.of(_incidents);
    return _incidents.where((i) => i.reporterId == reporterId).toList();
  }

  @override
  List<OpeningReport> openingReports({String? reporterId}) {
    if (reporterId == null) return List.of(_openings);
    return _openings.where((o) => o.reporterId == reporterId).toList();
  }

  @override
  List<ApprovalRecord> approvalsFor(String resultId) =>
      _approvals.where((a) => a.resultId == resultId).toList();

  @override
  List<AuditEntry> auditLog() => List.of(_audit.reversed);

  @override
  List<SyncQueueItem> syncQueue() => _hive.syncQueue();

  @override
  Future<PollingResult> submitResult(PollingResult result, {bool offline = false}) async {
    final resolved = resolvePu(result.pollingUnitId);
    var r = result.copyWith(
      status: ResultStatus.pendingWard,
      submittedAt: DateTime.now(),
    );
    // enrich geography
    r = PollingResult(
      id: r.id.isEmpty ? _uuid.v4() : r.id,
      electionId: r.electionId,
      pollingUnitId: r.pollingUnitId,
      submittedBy: r.submittedBy,
      accreditedVoters: r.accreditedVoters,
      validVotes: r.validVotes,
      invalidVotes: r.invalidVotes,
      status: offline ? ResultStatus.draft : ResultStatus.pendingWard,
      rejectionReason: null,
      submittedAt: r.submittedAt,
      partyVotes: r.partyVotes,
      puName: resolved?.pu.name ?? r.puName,
      wardId: resolved?.ward.id ?? r.wardId,
      lgaId: resolved?.lga.id ?? r.lgaId,
      stateId: resolved?.state.id ?? r.stateId,
    );

    if (offline) {
      await _hive.enqueue(SyncQueueItem(
        id: _uuid.v4(),
        type: 'result',
        payload: r.toMap(),
        enqueuedAt: DateTime.now(),
      ));
      await _hive.saveDraft('result_${r.pollingUnitId}', r.toMap());
      _auditAdd(r.submittedBy, 'polling_result', r.id, 'queued_offline');
      notifyListeners();
      return r;
    }

    final idx = _results.indexWhere((x) => x.pollingUnitId == r.pollingUnitId && x.electionId == r.electionId);
    if (idx >= 0) {
      _results[idx] = r;
    } else {
      _results.add(r);
    }
    _auditAdd(r.submittedBy, 'polling_result', r.id, 'submit');
    notifyListeners();
    return r;
  }

  @override
  Future<OpeningReport> submitOpening(OpeningReport report, {bool offline = false}) async {
    var o = report;
    if (o.id.isEmpty) {
      o = OpeningReport(
        id: _uuid.v4(),
        electionId: o.electionId,
        pollingUnitId: o.pollingUnitId,
        reporterId: o.reporterId,
        openedAt: o.openedAt,
        materialsComplete: o.materialsComplete,
        officialsPresent: o.officialsPresent,
        notes: o.notes,
        gpsLat: o.gpsLat,
        gpsLon: o.gpsLon,
        status: offline ? ResultStatus.draft : ResultStatus.pendingWard,
        puName: o.puName ?? _puById[o.pollingUnitId]?.name,
      );
    }
    if (offline) {
      await _hive.enqueue(SyncQueueItem(
        id: _uuid.v4(),
        type: 'opening',
        payload: o.toMap(),
        enqueuedAt: DateTime.now(),
      ));
      notifyListeners();
      return o;
    }
    _openings.add(o);
    _auditAdd(o.reporterId, 'opening_report', o.id, 'submit');
    notifyListeners();
    return o;
  }

  @override
  Future<Incident> submitIncident(Incident incident, {bool offline = false}) async {
    var i = incident;
    if (i.id.isEmpty) {
      i = Incident(
        id: _uuid.v4(),
        electionId: i.electionId,
        pollingUnitId: i.pollingUnitId,
        reporterId: i.reporterId,
        category: i.category,
        description: i.description,
        photoPath: i.photoPath,
        gpsLat: i.gpsLat,
        gpsLon: i.gpsLon,
        severity: i.severity,
        status: offline ? 'queued' : 'open',
        createdAt: i.createdAt,
        puName: i.puName ?? _puById[i.pollingUnitId]?.name,
      );
    }
    if (offline) {
      await _hive.enqueue(SyncQueueItem(
        id: _uuid.v4(),
        type: 'incident',
        payload: i.toMap(),
        enqueuedAt: DateTime.now(),
      ));
      notifyListeners();
      return i;
    }
    _incidents.add(i);
    _auditAdd(i.reporterId, 'incident', i.id, 'submit');
    notifyListeners();
    return i;
  }

  @override
  Future<PollingResult> approveResult(String resultId, {String? note}) async {
    final user = _current;
    if (user == null) throw StateError('Not logged in');
    final idx = _results.indexWhere((r) => r.id == resultId);
    if (idx < 0) throw StateError('Result not found');
    final current = _results[idx];
    final next = ResultStatus.nextOnApprove(current.status);
    if (next == null) throw StateError('Cannot approve from ${current.status}');

    // Role gate
    final expected = ResultStatus.expectedQueueStatusForRole(user.role);
    if (user.role != AppRoles.superAdmin && expected != null && current.status != expected) {
      throw StateError('Role ${user.role} cannot approve status ${current.status}');
    }

    final updated = current.copyWith(status: next, rejectionReason: null);
    _results[idx] = updated;
    _approvals.add(ApprovalRecord(
      id: _uuid.v4(),
      resultId: resultId,
      actorId: user.id,
      fromStatus: current.status,
      toStatus: next,
      reason: note,
      createdAt: DateTime.now(),
    ));
    _auditAdd(user.id, 'polling_result', resultId, 'approve', meta: {'to': next});
    notifyListeners();
    return updated;
  }

  @override
  Future<PollingResult> rejectResult(String resultId, {required String reason}) async {
    final user = _current;
    if (user == null) throw StateError('Not logged in');
    final idx = _results.indexWhere((r) => r.id == resultId);
    if (idx < 0) throw StateError('Result not found');
    final current = _results[idx];
    final updated = current.copyWith(status: ResultStatus.rejected, rejectionReason: reason);
    _results[idx] = updated;
    _approvals.add(ApprovalRecord(
      id: _uuid.v4(),
      resultId: resultId,
      actorId: user.id,
      fromStatus: current.status,
      toStatus: ResultStatus.rejected,
      reason: reason,
      createdAt: DateTime.now(),
    ));
    _auditAdd(user.id, 'polling_result', resultId, 'reject', meta: {'reason': reason});
    notifyListeners();
    return updated;
  }

  @override
  Future<int> syncPending() async {
    final queue = _hive.syncQueue();
    var n = 0;
    for (final item in queue) {
      switch (item.type) {
        case 'result':
          final r = PollingResult.fromMap(item.payload);
          await submitResult(r, offline: false);
          break;
        case 'incident':
          final i = Incident.fromMap(item.payload);
          await submitIncident(i, offline: false);
          break;
        case 'opening':
          final o = OpeningReport.fromMap(item.payload);
          await submitOpening(o, offline: false);
          break;
      }
      await _hive.removeFromQueue(item.id);
      n++;
    }
    notifyListeners();
    return n;
  }

  void _auditAdd(String? actor, String type, String id, String action, {Map<String, dynamic>? meta}) {
    _audit.add(AuditEntry(
      id: _uuid.v4(),
      actorId: actor,
      entityType: type,
      entityId: id,
      action: action,
      meta: meta,
      createdAt: DateTime.now(),
    ));
  }

}
