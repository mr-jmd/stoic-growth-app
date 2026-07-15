import '../core/l10n/app_localizations.dart';
import 'virtue.dart';
import 'virtue_progress_state.dart';

/// Localized display labels for [Virtue] and [VirtueProgressState]. Labels live
/// in `app_es.arb`, never hardcoded next to the enums (DESIGN_BRIEF §7).
extension VirtueL10n on Virtue {
  String label(AppLocalizations l) => switch (this) {
        Virtue.templanza => l.virtueTemplanza,
        Virtue.coraje => l.virtueCoraje,
        Virtue.sabiduria => l.virtueSabiduria,
        Virtue.justicia => l.virtueJusticia,
      };
}

extension VirtueProgressStateL10n on VirtueProgressState {
  String label(AppLocalizations l) => switch (this) {
        VirtueProgressState.sinDesbastar => l.virtueStateSinDesbastar,
        VirtueProgressState.tomandoColor => l.virtueStateTomandoColor,
        VirtueProgressState.pulida => l.virtueStatePulida,
        VirtueProgressState.enReposo => l.virtueStateEnReposo,
      };
}
