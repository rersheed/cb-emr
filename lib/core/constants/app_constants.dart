class AppConstants {
  static const appTitle = 'CB-EMR';
  static const appSubtitle = 'City Boy Election Monitoring';
  static const geographyAsset = 'assets/data/nw_geography.json';
  static const apcLogo = 'assets/images/apc-logo.png';
  static const cityBoyLogo = 'assets/images/city-boy-logo.png';
  static const hiveDraftsBox = 'cb_emr_drafts';
  static const hiveSyncBox = 'cb_emr_sync_queue';
}

class AppRoles {
  static const fieldAgent = 'field_agent';
  static const wardSupervisor = 'ward_supervisor';
  static const lgaSupervisor = 'lga_supervisor';
  static const stateSupervisor = 'state_supervisor';
  static const situationRoom = 'situation_room';
  static const superAdmin = 'super_admin';

  static String label(String role) => switch (role) {
        fieldAgent => 'Field Agent',
        wardSupervisor => 'Ward Supervisor',
        lgaSupervisor => 'LGA Supervisor',
        stateSupervisor => 'State Supervisor',
        situationRoom => 'Situation Room Analyst',
        superAdmin => 'Super Admin',
        _ => role,
      };
}

class ResultStatus {
  static const draft = 'draft';
  static const pendingWard = 'pending_ward';
  static const pendingLga = 'pending_lga';
  static const pendingState = 'pending_state';
  static const stateVerified = 'state_verified';
  static const rejected = 'rejected';

  static const chain = [
    draft,
    pendingWard,
    pendingLga,
    pendingState,
    stateVerified,
  ];

  static String label(String s) => switch (s) {
        draft => 'Draft',
        pendingWard => 'Pending Ward',
        pendingLga => 'Pending LGA',
        pendingState => 'Pending State',
        stateVerified => 'State Verified',
        rejected => 'Rejected',
        _ => s,
      };

  static String? nextOnApprove(String current) => switch (current) {
        pendingWard => pendingLga,
        pendingLga => pendingState,
        pendingState => stateVerified,
        draft => pendingWard,
        _ => null,
      };

  static String? expectedQueueStatusForRole(String role) => switch (role) {
        AppRoles.wardSupervisor => pendingWard,
        AppRoles.lgaSupervisor => pendingLga,
        AppRoles.stateSupervisor => pendingState,
        AppRoles.superAdmin => pendingWard, // sees ward queue by default
        _ => null,
      };
}
