import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// A destination in the bottom nav (DESIGN_BRIEF §5: Hoy / Diario / Hábitos).
class AppNavDestination {
  const AppNavDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom navigation (DESIGN_BRIEF §5). Presentational — routing is wired in
/// later sprints. Active/inactive colours and the surface tint come from tokens;
/// a top `line` border and a bottom-anchored surface gradient give it weight
/// without a hard bar.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onSelected,
  });

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.navSurface.withValues(alpha: 0), c.navSurface],
        ),
        border: Border(top: BorderSide(color: c.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;
    final color = selected ? c.navActive : c.navInactive;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(destination.icon, size: 22, color: color),
          const SizedBox(height: 4),
          Text(
            destination.label,
            style: tokens.text.navLabel.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
