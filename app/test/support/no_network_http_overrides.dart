import 'dart:io';

/// Offline guardrail (SPRINT_PLAN invariant #4). Any attempt to open an HTTP
/// connection throws immediately, so a test that drives a flow under this
/// override *fails* if a network call sneaks in. Introduced in Sprint 1 and
/// extended sprint-by-sprint to cover the full journey by Sprint 7.
class NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw StateError(
      'Network access attempted — the 100%-offline invariant was violated.',
    );
  }
}

/// Runs [body] with the network sealed off, restoring any previous overrides.
Future<void> withNoNetwork(Future<void> Function() body) async {
  final previous = HttpOverrides.current;
  HttpOverrides.global = NoNetworkHttpOverrides();
  try {
    await body();
  } finally {
    HttpOverrides.global = previous;
  }
}
