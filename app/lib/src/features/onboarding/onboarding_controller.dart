import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tideline/src/providers.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/services/tls.dart';
import 'package:wavelog_client/wavelog_client.dart';

/// Onboarding steps.
enum OnboardingStep {
  /// What Tideline is.
  welcome,

  /// Server address.
  server,

  /// API token and permissions.
  token,

  /// Station location.
  station,
}

/// Problems the onboarding explains in plain language.
enum OnboardingProblem {
  /// Not a usable address.
  invalidUrl,

  /// http:// to a public address: never allowed.
  insecurePublicHttp,

  /// http:// on the LAN without the explicit opt-in.
  httpNeedsOptIn,

  /// No answer from the server.
  unreachable,

  /// The server answers, but not with Wavelog API v2 (older than 3.1.0, or
  /// not Wavelog).
  noApiV2,

  /// The token is not valid.
  tokenInvalid,

  /// The token expired.
  tokenExpired,

  /// The token lacks required permissions.
  missingScopes,

  /// The server had a problem.
  serverError,

  /// The pinned certificate is still not accepted.
  certificateRejected,
}

/// State of the onboarding flow.
class OnboardingState {
  /// Creates the state.
  const new({
    this.step = OnboardingStep.welcome,
    this.endpoint,
    this.label = '',
    this.allowHttpLan = false,
    this.busy = false,
    this.problem,
    this.untrustedCertificate,
    this.pinnedSha256,
    this.capabilities,
    this.stations = const [],
    this.token,
  });

  /// Current step.
  final OnboardingStep step;

  /// Parsed server address.
  final WavelogEndpoint? endpoint;

  /// Account name.
  final String label;

  /// Plain-HTTP opt-in (LAN only).
  final bool allowHttpLan;

  /// A check is running.
  final bool busy;

  /// The last problem, if any.
  final OnboardingProblem? problem;

  /// A certificate the platform rejected, awaiting the user's decision.
  final CertificateInfo? untrustedCertificate;

  /// The fingerprint the user chose to trust.
  final String? pinnedSha256;

  /// What the server and token support.
  final ServerCapabilities? capabilities;

  /// The user's station locations.
  final List<WavelogStation> stations;

  /// The token, kept only until the account is saved.
  final String? token;

  /// A copy with changes. Pass `clear*` flags to reset nullable fields.
  OnboardingState copyWith({
    OnboardingStep? step,
    WavelogEndpoint? endpoint,
    String? label,
    bool? allowHttpLan,
    bool? busy,
    OnboardingProblem? problem,
    bool clearProblem = false,
    CertificateInfo? untrustedCertificate,
    bool clearCertificate = false,
    String? pinnedSha256,
    ServerCapabilities? capabilities,
    List<WavelogStation>? stations,
    String? token,
  }) => OnboardingState(
    step: step ?? this.step,
    endpoint: endpoint ?? this.endpoint,
    label: label ?? this.label,
    allowHttpLan: allowHttpLan ?? this.allowHttpLan,
    busy: busy ?? this.busy,
    problem: clearProblem ? null : (problem ?? this.problem),
    untrustedCertificate: clearCertificate
        ? null
        : (untrustedCertificate ?? this.untrustedCertificate),
    pinnedSha256: pinnedSha256 ?? this.pinnedSha256,
    capabilities: capabilities ?? this.capabilities,
    stations: stations ?? this.stations,
    token: token ?? this.token,
  );
}

