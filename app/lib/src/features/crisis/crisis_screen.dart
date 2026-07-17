import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'breathing_timer.dart';
import 'crisis_content.dart';
import 'crisis_flow.dart';

/// Crisis mode (README 10.2): 100% static, no AI, works fully offline. Immediate
/// relief (breathing + a calm affirmation) **always precedes** any socratic
/// question — the ordering is enforced structurally (the prompt widget is not in
/// the tree until relief completes), not just visually. The "estoy bien ahora"
/// exit is visible in every state, including while content loads or if it fails.
class CrisisScreen extends ConsumerWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(crisisContentProvider);
    return content.when(
      data: (c) => _CrisisScaffold(child: _CrisisFlowView(content: c)),
      // Degrade safely: never a blank/blocked screen in a crisis. A calm
      // fallback line + the exit are always available.
      loading: () => const _CrisisScaffold(child: _Fallback()),
      error: (_, _) => const _CrisisScaffold(child: _Fallback()),
    );
  }
}

/// Spacious, calm frame with the always-present exit pinned at the top-end.
class _CrisisScaffold extends StatelessWidget {
  const _CrisisScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  l.crisisExit,
                  style: tokens.text.chip
                      .copyWith(color: tokens.colors.crisisStroke),
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    return Center(
      child: Text(
        l.crisisFallbackLine,
        textAlign: TextAlign.center,
        style: tokens.text.quote,
      ),
    );
  }
}

class _CrisisFlowView extends ConsumerStatefulWidget {
  const _CrisisFlowView({required this.content});

  final CrisisContent content;

  @override
  ConsumerState<_CrisisFlowView> createState() => _CrisisFlowViewState();
}

class _CrisisFlowViewState extends ConsumerState<_CrisisFlowView> {
  int _promptIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final content = widget.content;
    final state = ref.watch(crisisFlowProvider);

    return Column(
      children: [
        SizedBox(height: tokens.spacing.lg),
        // The calm reframing statement — an affirmation, never a question.
        Text(
          content.affirmation,
          textAlign: TextAlign.center,
          style: tokens.text.quote,
        ),
        const Spacer(),
        // Relief first: while breathing runs, no question exists in the tree.
        if (!state.reliefIsComplete)
          BreathingTimer(
            script: content.breathing,
            onComplete: () =>
                ref.read(crisisFlowProvider.notifier).completeRelief(),
          )
        // Only after relief completes may a socratic prompt appear — a
        // dismissible invitation the user can ignore by simply leaving.
        else
          _SocraticInvitation(
            intro: l.crisisSocraticIntro,
            prompt: content.socraticPrompts[
                _promptIndex % content.socraticPrompts.length],
            anotherLabel: l.crisisAnotherQuestion,
            onAnother: content.socraticPrompts.length > 1
                ? () {
                    setState(() => _promptIndex++);
                    ref.read(crisisFlowProvider.notifier).offerSocratic();
                  }
                : null,
          ),
        const Spacer(),
      ],
    );
  }
}

class _SocraticInvitation extends StatelessWidget {
  const _SocraticInvitation({
    required this.intro,
    required this.prompt,
    required this.anotherLabel,
    required this.onAnother,
  });

  final String intro;
  final String prompt;
  final String anotherLabel;
  final VoidCallback? onAnother;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(intro, style: tokens.text.eyebrow),
        SizedBox(height: tokens.spacing.lg),
        Text(
          prompt,
          textAlign: TextAlign.center,
          style: tokens.text.reflection,
        ),
        if (onAnother != null) ...[
          SizedBox(height: tokens.spacing.xxl),
          AppButton(
            label: anotherLabel,
            variant: AppButtonVariant.secondary,
            onPressed: onAnother,
          ),
        ],
      ],
    );
  }
}
