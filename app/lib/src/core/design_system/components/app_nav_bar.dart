import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// A destination of the bottom navigation bar.
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final String label;
  final IconData? activeIcon;
}

/// The tab bar of "Piedra y luz": a quiet warm band with three destinations.
/// The active item reads in ink with a small terracotta tick under its label;
/// inactive items are faint warm grey. Every item is a ≥48dp target.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
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
        color: c.navSurface,
        border: Border(top: BorderSide(color: c.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    active: i == currentIndex,
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
    required this.active,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;
    final scheme = Theme.of(context).colorScheme;
    final color = active ? c.navActive : c.navInactive;

    return Semantics(
      button: true,
      selected: active,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? (destination.activeIcon ?? destination.icon)
                     : destination.icon,
              size: 22,
              color: color,
            ),
            SizedBox(height: tokens.spacing.xs),
            Text(
              destination.label,
              style: tokens.text.navLabel.copyWith(color: color),
            ),
            SizedBox(height: tokens.spacing.xs),
            AnimatedContainer(
              duration: tokens.motion.fast,
              width: active ? 14 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
