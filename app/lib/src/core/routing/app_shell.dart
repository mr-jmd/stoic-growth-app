import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/tour/tour_controller.dart';
import '../../features/tour/tour_overlay.dart';
import '../../features/tour/tour_targets.dart';
import '../database/repositories/tutorial_repository.dart';
import '../design_system/design_system.dart';
import '../l10n/app_localizations.dart';

/// The tab shell of the app: three branches (Hoy / Hábitos / Diario) over an
/// `IndexedStack`, with the persistent chrome at the bottom — the always-visible
/// [CalmBand] (one tap to `/crisis`, from every tab) above the [AppNavBar].
///
/// Detail/form/journal-entry/crisis routes are pushed on the **root** navigator
/// (see app_router.dart), so they present full-screen over this shell and the
/// tab state underneath is preserved.
///
/// The guided tour renders as a [TourOverlay] layered above the whole shell
/// (chrome included). It auto-starts once when the persisted tour flag is
/// still false — the shell only exists past the onboarding gate, so that is
/// exactly the first post-onboarding landing.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _autoStarted = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tourStep = ref.watch(tourControllerProvider);

    // Auto-start the tour exactly once per session when it was never seen.
    ref.listen(tutorialCompletedProvider, (_, next) {
      if (_autoStarted || next.asData?.value != false) return;
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (ref.read(tourControllerProvider) == null) {
          ref.read(tourControllerProvider.notifier).start();
        }
      });
    });

    final scaffold = Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KeyedSubtree(
            key: tourCalmBandKey,
            child: CalmBand(
              label: l.crisisAccessLabel,
              onTap: () => context.push('/crisis'),
            ),
          ),
          AppNavBar(
            destinations: [
              AppNavDestination(
                icon: Icons.wb_sunny_outlined,
                activeIcon: Icons.wb_sunny,
                label: l.navToday,
              ),
              AppNavDestination(
                icon: Icons.circle_outlined,
                activeIcon: Icons.circle,
                label: l.navHabits,
              ),
              AppNavDestination(
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book,
                label: l.navJournal,
              ),
            ],
            currentIndex: widget.navigationShell.currentIndex,
            onSelected: (index) => widget.navigationShell.goBranch(
              index,
              // Re-tapping the active tab returns to that branch's root.
              initialLocation: index == widget.navigationShell.currentIndex,
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        scaffold,
        if (tourStep != null)
          TourOverlay(navigationShell: widget.navigationShell),
      ],
    );
  }
}
