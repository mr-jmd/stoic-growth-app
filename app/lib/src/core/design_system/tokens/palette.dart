import 'package:flutter/painting.dart';

/// Raw colour literals for the "mármol pulido" (light) / "basalto pulido" (dark)
/// system. **This is the only file in the app allowed to contain `Color(0x…)`
/// literals** (DESIGN_BRIEF §7 verification greps enforce this). Every value
/// here is a (light, dark) pair from DESIGN_BRIEF §2–§3; feature/shared code
/// reads resolved roles from `ColorScheme` / `StoicTokens`, never these.
///
/// Hard rule: dark is warm dark stone — never neutral black/grey
/// (`#000`, `#121212`). The earth undertone is preserved on every surface.

// Seed for ColorScheme.fromSeed in both modes (corrected by hand afterwards).
const Color seed = Color(0xFFD7CEBB);

// ── §2.1 Text ────────────────────────────────────────────────────────────────
const Color inkLight = Color(0xFF2C2822);
const Color inkDark = Color(0xFFEDE6D8);
const Color softLight = Color(0xFF6B6355);
const Color softDark = Color(0xFFB7AD9C);
const Color faintLight = Color(0xFF9A8F7C);
const Color faintDark = Color(0xFF968C79);
const Color labelWarmLight = Color(0xFF8A7F6C);
const Color labelWarmDark = Color(0xFF9A8F7C);
const Color attributionLight = Color(0xFF8A7F6C);
const Color attributionDark = Color(0xFF9C927E);
const Color eyebrowSubLight = Color(0xFFA99D88);
const Color eyebrowSubDark = Color(0xFF928873);
const Color navInactiveLight = Color(0xFFA99D88);
const Color navInactiveDark = Color(0xFF7C7360);

// ── §2.2 Surfaces ────────────────────────────────────────────────────────────
const Color ivoryLight = Color(0xFFF3EDE1);
const Color ivoryDark = Color(0xFF1E1A16);
const Color cardLight = Color(0xFFFAF6EE);
const Color cardDark = Color(0xFF26221D);
const Color boneLight = Color(0xFFEAE1D1);
const Color boneDark = Color(0xFF2E2822);
const Color containerHighLight = cardLight; // light uses `card`
const Color containerHighDark = Color(0xFF322C25);

// `line` (outline / dividers) is ink/paper at 8% opacity in each mode.
const Color lineLight = Color(0x142C2822); // #2C2822 @ ~8%
const Color lineDark = Color(0x14EDE6D8); // #EDE6D8 @ ~8%

// `appBg` radial gradient stops (AppScaffold background — never a flat colour).
const Color appBgLightInner = Color(0xFFDED5C3);
const Color appBgLightOuter = Color(0xFFD0C7B3);
const Color appBgDarkInner = Color(0xFF1F1B17);
const Color appBgDarkOuter = Color(0xFF17140F);

// ── §2.3 Interactive / state ─────────────────────────────────────────────────
const Color slateLight = Color(0xFF5B6B78);
const Color slateDark = Color(0xFF8FA2B0);
const Color slatePressedLight = Color(0xFF3F4A54);
const Color slatePressedDark = Color(0xFFA9BBC7);
// `error` is muted clay — ONLY for real input errors, never relapse/crisis.
const Color errorLight = Color(0xFF9C5A44);
const Color errorDark = Color(0xFFC77E63);

// Bottom-nav active + surface tints (§5).
const Color navActiveLight = slatePressedLight;
const Color navActiveDark = slatePressedDark;
const Color navSurfaceLight = Color(0xFFEFE8DB);
const Color navSurfaceDark = Color(0xFF201C18);

// Crisis access slab (§5) — "charco de calma", never alarm.
const Color crisisSurfaceLight = Color(0xFFEFE8DB);
const Color crisisSurfaceDark = Color(0xFF242A2E);
const Color crisisStrokeLight = Color(0xFF7F8B96);
const Color crisisStrokeDark = Color(0xFF8FA2B0);

// SelectableChip selected fill/text (§5).
const Color chipSelectedFillLight = Color(0xFFEEF1F0);
const Color chipSelectedFillDark = Color(0xFF28322E);
const Color chipSelectedTextLight = Color(0xFF4F5F57);
const Color chipSelectedTextDark = Color(0xFFAEC3B8);

