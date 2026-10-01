class ResultValidation {
  final bool ok;
  final List<String> errors;
  final List<String> warnings;

  const ResultValidation({
    required this.ok,
    this.errors = const [],
    this.warnings = const [],
  });
}

ResultValidation validateResultVotes({
  required Map<String, int> partyVotes,
  required int accredited,
  required int invalid,
}) {
  final errors = <String>[];
  final warnings = <String>[];
  if (partyVotes.isEmpty) errors.add('Enter at least one party vote line.');
  for (final e in partyVotes.entries) {
    if (e.value < 0) errors.add('${e.key}: votes cannot be negative.');
  }
  final total = partyVotes.values.fold<int>(0, (a, b) => a + b);
  if (accredited < 0) errors.add('Accredited voters cannot be negative.');
  if (invalid < 0) errors.add('Invalid votes cannot be negative.');
  if (total + invalid > accredited && accredited > 0) {
    warnings.add(
      'Party votes ($total) + invalid ($invalid) exceed accredited ($accredited).',
    );
  }
  if (total == 0 && accredited > 0) {
    warnings.add('Accredited voters set but all party votes are zero.');
  }
  return ResultValidation(ok: errors.isEmpty, errors: errors, warnings: warnings);
}
