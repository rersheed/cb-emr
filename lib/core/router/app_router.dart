import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/agent/presentation/agent_shell.dart';
import '../../features/agent/presentation/pu_screen.dart';
import '../../features/agent/presentation/opening_form_screen.dart';
import '../../features/agent/presentation/incident_form_screen.dart';
import '../../features/agent/presentation/result_entry_screen.dart';
import '../../features/supervisor/presentation/approval_queue_screen.dart';
import '../../features/offline/presentation/sync_queue_screen.dart';
import '../../features/situation_room/presentation/situation_room_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(sessionProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/forgot' || loc == '/splash';
      if (user == null && !loggingIn) return '/login';
      if (user != null && (loc == '/login' || loc == '/splash')) {
        return _homeForRole(user.role);
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/agent', builder: (_, __) => const AgentShell()),
      GoRoute(
        path: '/agent/pu/:puId',
        builder: (_, s) => PuScreen(puId: s.pathParameters['puId']!),
      ),
      GoRoute(
        path: '/agent/opening/:puId',
        builder: (_, s) => OpeningFormScreen(puId: s.pathParameters['puId']!),
      ),
      GoRoute(
        path: '/agent/incident/:puId',
        builder: (_, s) => IncidentFormScreen(puId: s.pathParameters['puId']!),
      ),
      GoRoute(
        path: '/agent/result/:puId',
        builder: (_, s) => ResultEntryScreen(puId: s.pathParameters['puId']!),
      ),
      GoRoute(path: '/supervisor', builder: (_, __) => const ApprovalQueueScreen()),
      GoRoute(path: '/offline', builder: (_, __) => const SyncQueueScreen()),
      GoRoute(path: '/situation-room', builder: (_, __) => const SituationRoomScreen()),
    ],
  );
});

String _homeForRole(String role) {
  switch (role) {
    case AppRoles.fieldAgent:
      return '/agent';
    case AppRoles.wardSupervisor:
    case AppRoles.lgaSupervisor:
    case AppRoles.stateSupervisor:
    case AppRoles.superAdmin:
      return '/supervisor';
    case AppRoles.situationRoom:
      return '/situation-room';
    default:
      return '/agent';
  }
}

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _ref.listen(sessionProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}
