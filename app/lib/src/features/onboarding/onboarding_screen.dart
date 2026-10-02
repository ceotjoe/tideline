import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tideline/l10n/generated/app_localizations.dart';
import 'package:tideline/src/design/theme.dart';
import 'package:tideline/src/features/onboarding/onboarding_controller.dart';
import 'package:tideline/src/services/app_services.dart';
import 'package:tideline/src/widgets/tide_gauge.dart';

/// First-run setup: connect a Wavelog account.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const new({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _url = TextEditingController();
  final _label = TextEditingController();
  final _token = TextEditingController();
  bool _allowHttp = false;
  int? _station;

  @override
  void dispose() {
    _url.dispose();
    _label.dispose();
    _token.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    ref.listen(onboardingProvider.select((s) => s.untrustedCertificate), (
      _,
      cert,
    ) {
      if (cert != null) unawaited(_showCertificate(cert.sha256));
    });

    final step = state.step;
    final metrics = context.metrics;
    final content = switch (step) {
      OnboardingStep.welcome => _welcome(l10n, controller),
      OnboardingStep.server => _server(l10n, state, controller),
      OnboardingStep.token => _tokenStep(l10n, state, controller),
      OnboardingStep.station => _stationStep(l10n, state, controller),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TideGauge(pendingCount: 0, height: 40, showLabel: false),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(metrics.lg),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (step != OnboardingStep.welcome)
                          Padding(
                            padding: EdgeInsets.only(bottom: metrics.sm),
                            child: Text(
                              l10n.onboardingStepOf(step.index, 3),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        content,
                        if (state.problem case final problem?)
                          _ProblemCard(problem: problem, state: state),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Semantics(
    header: true,
    child: Text(text, style: Theme.of(context).textTheme.headlineMedium),
  );

  Widget _body(String text) => Padding(
    padding: EdgeInsets.symmetric(vertical: context.metrics.sm),
    child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
  );

  Widget _buttons({
    required VoidCallback? onContinue,
    required String continueLabel,
    VoidCallback? onBack,
    bool busy = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(top: context.metrics.lg),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: context.metrics.sm,
        runSpacing: context.metrics.sm,
        children: [
          if (onBack != null)
            OutlinedButton(onPressed: onBack, child: Text(l10n.actionBack)),
          FilledButton(
            onPressed: busy ? null : onContinue,
            child: busy
                ? Semantics(
                    label: l10n.onboardingChecking,
                    child: const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Text(continueLabel),
          ),
        ],
      ),
    );
  }

  Widget _welcome(AppLocalizations l10n, OnboardingController c) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _title(l10n.onboardingWelcomeTitle),
      _body(l10n.onboardingWelcomeBody),
      _buttons(
        onContinue: () => c.goTo(OnboardingStep.server),
        continueLabel: l10n.onboardingStart,
      ),
    ],
  );

  Widget _server(
    AppLocalizations l10n,
    OnboardingState state,
    OnboardingController c,
  ) {
    final isHttp = _url.text.trim().toLowerCase().startsWith('http://');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l10n.onboardingServerTitle),
        _body(l10n.onboardingServerBody),
        TextField(
          controller: _url,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.url],
          decoration: InputDecoration(
            labelText: l10n.fieldServerUrl,
            hintText: l10n.fieldServerUrlHint,
          ),
          onChanged: (_) => setState(() {}),
        ),
        SizedBox(height: context.metrics.md),
        TextField(
          controller: _label,
          decoration: InputDecoration(
            labelText: l10n.fieldAccountLabel,
            hintText: l10n.fieldAccountLabelHint,
          ),
        ),
        if (isHttp) ...[
          SizedBox(height: context.metrics.md),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.onboardingAllowHttp),
            subtitle: Text(l10n.onboardingAllowHttpWarning),
            value: _allowHttp,
            onChanged: (v) => setState(() => _allowHttp = v),
          ),
        ],
        _buttons(
          onBack: () => c.goTo(OnboardingStep.welcome),
          onContinue: () => c.submitServer(
            url: _url.text,
            label: _label.text,
            allowHttpLan: isHttp && _allowHttp,
          ),
          continueLabel: l10n.actionContinue,
        ),
      ],
    );
  }

  Widget _tokenStep(
    AppLocalizations l10n,
    OnboardingState state,
    OnboardingController c,
  ) {
    final granted = state.capabilities?.token.scopes;
    Widget scope(String name, String label) {
      final ok = granted?.contains(name);
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          ok == null
              ? Icons.radio_button_unchecked
              : ok
              ? Icons.check_circle
              : Icons.cancel_outlined,
          semanticLabel: ok == null
              ? null
              : ok
              ? l10n.scopeGranted
              : l10n.scopeMissing,
        ),
        title: Text(label),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l10n.onboardingTokenTitle),
        _body(l10n.onboardingTokenBody),
        TextField(
          controller: _token,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          enableIMEPersonalizedLearning: false,
          decoration: InputDecoration(labelText: l10n.fieldToken),
          onSubmitted: state.busy ? null : (v) => c.submitToken(v),
        ),
        SizedBox(height: context.metrics.md),
        Semantics(
          header: true,
          child: Text(
            l10n.onboardingScopesRequired,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        scope('qso:write', l10n.scopeQsoWrite),
        scope('qso:read', l10n.scopeQsoRead),
        scope('station:read', l10n.scopeStationRead),
        Semantics(
          header: true,
          child: Text(
            l10n.onboardingScopesOptional,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        scope('qso:delete', l10n.scopeQsoDelete),
        scope('contest:write', l10n.scopeContest),
        scope('lookup:read', l10n.scopeLookup),
        _buttons(
          onBack: () => c.goTo(OnboardingStep.server),
          onContinue: () => c.submitToken(_token.text),
          continueLabel: l10n.actionCheckToken,
          busy: state.busy,
        ),
      ],
    );
  }

  Widget _stationStep(
    AppLocalizations l10n,
    OnboardingState state,
    OnboardingController c,
  ) {
    final stations = state.stations;
    _station ??=
        (stations.where((s) => s.active).firstOrNull ?? stations.firstOrNull)
            ?.id;
    final caps = state.capabilities!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(l10n.onboardingStationTitle),
        _body(
          caps.hasContestSessions
              ? l10n.onboardingServerVersion32
              : l10n.onboardingServerVersion31,
        ),
        if (stations.isEmpty)
          _body(l10n.onboardingNoStations)
        else ...[
          _body(l10n.onboardingStationBody),
          RadioGroup<int>(
            groupValue: _station,
            onChanged: (v) => setState(() => _station = v),
            child: Column(
              children: [
                for (final s in stations)
                  RadioListTile<int>(
                    value: s.id,
                    title: Text(s.name),
                    subtitle: Text([s.callsign, ?s.gridsquare].join(' · ')),
                  ),
              ],
            ),
          ),
        ],
        _buttons(
          onBack: () => c.goTo(OnboardingStep.token),
          onContinue: stations.isEmpty
              ? () => c.submitToken(state.token ?? '')
              : () async {
                  final id = await c.finish(_station!);
                  if (id != null) {
                    await ref.read(syncControllerProvider.notifier).syncNow();
                  }
                },
          continueLabel: stations.isEmpty
              ? l10n.actionCheckToken
              : l10n.onboardingFinish,
          busy: state.busy,
        ),
      ],
    );
  }

  Future<void> _showCertificate(String _) async {
    final l10n = AppLocalizations.of(context);
    final cert = ref.read(onboardingProvider).untrustedCertificate!;
    final controller = ref.read(onboardingProvider.notifier);
    final date = DateFormat.yMMMd(l10n.localeName);
    final trusted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.gpp_maybe_outlined),
        title: Text(l10n.certTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.certBody),
              SizedBox(height: context.metrics.md),
              Text(
                l10n.certFingerprint,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SelectableText(
                cert.sha256,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              SizedBox(height: context.metrics.sm),
              Text(l10n.certSubjectLine(cert.subject)),
              Text(l10n.certIssuerLine(cert.issuer)),
              Text(
                l10n.certValidity(
                  date.format(cert.validFrom),
                  date.format(cert.validUntil),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.certCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.certTrust),
          ),
        ],
      ),
    );
    if (trusted ?? false) {
      await controller.trustCertificate();
    } else {
      controller.rejectCertificate();
    }
  }
}

