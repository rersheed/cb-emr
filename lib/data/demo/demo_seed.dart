import '../models/models.dart';
import '../../core/constants/app_constants.dart';

ElectionInfo get kDemoElection => ElectionInfo(
      id: 'elec-nw-2026-demo',
      name: 'NW Demo Gubernatorial 2026',
      electionDate: DateTime(2026, 11, 15),
      status: 'active',
    );

const kParties = <Party>[
  Party(id: 'apc', name: 'All Progressives Congress', acronym: 'APC', colorHex: '#39a453'),
  Party(id: 'pdp', name: 'Peoples Democratic Party', acronym: 'PDP', colorHex: '#e52b32'),
  Party(id: 'nnpp', name: 'New Nigeria Peoples Party', acronym: 'NNPP', colorHex: '#5cc3e7'),
  Party(id: 'lp', name: 'Labour Party', acronym: 'LP', colorHex: '#976532'),
];

/// Demo users — passwordless picker. Geography ids match trimmed NW asset.
List<DemoUser> buildDemoUsers({
  required String kadunaStateId,
  required String kadunaNorthLgaId,
  required String demoWardId,
  required List<String> agentPuIds,
}) {
  return [
    DemoUser(
      id: 'usr-agent-1',
      email: 'agent.amina@cb-emr.demo',
      fullName: 'Amina Mohammed',
      role: AppRoles.fieldAgent,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
      wardId: demoWardId,
      assignedPuIds: agentPuIds,
    ),
    DemoUser(
      id: 'usr-ward-1',
      email: 'ward.ibrahim@cb-emr.demo',
      fullName: 'Ibrahim Garba',
      role: AppRoles.wardSupervisor,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
      wardId: demoWardId,
    ),
    DemoUser(
      id: 'usr-lga-1',
      email: 'lga.aisha@cb-emr.demo',
      fullName: 'Aisha Suleiman',
      role: AppRoles.lgaSupervisor,
      stateId: kadunaStateId,
      lgaId: kadunaNorthLgaId,
    ),
    DemoUser(
      id: 'usr-state-1',
      email: 'state.sani@cb-emr.demo',
      fullName: 'Sani Bello',
      role: AppRoles.stateSupervisor,
      stateId: kadunaStateId,
    ),
    DemoUser(
      id: 'usr-sitroom-1',
      email: 'sitroom.hauwa@cb-emr.demo',
      fullName: 'Hauwa Ibrahim',
      role: AppRoles.situationRoom,
    ),
    DemoUser(
      id: 'usr-admin-1',
      email: 'admin.amina@cb-emr.demo',
      fullName: 'Amina Yusuf',
      role: AppRoles.superAdmin,
    ),
  ];
}
