import 'package:flutter/material.dart';

import '../../../shared/virtue.dart';
import '../../../shared/virtue_progress_state.dart';
import '../../l10n/app_localizations.dart';
import '../design_system.dart';

/// Debug-only reference screen (DESIGN_BRIEF §8.5). Renders every base component
/// and the four virtue colours across all progress states, with a **local**
/// brightness toggle that re-themes only this preview — it does not touch the
/// app's global theme. This is the visual proof that no component assumes a mode.
///
/// Not part of the shipped product surface; reachable only in debug builds
/// (see `app_router.dart`).
class DesignGalleryScreen extends StatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  State<DesignGalleryScreen> createState() => _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends State<DesignGalleryScreen> {
  Brightness _preview = Brightness.light;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.galleryTitle,
                    style: context.stoic.text.displayGreeting.copyWith(fontSize: 24),
                  ),
                ),
                _BrightnessToggle(
                  brightness: _preview,
                  onChanged: (b) => setState(() => _preview = b),
                ),
              ],
            ),
          ),
          Expanded(
            child: Theme(
              // Local override — global app theme is untouched.
              data: _preview == Brightness.light ? stoicLightTheme() : stoicDarkTheme(),
              child: const _GalleryPreview(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrightnessToggle extends StatelessWidget {
  const _BrightnessToggle({required this.brightness, required this.onChanged});

  final Brightness brightness;
  final ValueChanged<Brightness> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableChip(
          label: l.galleryToggleLight,
          selected: brightness == Brightness.light,
          onSelected: (_) => onChanged(Brightness.light),
        ),
        const SizedBox(width: 8),
        SelectableChip(
          label: l.galleryToggleDark,
          selected: brightness == Brightness.dark,
          onSelected: (_) => onChanged(Brightness.dark),
        ),
      ],
    );
  }
}

class _GalleryPreview extends StatefulWidget {
  const _GalleryPreview();

  @override
  State<_GalleryPreview> createState() => _GalleryPreviewState();
}

class _GalleryPreviewState extends State<_GalleryPreview> {
  String _mood = 'chipMoodMedium';
  final Set<String> _evening = {'chipEveningPresent'};
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final c = tokens.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.3,
          colors: [c.appBgInner, c.appBgOuter],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // ── Typography ──────────────────────────────────────────────────
          _Section(title: l.gallerySectionTypography),
          Text(l.galleryEyebrowQuote, style: tokens.text.eyebrow),
          const SizedBox(height: 6),
          Text(l.galleryQuoteDemo, style: tokens.text.quote),
          const SizedBox(height: 4),
          Text(l.galleryQuoteAttribution, style: tokens.text.attribution),
          const SizedBox(height: 14),
          Text(l.galleryPromptDemo, style: tokens.text.promptDisplay),
          const SizedBox(height: 6),
          Text(l.galleryReflectionDemo, style: tokens.text.reflection),

          // ── Virtues ─────────────────────────────────────────────────────
          _Section(title: l.gallerySectionVirtues),
          for (final virtue in Virtue.values) ...[
            _VirtueRow(virtue: virtue),
            const SizedBox(height: 12),
          ],

          // ── Buttons ─────────────────────────────────────────────────────
          _Section(title: l.gallerySectionButtons),
          Row(
            children: [
              AppButton(label: l.buttonPrimaryDemo, onPressed: () {}),
              const SizedBox(width: 12),
              AppButton(
                label: l.buttonSecondaryDemo,
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
            ],
          ),

          // ── Chips ───────────────────────────────────────────────────────
          _Section(title: l.gallerySectionChips),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in {
                'chipMoodLow': l.chipMoodLow,
                'chipMoodMedium': l.chipMoodMedium,
                'chipMoodHigh': l.chipMoodHigh,
              }.entries)
                SelectableChip(
                  label: e.value,
                  selected: _mood == e.key,
                  onSelected: (_) => setState(() => _mood = e.key),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in {
                'chipEveningRest': l.chipEveningRest,
                'chipEveningPresent': l.chipEveningPresent,
                'chipEveningKind': l.chipEveningKind,
              }.entries)
                SelectableChip(
                  label: e.value,
                  selected: _evening.contains(e.key),
                  onSelected: (sel) => setState(() {
                    sel ? _evening.add(e.key) : _evening.remove(e.key);
                  }),
                ),
            ],
          ),

          // ── Cards ───────────────────────────────────────────────────────
          _Section(title: l.gallerySectionCards),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.galleryEyebrowQuote, style: tokens.text.eyebrow),
                const SizedBox(height: 6),
                Text(l.galleryQuoteDemo, style: tokens.text.quote),
                const SizedBox(height: 4),
                Text(l.galleryQuoteAttribution, style: tokens.text.attribution),
              ],
            ),
          ),

          // ── Empty state ─────────────────────────────────────────────────
          _Section(title: l.gallerySectionEmptyState),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 240,
              child: EmptyState(
                title: l.emptyHabitsTitle,
                message: l.emptyHabitsBody,
                actionLabel: l.emptyHabitsAction,
                onAction: () {},
              ),
            ),
          ),

          // ── Nav + crisis ────────────────────────────────────────────────
          _Section(title: l.gallerySectionNav),
          CrisisAccessButton(label: l.crisisAccessLabel, onPressed: () {}),
          const SizedBox(height: 12),
          AppBottomNav(
            currentIndex: _navIndex,
            onSelected: (i) => setState(() => _navIndex = i),
            destinations: [
              AppNavDestination(icon: Icons.wb_twilight_outlined, label: l.navToday),
              AppNavDestination(icon: Icons.menu_book_outlined, label: l.navJournal),
              AppNavDestination(icon: Icons.eco_outlined, label: l.navHabits),
            ],
          ),
        ],
      ),
    );
  }
}

/// A virtue across its progress states, to prove the material metaphor reads in
/// both modes.
class _VirtueRow extends StatelessWidget {
  const _VirtueRow({required this.virtue});

  final Virtue virtue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final state in VirtueProgressState.values) ...[
          Expanded(child: VirtueIndicator(virtue: virtue, state: state)),
          if (state != VirtueProgressState.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title.toUpperCase(), style: context.stoic.text.eyebrow),
    );
  }
}
