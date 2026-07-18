import 'package:flutter/painting.dart';

/// Raw colour literals for the "Piedra y luz" system — luminous warm marble
/// (light) / warm basalt (dark), near-black warm ink, and **one** accent:
/// terracotta. **This is the only file in the app allowed to contain
/// `Color(0x…)` literals** (verification greps enforce this). Every value is a
/// (light, dark) pair; feature/shared code reads resolved roles from
/// `ColorScheme` / `StoicTokens`, never these.
///
/// Hard rules:
/// - Dark is warm stone — never neutral black/grey (`#000`, `#121212`).
/// - The palette is near-monochrome: the four virtues are undertone shifts of
///   stone, not four competing hues. Terracotta is the only true accent.
/// - `error` is a muted oxide reserved for real form errors — never relapse,
///   never crisis.

// Seed for ColorScheme.fromSeed in both modes (corrected by hand afterwards).
const Color seed = Color(0xFFB4552D);

// ── Text ─────────────────────────────────────────────────────────────────────
const Color inkLight = Color(0xFF1B1713);
const Color inkDark = Color(0xFFF1EAE0);
const Color softLight = Color(0xFF5A534B);
const Color softDark = Color(0xFFC6BBAD);
const Color faintLight = Color(0xFF90867A);
const Color faintDark = Color(0xFF8E8478);
const Color labelWarmLight = Color(0xFF7A7063);
const Color labelWarmDark = Color(0xFF9A9084);
const Color attributionLight = Color(0xFF857B6E);
const Color attributionDark = Color(0xFF9C9184);
const Color eyebrowSubLight = Color(0xFFA39A8D);
const Color eyebrowSubDark = Color(0xFF857B6E);
const Color navInactiveLight = Color(0xFFA39A8D);
const Color navInactiveDark = Color(0xFF7E7466);

// ── Surfaces ─────────────────────────────────────────────────────────────────
// `ivory` is the page/scaffold surface; `card` the raised paper; `bone` the
// inset fill (text fields, quiet tiles); `containerHigh` the brightest lift.
const Color ivoryLight = Color(0xFFFAF7F1);
const Color ivoryDark = Color(0xFF1A1512);
const Color cardLight = Color(0xFFFDFBF7);
const Color cardDark = Color(0xFF221C16);
const Color boneLight = Color(0xFFF1EBDF);
const Color boneDark = Color(0xFF1D1813);
const Color containerHighLight = Color(0xFFFFFEFA);
const Color containerHighDark = Color(0xFF2A231C);

// `line` (outline / dividers) is ink/paper at 10% opacity in each mode.
const Color lineLight = Color(0x1A1B1713);
const Color lineDark = Color(0x1AF1EAE0);

// `appBg` wash stops (AppScaffold background — a soft vertical wash of light,
// brighter at the top, never a flat colour).
const Color appBgLightInner = Color(0xFFFAF7F1);
const Color appBgLightOuter = Color(0xFFEFE9DE);
const Color appBgDarkInner = Color(0xFF1A1512);
const Color appBgDarkOuter = Color(0xFF120E0A);

// ── Interactive / state ──────────────────────────────────────────────────────
// Terracotta — the single accent of the system.
const Color accentLight = Color(0xFFB4552D);
const Color accentDark = Color(0xFFDC8257);
const Color accentPressedLight = Color(0xFF96431F);
const Color accentPressedDark = Color(0xFFE89A74);
const Color onAccentLight = Color(0xFFFDF4EC);
const Color onAccentDark = Color(0xFF2A130A);
const Color accentSoftFillLight = Color(0xFFF4E3D8);
const Color accentSoftFillDark = Color(0xFF3A2419);
const Color accentSoftTextLight = Color(0xFF8A3F1D);
const Color accentSoftTextDark = Color(0xFFE9A47F);

// `error` is muted oxide — ONLY for real input errors, never relapse/crisis.
const Color errorLight = Color(0xFF8E3B2F);
const Color errorDark = Color(0xFFD08370);

// Bottom-nav active + surface tints.
const Color navActiveLight = inkLight;
const Color navActiveDark = inkDark;
const Color navSurfaceLight = Color(0xFFF6F1E8);
const Color navSurfaceDark = Color(0xFF1E1813);

// Calm/crisis access band — "charco de calma", never alarm.
const Color crisisSurfaceLight = Color(0xFFF2EDE4);
const Color crisisSurfaceDark = Color(0xFF241E18);
const Color crisisStrokeLight = Color(0xFF7A746C);
const Color crisisStrokeDark = Color(0xFF948C82);

