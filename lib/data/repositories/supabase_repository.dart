import '../models/models.dart';
import 'emr_repository.dart';

/// Future Supabase-backed implementation. Not used in the local demo.
/// Wire by swapping [repositoryProvider] once a Supabase project + anon key exist.
class SupabaseRepository implements EmrRepository {
  SupabaseRepository({required this.supabaseUrl, required this.anonKey});

  final String supabaseUrl;
  final String anonKey;

  Never _unimplemented() =>
      throw UnimplementedError('SupabaseRepository is a stub. Use DemoRepository for local demo.');

  @override
  Future<void> initialize() async => _unimplemented();
  @override
  List<StateGeo> get states => _unimplemented();
  @override
  List<Party> get parties => _unimplemented();
  @override
  ElectionInfo get election => _unimplemented();
  @override
  List<DemoUser> get demoUsers => _unimplemented();
  @override
  DemoUser? get currentUser => null;
  @override
  Future<void> loginAs(DemoUser user) async => _unimplemented();
  @override
  Future<void> logout() async => _unimplemented();
  @override
  List<PollingUnitGeo> assignedUnitsFor(DemoUser user) => _unimplemented();
  @override
  PollingUnitGeo? findPu(String id) => _unimplemented();
  @override
  ({StateGeo state, LgaGeo lga, WardGeo ward, PollingUnitGeo pu})? resolvePu(String puId) =>
      _unimplemented();
  @override
  List<PollingResult> results({String? status, String? submittedBy, String? wardId, String? lgaId, String? stateId}) =>
      _unimplemented();
  @override
  List<Incident> incidents({String? reporterId}) => _unimplemented();
  @override
  List<OpeningReport> openingReports({String? reporterId}) => _unimplemented();
  @override
  List<ApprovalRecord> approvalsFor(String resultId) => _unimplemented();
  @override
  List<AuditEntry> auditLog() => _unimplemented();
  @override
  List<SyncQueueItem> syncQueue() => _unimplemented();
  @override
  Future<PollingResult> submitResult(PollingResult result, {bool offline = false}) async =>
      _unimplemented();
  @override
  Future<OpeningReport> submitOpening(OpeningReport report, {bool offline = false}) async =>
      _unimplemented();
  @override
  Future<Incident> submitIncident(Incident incident, {bool offline = false}) async =>
      _unimplemented();
  @override
  Future<PollingResult> approveResult(String resultId, {String? note}) async => _unimplemented();
  @override
  Future<PollingResult> rejectResult(String resultId, {required String reason}) async =>
      _unimplemented();
  @override
  Future<int> syncPending() async => _unimplemented();
  @override
  void addListener(void Function() listener) {}
  @override
  void removeListener(void Function() listener) {}
}
