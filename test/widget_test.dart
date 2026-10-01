import 'package:flutter_test/flutter_test.dart';
import 'package:cb_emr/core/utils/validators.dart';
import 'package:cb_emr/core/constants/app_constants.dart';

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
    expect(ResultStatus.nextOnApprove(ResultStatus.pendingWard), ResultStatus.pendingLga);
    expect(ResultStatus.nextOnApprove(ResultStatus.pendingLga), ResultStatus.pendingState);
    expect(ResultStatus.nextOnApprove(ResultStatus.pendingState), ResultStatus.stateVerified);
  });
}
