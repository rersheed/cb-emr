import '../models/models.dart';

/// Abstraction shared by [DemoRepository] and future [SupabaseRepository].
abstract class EmrRepository {
  Future<void> initialize();

  List<StateGeo> get states;
  List<Party> get parties;
  ElectionInfo get election;
  List<DemoUser> get demoUsers;

  DemoUser? get currentUser;
  Future<void> loginAs(DemoUser user);
  Future<void> logout();

  List<PollingUnitGeo> assignedUnitsFor(DemoUser user);
  PollingUnitGeo? findPu(String id);
  ({StateGeo state, LgaGeo lga, WardGeo ward, PollingUnitGeo pu})? resolvePu(String puId);

  List<PollingResult> results({String? status, String? submittedBy, String? wardId, String? lgaId, String? stateId});
  List<Incident> incidents({String? reporterId});
  List<OpeningReport> openingReports({String? reporterId});
  List<ApprovalRecord> approvalsFor(String resultId);
  List<AuditEntry> auditLog();
  List<SyncQueueItem> syncQueue();

  Future<PollingResult> submitResult(PollingResult result, {bool offline = false});
  Future<OpeningReport> submitOpening(OpeningReport report, {bool offline = false});
  Future<Incident> submitIncident(Incident incident, {bool offline = false});

  Future<PollingResult> approveResult(String resultId, {String? note});
  Future<PollingResult> rejectResult(String resultId, {required String reason});

  Future<int> syncPending();

  void addListener(void Function() listener);
  void removeListener(void Function() listener);
}
