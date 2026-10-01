import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../local/hive_drafts.dart';
import '../repositories/demo_repository.dart';
import '../repositories/emr_repository.dart';
import '../models/models.dart';

final hiveStoreProvider = Provider<HiveDraftStore>((ref) => HiveDraftStore());

/// Swap to SupabaseRepository when a live project is configured.
final repositoryProvider = Provider<EmrRepository>((ref) {
  return DemoRepository(ref.watch(hiveStoreProvider));
});

final repoInitProvider = FutureProvider<EmrRepository>((ref) async {
  final repo = ref.watch(repositoryProvider);
  await repo.initialize();
  return repo;
});

/// Tick when demo repo notifies (login, submit, approve…).
final sessionProvider = NotifierProvider<SessionNotifier, DemoUser?>(SessionNotifier.new);

class SessionNotifier extends Notifier<DemoUser?> {
  @override
  DemoUser? build() {
    final repo = ref.watch(repositoryProvider);
    void onChange() => state = repo.currentUser;
    repo.addListener(onChange);
    ref.onDispose(() => repo.removeListener(onChange));
    return repo.currentUser;
  }

  Future<void> login(DemoUser user) async {
    await ref.read(repositoryProvider).loginAs(user);
    state = user;
  }

  Future<void> logout() async {
    await ref.read(repositoryProvider).logout();
    state = null;
  }
}

final resultsTickProvider = NotifierProvider<ResultsTickNotifier, int>(ResultsTickNotifier.new);

class ResultsTickNotifier extends Notifier<int> {
  @override
  int build() {
    final repo = ref.watch(repositoryProvider);
    void onChange() => state = state + 1;
    repo.addListener(onChange);
    ref.onDispose(() => repo.removeListener(onChange));
    return 0;
  }
}
