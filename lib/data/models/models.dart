import 'package:equatable/equatable.dart';

class StateGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<LgaGeo> lgas;
  const StateGeo({required this.id, required this.name, required this.code, required this.lgas});
  @override
  List<Object?> get props => [id];
}

class LgaGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<WardGeo> wards;
  const LgaGeo({required this.id, required this.name, required this.code, required this.wards});
  @override
  List<Object?> get props => [id];
}

class WardGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  final double? lat;
  final double? lon;
  final List<PollingUnitGeo> pollingUnits;
  const WardGeo({
    required this.id,
    required this.name,
    required this.code,
    this.lat,
    this.lon,
    required this.pollingUnits,
  });
  @override
  List<Object?> get props => [id];
}

class PollingUnitGeo extends Equatable {
  final String id;
  final String name;
  final String code;
  const PollingUnitGeo({required this.id, required this.name, required this.code});
  @override
  List<Object?> get props => [id];
}

class DemoUser extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? stateId;
  final String? lgaId;
  final String? wardId;
  final List<String> assignedPuIds;
  const DemoUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.stateId,
    this.lgaId,
    this.wardId,
    this.assignedPuIds = const [],
  });
  @override
  List<Object?> get props => [id];
}

class Party extends Equatable {
  final String id;
  final String name;
  final String acronym;
  final String colorHex;
  const Party({required this.id, required this.name, required this.acronym, required this.colorHex});
  @override
  List<Object?> get props => [id];
}

class ElectionInfo extends Equatable {
  final String id;
  final String name;
  final DateTime electionDate;
  final String status;
  const ElectionInfo({
    required this.id,
    required this.name,
    required this.electionDate,
    required this.status,
  });
  @override
  List<Object?> get props => [id];
}

class PollingResult extends Equatable {
  final String id;
  final String electionId;
  final String pollingUnitId;
  final String submittedBy;
  final int accreditedVoters;
  final int validVotes;
  final int invalidVotes;
  final String status;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final Map<String, int> partyVotes; // partyId -> votes
  final String? puName;
  final String? wardId;
  final String? lgaId;
  final String? stateId;

  const PollingResult({
    required this.id,
    required this.electionId,
    required this.pollingUnitId,
    required this.submittedBy,
    required this.accreditedVoters,
    required this.validVotes,
    required this.invalidVotes,
    required this.status,
    this.rejectionReason,
    this.submittedAt,
    required this.partyVotes,
    this.puName,
    this.wardId,
    this.lgaId,
    this.stateId,
  });

  int get totalPartyVotes => partyVotes.values.fold(0, (a, b) => a + b);

  PollingResult copyWith({
    String? status,
    String? rejectionReason,
    DateTime? submittedAt,
    int? accreditedVoters,
    int? validVotes,
    int? invalidVotes,
    Map<String, int>? partyVotes,
  }) =>
      PollingResult(
        id: id,
        electionId: electionId,
        pollingUnitId: pollingUnitId,
        submittedBy: submittedBy,
        accreditedVoters: accreditedVoters ?? this.accreditedVoters,
        validVotes: validVotes ?? this.validVotes,
        invalidVotes: invalidVotes ?? this.invalidVotes,
        status: status ?? this.status,
        rejectionReason: rejectionReason,
        submittedAt: submittedAt ?? this.submittedAt,
        partyVotes: partyVotes ?? this.partyVotes,
        puName: puName,
        wardId: wardId,
        lgaId: lgaId,
        stateId: stateId,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'electionId': electionId,
        'pollingUnitId': pollingUnitId,
        'submittedBy': submittedBy,
        'accreditedVoters': accreditedVoters,
        'validVotes': validVotes,
        'invalidVotes': invalidVotes,
        'status': status,
        'rejectionReason': rejectionReason,
        'submittedAt': submittedAt?.toIso8601String(),
        'partyVotes': partyVotes,
        'puName': puName,
        'wardId': wardId,
        'lgaId': lgaId,
        'stateId': stateId,
      };

  factory PollingResult.fromMap(Map<dynamic, dynamic> m) => PollingResult(
        id: m['id'] as String,
        electionId: m['electionId'] as String,
        pollingUnitId: m['pollingUnitId'] as String,
        submittedBy: m['submittedBy'] as String,
        accreditedVoters: m['accreditedVoters'] as int,
        validVotes: m['validVotes'] as int,
        invalidVotes: m['invalidVotes'] as int,
        status: m['status'] as String,
        rejectionReason: m['rejectionReason'] as String?,
        submittedAt: m['submittedAt'] != null ? DateTime.parse(m['submittedAt'] as String) : null,
        partyVotes: Map<String, int>.from(m['partyVotes'] as Map),
        puName: m['puName'] as String?,
        wardId: m['wardId'] as String?,
        lgaId: m['lgaId'] as String?,
        stateId: m['stateId'] as String?,
      );