// Habit row check (§5).
const Color habitCheckFillLight = Color(0xFF7B7D52);
const Color habitCheckFillDark = Color(0xFF8D8F5F);
const Color habitCheckGlyphLight = Color(0xFFFFFEF8); // ivory glyph
const Color habitCheckGlyphDark = inkDark;

// ── §3.1 Virtue "pulida" (full/active) gradients, 158° ───────────────────────
// [start, end, onColor]
const List<Color> templanzaHighLight = [Color(0xFF7F8B96), Color(0xFF5F6D79)];
const List<Color> templanzaHighDark = [Color(0xFF78848F), Color(0xFF586572)];
const List<Color> corajeHighLight = [Color(0xFFB07A5F), Color(0xFF8A5540)];
const List<Color> corajeHighDark = [Color(0xFFA67256), Color(0xFF854F3B)];
const List<Color> sabiduriaHighLight = [Color(0xFFA0A27C), Color(0xFF83855C)];
const List<Color> sabiduriaHighDark = [Color(0xFF9A9C77), Color(0xFF7E8058)];
const List<Color> justiciaHighLight = [Color(0xFFB89A5E), Color(0xFF9A824F)];
const List<Color> justiciaHighDark = [Color(0xFFB4965A), Color(0xFF96804C)];

const Color onSlabWarm = Color(0xFFF2EFE8); // Templanza/Coraje/Justicia
const Color onSlabOlive = Color(0xFFF4F1E6); // Sabiduría

// ── §3.2 "sin desbastar" (low) ───────────────────────────────────────────────
// Dark values are given explicitly in the brief. Light values: the brief gives
// Justicia explicitly and says each other virtue uses its own analogous pale
// tint — encoded here (design-system-internal, the correct home for such hex).
const List<Color> templanzaLowLight = [Color(0xFFE4E7EA), Color(0xFFD3D9DE)];
const Color templanzaLowTextLight = Color(0xFF5F6D79);
const List<Color> templanzaLowDark = [Color(0xFF33383D), Color(0xFF2A2E33)];
const Color templanzaLowTextDark = Color(0xFF8A97A2);

const List<Color> corajeLowLight = [Color(0xFFECDDD3), Color(0xFFE0CBBB)];
const Color corajeLowTextLight = Color(0xFF8A5540);
const List<Color> corajeLowDark = [Color(0xFF3A322D), Color(0xFF2F2823)];
const Color corajeLowTextDark = Color(0xFFA9765F);

const List<Color> sabiduriaLowLight = [Color(0xFFE9E9D8), Color(0xFFDBDBC2)];
const Color sabiduriaLowTextLight = Color(0xFF83855C);
const List<Color> sabiduriaLowDark = [Color(0xFF34362C), Color(0xFF2B2C24)];
const Color sabiduriaLowTextDark = Color(0xFF9D9E7B);

const List<Color> justiciaLowLight = [Color(0xFFEDE4D2), Color(0xFFE2D5BE)];
const Color justiciaLowTextLight = Color(0xFF9A824F);
const List<Color> justiciaLowDark = [Color(0xFF38311F), Color(0xFF2E281A)];
const Color justiciaLowTextDark = Color(0xFFB89A5E);

// ── §3.2 "en reposo" (relapse) — virtue-independent ──────────────────────────
const List<Color> reposoLight = [Color(0xFFECDCCD), Color(0xFFDDC7B6)];
const Color reposoTextLight = Color(0xFF8A6A56);
const List<Color> reposoDark = [Color(0xFF332B24), Color(0xFF28211B)];
const Color reposoTextDark = Color(0xFFC0A488);

// ── Shadows / elevation tints (§2 "Sombras") ─────────────────────────────────
const Color shadowWarmLight = Color(0xFF3C301E); // rgba(60,48,30,·)
const Color shadowWarmDark = Color(0xFF080603); // warm near-black, never pure
const Color innerHighlightLight = Color(0xFFFFFFFF);
const Color innerHighlightDark = Color(0xFFFFFFFF);
