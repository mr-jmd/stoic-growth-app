/// Qualitative progress state of a virtue, expressed as a **material metaphor**
/// (unworked stone → polished stone), never a number, bar or percentage.
///
/// The mapping from habit consistency to this state is a pure function
/// (`VirtueProgressCalculator`, Sprint 7) and is **brightness-agnostic**: it
/// returns only the qualitative state. Whether the slab renders with the light
/// ("mármol pulido") or dark ("basalto pulido") gradient is decided at render
/// time from the active theme — see [StoicTokens.virtueSlab].
///
/// [enReposo] is the post-relapse state: warm resting stone, re-buildable.
/// It is **never** empty, never red, never flat black (DESIGN_BRIEF §3.2 / §6).
enum VirtueProgressState {
  /// Low / just starting — present but unworked.
  sinDesbastar,

  /// Medium — the virtue's gradient at half saturation.
  tomandoColor,

  /// High / consistent — the full polished gradient.
  pulida,

  /// After a relapse — warm resting stone, virtue-independent.
  enReposo,
}