class _ProblemCard extends StatelessWidget {
  const new({required this.problem, required this.state});

  final OnboardingProblem problem;
  final OnboardingState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.colors;
    final text = switch (problem) {
      OnboardingProblem.invalidUrl => l10n.problemInvalidUrl,
      OnboardingProblem.insecurePublicHttp => l10n.problemInsecurePublicHttp,
      OnboardingProblem.httpNeedsOptIn => l10n.problemHttpNeedsOptIn,
      OnboardingProblem.unreachable => l10n.problemUnreachable,
      OnboardingProblem.noApiV2 => l10n.problemNoApiV2,
      OnboardingProblem.tokenInvalid => l10n.problemTokenInvalid,
      OnboardingProblem.tokenExpired => l10n.problemTokenExpired,
      OnboardingProblem.missingScopes => l10n.problemMissingScopes(
        (state.capabilities?.missingRequiredScopes.toList() ?? [])..sort(),
      ),
      OnboardingProblem.serverError => l10n.problemServerError,
      OnboardingProblem.certificateRejected => l10n.problemCertificateRejected,
    };
    return Padding(
      padding: EdgeInsets.only(top: context.metrics.md),
      child: Semantics(
        liveRegion: true,
        child: Container(
          padding: EdgeInsets.all(context.metrics.md),
          decoration: BoxDecoration(
            color: colors.rejected.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: colors.rejected.foreground),
              SizedBox(width: context.metrics.sm),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(color: colors.rejected.foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
