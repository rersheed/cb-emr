import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cb_emr/core/theme/app_theme.dart';
import 'package:cb_emr/core/utils/validators.dart';
import 'package:cb_emr/core/constants/app_constants.dart';
import 'package:cb_emr/core/widgets/ui_kit.dart';
import 'package:cb_emr/data/models/models.dart';

void main() {
  test('result validation accepts normal votes', () {
    final v = validateResultVotes(
      partyVotes: {'apc': 10, 'pdp': 5},
      accredited: 20,
      invalid: 1,
    );
    expect(v.ok, isTrue);
  });

  test('result validation rejects negatives', () {
    final v = validateResultVotes(
      partyVotes: {'apc': -1},
      accredited: 10,
      invalid: 0,
    );
    expect(v.ok, isFalse);
  });

  test('approval next status chain', () {
    expect(
      ResultStatus.nextOnApprove(ResultStatus.pendingWard),
      ResultStatus.pendingLga,
    );
    expect(
      ResultStatus.nextOnApprove(ResultStatus.pendingLga),
      ResultStatus.pendingState,
    );
    expect(
      ResultStatus.nextOnApprove(ResultStatus.pendingState),
      ResultStatus.stateVerified,
    );
  });

  test('result evidence survives map round-trip', () {
    final r = PollingResult(
      id: 'r1',
      electionId: 'e1',
      pollingUnitId: 'pu1',
      submittedBy: 'a1',
      accreditedVoters: 100,
      validVotes: 90,
      invalidVotes: 2,
      status: ResultStatus.pendingWard,
      partyVotes: const {'apc': 50, 'pdp': 40},
      evidencePhotoPath: '/data/sheet.jpg',
      evidenceCapturedAt: DateTime.utc(2026, 11, 17, 10, 30),
    );
    final again = PollingResult.fromMap(r.toMap());
    expect(again.hasEvidence, isTrue);
    expect(again.evidencePhotoPath, '/data/sheet.jpg');
    expect(
      again.copyWith(status: ResultStatus.pendingLga).evidencePhotoPath,
      '/data/sheet.jpg',
    );
  });

  testWidgets('phone-width grids, cards, and buttons do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 736);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.78,
                children: [
                  for (final label in [
                    'Opening\nReport',
                    'Incident',
                    'Results',
                    'Materials',
                    'Approvals',
                    'History',
                  ])
                    ActionGridTile(
                      icon: Icons.circle,
                      label: label,
                      color: ApcColors.green,
                      onTap: () {},
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
                children: [
                  for (final label in [
                    'Opening report',
                    'Report incident',
                    'Enter results',
                    'Materials check',
                  ])
                    ActionGridTile(
                      icon: Icons.circle,
                      label: label,
                      color: ApcColors.blue,
                      onTap: () {},
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GradientCtaButton(
                label: 'Submit for ward approval',
                onPressed: _noop,
              ),
              const SizedBox(height: 12),
              SoftCard(
                padding: EdgeInsets.zero,
                onTap: () {},
                child: const ListTile(
                  title: Text('GOMBE ROAD/ ABG CENTRE'),
                  subtitle: Text('Code 001'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 128,
                child: SoftCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.how_to_vote_rounded, size: 18),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'GOMBE ROAD/ ABG CENTRE',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Code 001',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: FloatingPillNav(
            index: 0,
            onChanged: (_) {},
            items: const [
              (icon: Icons.home_rounded, label: 'Home'),
              (icon: Icons.how_to_vote_rounded, label: 'PUs'),
              (icon: Icons.history_rounded, label: 'History'),
              (icon: Icons.person_rounded, label: 'Account'),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