  @override
  List<Object?> get props => [id, status, partyVotes];
}

class OpeningReport extends Equatable {
  final String id;
  final String electionId;
  final String pollingUnitId;
  final String reporterId;
  final DateTime openedAt;
  final bool materialsComplete;
  final bool officialsPresent;
  final String? notes;
  final double? gpsLat;
  final double? gpsLon;
  final String status;
  final String? puName;

  const OpeningReport({
    required this.id,
    required this.electionId,
    required this.pollingUnitId,
    required this.reporterId,
    required this.openedAt,
    required this.materialsComplete,
    required this.officialsPresent,
    this.notes,
    this.gpsLat,
    this.gpsLon,
    required this.status,
    this.puName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'electionId': electionId,
        'pollingUnitId': pollingUnitId,
        'reporterId': reporterId,
        'openedAt': openedAt.toIso8601String(),
        'materialsComplete': materialsComplete,
        'officialsPresent': officialsPresent,
        'notes': notes,
        'gpsLat': gpsLat,
        'gpsLon': gpsLon,
        'status': status,
        'puName': puName,
      };

  factory OpeningReport.fromMap(Map<dynamic, dynamic> m) => OpeningReport(
        id: m['id'] as String,
        electionId: m['electionId'] as String,
        pollingUnitId: m['pollingUnitId'] as String,
        reporterId: m['reporterId'] as String,
        openedAt: DateTime.parse(m['openedAt'] as String),
        materialsComplete: m['materialsComplete'] as bool,
        officialsPresent: m['officialsPresent'] as bool,
        notes: m['notes'] as String?,
        gpsLat: (m['gpsLat'] as num?)?.toDouble(),
        gpsLon: (m['gpsLon'] as num?)?.toDouble(),
        status: m['status'] as String,
        puName: m['puName'] as String?,
      );

  @override
  List<Object?> get props => [id];
}

class Incident extends Equatable {
  final String id;
  final String electionId;
  final String pollingUnitId;
  final String reporterId;
  final String category;
  final String description;
  final String? photoPath;
  final double? gpsLat;
  final double? gpsLon;
  final String severity;
  final String status;
  final DateTime createdAt;
  final String? puName;

  const Incident({
    required this.id,
    required this.electionId,
    required this.pollingUnitId,
    required this.reporterId,
    required this.category,
    required this.description,
    this.photoPath,
    this.gpsLat,
    this.gpsLon,
    required this.severity,
    required this.status,
    required this.createdAt,
    this.puName,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'electionId': electionId,
        'pollingUnitId': pollingUnitId,
        'reporterId': reporterId,
        'category': category,
        'description': description,
        'photoPath': photoPath,
        'gpsLat': gpsLat,
        'gpsLon': gpsLon,
        'severity': severity,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'puName': puName,
      };

  factory Incident.fromMap(Map<dynamic, dynamic> m) => Incident(
        id: m['id'] as String,
        electionId: m['electionId'] as String,
        pollingUnitId: m['pollingUnitId'] as String,
        reporterId: m['reporterId'] as String,
        category: m['category'] as String,
        description: m['description'] as String,
        photoPath: m['photoPath'] as String?,
        gpsLat: (m['gpsLat'] as num?)?.toDouble(),
        gpsLon: (m['gpsLon'] as num?)?.toDouble(),
        severity: m['severity'] as String,
        status: m['status'] as String,
        createdAt: DateTime.parse(m['createdAt'] as String),
        puName: m['puName'] as String?,
      );

  @override
  List<Object?> get props => [id];
}

class ApprovalRecord extends Equatable {
  final String id;
  final String resultId;
  final String actorId;
  final String fromStatus;
  final String toStatus;
  final String? reason;
  final DateTime createdAt;
  const ApprovalRecord({
    required this.id,
    required this.resultId,
    required this.actorId,
    required this.fromStatus,
    required this.toStatus,
    this.reason,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

class AuditEntry extends Equatable {
  final String id;
  final String? actorId;
  final String entityType;
  final String entityId;
  final String action;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;
  const AuditEntry({
    required this.id,
    this.actorId,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.meta,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id];
}

class SyncQueueItem extends Equatable {
  final String id;
  final String type; // result | incident | opening
  final Map<String, dynamic> payload;
  final DateTime enqueuedAt;
  const SyncQueueItem({
    required this.id,
    required this.type,
    required this.payload,
    required this.enqueuedAt,
  });
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'payload': payload,
        'enqueuedAt': enqueuedAt.toIso8601String(),
      };
  factory SyncQueueItem.fromMap(Map<dynamic, dynamic> m) => SyncQueueItem(
        id: m['id'] as String,
        type: m['type'] as String,
        payload: Map<String, dynamic>.from(m['payload'] as Map),
        enqueuedAt: DateTime.parse(m['enqueuedAt'] as String),
      );
  @override
  List<Object?> get props => [id];
}