// SelectableChip selected fill/text — warm terracotta-tinted paper.
const Color chipSelectedFillLight = Color(0xFFEFE1D6);
const Color chipSelectedFillDark = Color(0xFF38271C);
const Color chipSelectedTextLight = Color(0xFF7C3D1E);
const Color chipSelectedTextDark = Color(0xFFE8A57E);

// Habit check dot — the accent, full strength.
const Color habitCheckFillLight = accentLight;
const Color habitCheckFillDark = accentDark;
const Color habitCheckGlyphLight = onAccentLight;
const Color habitCheckGlyphDark = onAccentDark;

// ── Virtue "pulida" (polished stone) gradients ───────────────────────────────
// Near-monochrome: each virtue is a subtle undertone of deep stone. [start, end]
// plus a per-virtue contrast-safe onColor.
const List<Color> templanzaHighLight = [Color(0xFF66625D), Color(0xFF4A4640)];
const List<Color> templanzaHighDark = [Color(0xFF6D6963), Color(0xFF504C46)];
const Color templanzaHighOnLight = Color(0xFFF3F0EA);
const Color templanzaHighOnDark = Color(0xFFF0EDE7);

const List<Color> corajeHighLight = [Color(0xFFA05A38), Color(0xFF7E4426)];
const List<Color> corajeHighDark = [Color(0xFFA5663F), Color(0xFF83492B)];
const Color corajeHighOnLight = Color(0xFFF9EFE6);
const Color corajeHighOnDark = Color(0xFFF9EFE7);

const List<Color> sabiduriaHighLight = [Color(0xFF6F6C50), Color(0xFF545138)];
const List<Color> sabiduriaHighDark = [Color(0xFF75725A), Color(0xFF57543E)];
const Color sabiduriaHighOnLight = Color(0xFFF3F2E7);
const Color sabiduriaHighOnDark = Color(0xFFF2F1E5);

const List<Color> justiciaHighLight = [Color(0xFF8B743F), Color(0xFF6C592D)];
const List<Color> justiciaHighDark = [Color(0xFF92794A), Color(0xFF715E33)];
const Color justiciaHighOnLight = Color(0xFFF7F1E2);
const Color justiciaHighOnDark = Color(0xFFF6F0E1);

// ── Virtue "sin desbastar" (pale unhewn marble) ──────────────────────────────
const List<Color> templanzaLowLight = [Color(0xFFEAE8E4), Color(0xFFDDDAD4)];
const Color templanzaLowTextLight = Color(0xFF5F5B55);
const List<Color> templanzaLowDark = [Color(0xFF2B2723), Color(0xFF221F1B)];
const Color templanzaLowTextDark = Color(0xFFA29B92);

const List<Color> corajeLowLight = [Color(0xFFF0E2D8), Color(0xFFE5D0C2)];
const Color corajeLowTextLight = Color(0xFF8A4E30);
const List<Color> corajeLowDark = [Color(0xFF332822), Color(0xFF281F1A)];
const Color corajeLowTextDark = Color(0xFFC08663);

const List<Color> sabiduriaLowLight = [Color(0xFFECEBE0), Color(0xFFDFDDCC)];
const Color sabiduriaLowTextLight = Color(0xFF66634A);
const List<Color> sabiduriaLowDark = [Color(0xFF2C2B22), Color(0xFF23221B)];
const Color sabiduriaLowTextDark = Color(0xFFA5A183);

const List<Color> justiciaLowLight = [Color(0xFFF0EADB), Color(0xFFE4DAC5)];
const Color justiciaLowTextLight = Color(0xFF75613A);
const List<Color> justiciaLowDark = [Color(0xFF312A1D), Color(0xFF262117)];
const Color justiciaLowTextDark = Color(0xFFBC9C61);

// ── "En reposo" (relapse) — warm resting sand, virtue-independent ────────────
const List<Color> reposoLight = [Color(0xFFEADFCF), Color(0xFFDBCCB7)];
const Color reposoTextLight = Color(0xFF7C6850);
const List<Color> reposoDark = [Color(0xFF2C251C), Color(0xFF221C15)];
const Color reposoTextDark = Color(0xFFCBB393);

// ── Shadows / elevation tints ────────────────────────────────────────────────
const Color shadowWarmLight = Color(0xFF40321F);
const Color shadowWarmDark = Color(0xFF0A0703); // warm near-black, never pure
const Color innerHighlightLight = Color(0xFFFFFFFF);
const Color innerHighlightDark = Color(0xFFFFFFFF);
