/// Public Supabase client config (anon key is safe for client apps).
/// Prefer `--dart-define=SUPABASE_URL=...` and `SUPABASE_ANON_KEY=...` at build time.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sullcpwiddjrbzhlqfrn.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN1bGxjcHdpZGRqcmJ6aGxxZnJuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4ODcxMjEsImV4cCI6MjEwNjQ2MzEyMX0.OSm02u4jORZ4zWJZd6JDSXIR3NByS4uTMupYGqAjI6c',
  );

  static const String projectRef = 'sullcpwiddjrbzhlqfrn';

  /// Fixed demo election id matching seeded `elections` row.
  static const String demoElectionId = '11111111-1111-1111-1111-111111111111';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
