import '../models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../core/supabase_config.dart';

ElectionInfo get kDemoElection => ElectionInfo(
      id: SupabaseConfig.demoElectionId,
      name: '2027 General Election (Demo)',
      electionDate: DateTime(2027, 2, 25),
      status: 'active',
    );

const kParties = <Party>[
  Party(id: 'apc', name: 'All Progressives Congress', acronym: 'APC', colorHex: '#39a453'),
  Party(id: 'pdp', name: 'Peoples Democratic Party', acronym: 'PDP', colorHex: '#5cc3e7'),
  Party(id: 'nnpp', name: 'New Nigeria Peoples Party', acronym: 'NNPP', colorHex: '#e52b32'),
  Party(id: 'lp', name: 'Labour Party', acronym: 'LP', colorHex: '#976532'),
];

/// Stable UUIDs — match seeded `profiles` rows in Supabase.
class DemoProfileIds {
  static const agent = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0001';
  static const ward = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0002';
  static const lga = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0003';
  static const state = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0004';
  static const sitroom = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0005';
  static const admin = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaa0006';
}

/// Demo users — passwordless picker. Geography ids match trimmed NW asset.
List<DemoUser> buildDemoUsers({
  required String kadunaStateId,
  required String kadunaNorthLgaId,
  required String demoWardId,
  required List<String> agentPuIds,
}) {
  return [
    DemoUser(
      id: DemoProfileIds.agent,
      email: 'agent.amina@cb-emr.demo',
      fullName: 'Amina Mohammed',
      role: AppRoles.fieldAgent,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
      wardId: demoWardId,
      assignedPuIds: agentPuIds,
    ),
    DemoUser(
      id: DemoProfileIds.ward,
      email: 'ward.ibrahim@cb-emr.demo',
      fullName: 'Ibrahim Garba',
      role: AppRoles.wardSupervisor,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
      wardId: demoWardId,
    ),
    DemoUser(
      id: DemoProfileIds.lga,
      email: 'lga.aisha@cb-emr.demo',
      fullName: 'Aisha Suleiman',
      role: AppRoles.lgaSupervisor,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
    ),
    DemoUser(
      id: DemoProfileIds.state,
      email: 'state.sani@cb-emr.demo',
      fullName: 'Sani Bello',
      role: AppRoles.stateSupervisor,
      stateId: kadunaStateId,
    ),
    DemoUser(
      id: DemoProfileIds.sitroom,
      email: 'sitroom.hauwa@cb-emr.demo',
      fullName: 'Hauwa Ibrahim',
      role: AppRoles.situationRoom,
    ),
    DemoUser(
      id: DemoProfileIds.admin,
      email: 'admin.amina@cb-emr.demo',
      fullName: 'Amina Yusuf',
      role: AppRoles.superAdmin,
    ),
  ];
}
