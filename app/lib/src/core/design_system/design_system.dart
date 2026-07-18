/// Barrel for the Stoic design system. Feature code imports this one file and
/// reads everything through `Theme.of(context)` / `context.stoic` — never the
/// raw palette, never a `Color(0x…)` literal, never `Colors.black/white`, never
/// `Brightness` checks (DESIGN_BRIEF §6 / §7).
///
/// ## "No gamification" checklist (DESIGN_BRIEF §6 — for every future sprint)
///
/// Before shipping any screen, confirm it has **none** of:
/// - streak/fire emoji, confetti, badges/medals, achievement sounds,
///   "game"-style progress bars;
/// - relapse framed as failure — relapse is `VirtueProgressState.enReposo`
///   (warm resting stone), **never** empty, **never** red, **never** flat black,
///   **never** "rompiste tu racha";
/// - the `error` colour used for anything but real form errors (never
///   relapse/crisis framing);
/// - red or an alarming countdown in crisis; crisis is more spacious/calm than
///   the rest, and in dark reads as a "charco de calma", never disabled-looking;
/// - exclamation marks or clinical/pathologising language in copy;
/// - virtue progress shown as a score/percentage — always material state;
/// - neutral black/grey in dark mode — it is warm dark stone throughout.
library;

export 'components/app_button.dart';
export 'components/app_card.dart';
export 'components/app_nav_bar.dart';
export 'components/app_scaffold.dart';
export 'components/calm_band.dart';
export 'components/editorial_hero.dart';
export 'components/empty_state.dart';
export 'components/section_header.dart';
export 'components/selectable_chip.dart';
export 'components/stepper_control.dart';
export 'components/virtue_indicator.dart';
export 'theme/stoic_theme.dart';
export 'tokens/stoic_tokens.dart';