/// Drives onboarding. Nothing is stored until [finish].
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  /// Moves to [step] (back navigation).
  void goTo(OnboardingStep step) =>
      state = state.copyWith(step: step, clearProblem: true);

  /// Validates the address and continues to the token step.
  void submitServer({
    required String url,
    required String label,
    required bool allowHttpLan,
  }) {
    try {
      final endpoint = WavelogEndpoint.parse(
        url,
        allowHttpOnPrivateNetwork: allowHttpLan,
      );
      state = state.copyWith(
        endpoint: endpoint,
        label: label.trim().isEmpty ? endpoint.baseUri.host : label.trim(),
        allowHttpLan: allowHttpLan,
        step: OnboardingStep.token,
        clearProblem: true,
      );
    } on InvalidServerUrlException catch (e) {
      state = state.copyWith(
        problem: switch (e.reason) {
          InvalidServerUrlReason.insecurePublicHttp =>
            OnboardingProblem.insecurePublicHttp,
          InvalidServerUrlReason.httpNotAllowed =>
            OnboardingProblem.httpNeedsOptIn,
          _ => OnboardingProblem.invalidUrl,
        },
      );
    }
  }

  /// Checks the server with [token].
  Future<void> submitToken(String token) async {
    final endpoint = state.endpoint;
    if (endpoint == null) return;
    state = state.copyWith(busy: true, clearProblem: true, token: token.trim());
    final http = pinnedHttpClient(
      host: endpoint.baseUri.host,
      pinnedSha256: state.pinnedSha256,
    );
    try {
      final caps = await probeServer(
        endpoint: endpoint,
        token: token.trim(),
        httpClient: http,
      );
      if (caps.missingRequiredScopes.isNotEmpty) {
        state = state.copyWith(
          busy: false,
          capabilities: caps,
          problem: OnboardingProblem.missingScopes,
        );
        return;
      }
      final client = WavelogClient(
        endpoint: WavelogEndpoint(
          endpoint.baseUri,
          usesIndexPhp: caps.usesIndexPhp,
        ),
        token: token.trim(),
        httpClient: http,
      );
      final stations = await client.stations();
      state = state.copyWith(
        busy: false,
        capabilities: caps,
        stations: stations,
        step: OnboardingStep.station,
      );
    } on WavelogNetworkError catch (e) {
      if (e.reason.startsWith('tls') && state.pinnedSha256 == null) {
        final cert = await inspectUntrustedCertificate(
          endpoint.resolve('status'),
        );
        if (cert != null) {
          state = state.copyWith(busy: false, untrustedCertificate: cert);
          return;
        }
      }
      state = state.copyWith(
        busy: false,
        problem: state.pinnedSha256 != null && e.reason.startsWith('tls')
            ? OnboardingProblem.certificateRejected
            : OnboardingProblem.unreachable,
      );
    } on WavelogUnauthorized catch (e) {
      state = state.copyWith(
        busy: false,
        problem: e.isExpired
            ? OnboardingProblem.tokenExpired
            : OnboardingProblem.tokenInvalid,
      );
    } on WavelogNotFound {
      state = state.copyWith(busy: false, problem: OnboardingProblem.noApiV2);
    } on WavelogMalformedResponse {
      state = state.copyWith(busy: false, problem: OnboardingProblem.noApiV2);
    } on WavelogException {
      state = state.copyWith(
        busy: false,
        problem: OnboardingProblem.serverError,
      );
    } finally {
      http.close();
    }
  }

  /// The user compared the fingerprint and trusts this certificate.
  Future<void> trustCertificate() async {
    final cert = state.untrustedCertificate;
    final token = state.token;
    if (cert == null || token == null) return;
    state = state.copyWith(pinnedSha256: cert.sha256, clearCertificate: true);
    await submitToken(token);
  }

  /// The user does not trust the certificate.
  void rejectCertificate() => state = state.copyWith(
    clearCertificate: true,
    problem: OnboardingProblem.certificateRejected,
  );

  /// Saves the account with [stationId] as default station. Returns the
  /// new account id.
  Future<String?> finish(int stationId) async {
    final endpoint = state.endpoint;
    final caps = state.capabilities;
    final token = state.token;
    if (endpoint == null || caps == null || token == null) return null;
    state = state.copyWith(busy: true);
    final accounts = ref.read(accountRepositoryProvider);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final id = await accounts.add(
      label: state.label,
      baseUrl: endpoint.baseUri.toString(),
      usesIndexPhp: caps.usesIndexPhp,
      token: token,
      scopes: caps.token.scopes,
      hasContestSessions: caps.hasContestSessions,
      nowMillis: now,
      allowHttpLan: state.allowHttpLan,
      certPinSha256: state.pinnedSha256,
      tokenExpiresAt: caps.token.expiresAt?.millisecondsSinceEpoch,
    );
    await accounts.syncStations(id, [
      for (final s in state.stations)
        (
          remoteId: s.id,
          name: s.name,
          callsign: s.callsign,
          grid: s.gridsquare,
          active: s.active,
        ),
    ], nowMillis: now);
    final settings = ref.read(settingsStoreProvider);
    await settings.write('account.active', id);
    await settings.write('account.$id.defaultStation', '$stationId');
    state = const OnboardingState();
    return id;
  }
}

/// The onboarding controller.
final onboardingProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
