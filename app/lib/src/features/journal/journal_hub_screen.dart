import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/journal_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/journal_enums.dart';
import '../tour/tour_targets.dart';

/// The Diario tab root: today's two moments — morning intention and evening
/// review — as two calm panels. Each shows whether today's entry exists and
/// opens the existing full-screen flow (`/journal/morning`, `/journal/evening`);
/// saving there upserts on (day, type), so reopening always edits.
///
/// Purely additive over the existing repository — no new persistence.
class JournalHubScreen extends ConsumerStatefulWidget {
  const JournalHubScreen({super.key});

  @override
  ConsumerState<JournalHubScreen> createState() => _JournalHubScreenState();
}

class _JournalHubScreenState extends ConsumerState<JournalHubScreen> {
  JournalEntry? _morning;
  JournalEntry? _evening;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(journalRepositoryProvider);
    final now = DateTime.now();
    final morning = await repo.getEntryForDay(now, JournalType.morning);
    final evening = await repo.getEntryForDay(now, JournalType.evening);
    if (!mounted) return;
    setState(() {
      _morning = morning;
      _evening = evening;
    });
  }

  Future<void> _open(String route) async {
    await context.push(route);
    // Back from the entry flow — refresh today's state.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final date = MaterialLocalizations.of(context).formatFullDate(DateTime.now());

    return AppScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.page,
          tokens.spacing.xl,
          tokens.spacing.page,
          tokens.spacing.xl,
        ),
        children: [
          Text(date.toUpperCase(), style: tokens.text.eyebrow),
          SizedBox(height: tokens.spacing.sm),
          Text(l.journalHubTitle, style: tokens.text.displayGreeting),
          SizedBox(height: tokens.spacing.xxl),
          KeyedSubtree(
            key: tourJournalMomentsKey,
            child: Column(
              children: [
                _MomentCard(
                  eyebrow: l.journalHubMorningEyebrow,
                  title: l.homeOpenMorning,
                  invite: l.journalHubMorningInvite,
                  entry: _morning,
                  summary: _morning?.freeText,
                  onOpen: () => _open('/journal/morning'),
                ),
                SizedBox(height: tokens.spacing.gap),
                _MomentCard(
                  eyebrow: l.journalHubEveningEyebrow,
                  title: l.homeOpenEvening,
                  invite: l.journalHubEveningInvite,
                  entry: _evening,
                  summary: _evening?.freeText,
                  onOpen: () => _open('/journal/evening'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({
    required this.eyebrow,
    required this.title,
    required this.invite,
    required this.entry,
    required this.summary,
    required this.onOpen,
  });

  final String eyebrow;
  final String title;
  final String invite;
  final JournalEntry? entry;

  /// The saved phrase/note to echo back, when present.
  final String? summary;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final done = entry != null;

    return AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(eyebrow.toUpperCase(), style: tokens.text.eyebrow)),
              if (done)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: tokens.spacing.md,
                    vertical: tokens.spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: tokens.colors.accentSoft,
                    borderRadius: BorderRadius.circular(tokens.radii.full),
                  ),
                  child: Text(
                    l.journalHubDone,
                    style: tokens.text.caption
                        .copyWith(color: tokens.colors.onAccentSoft),
                  ),
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.md),
          Text(title, style: tokens.text.title),
          SizedBox(height: tokens.spacing.sm),
          Text(
            done && summary != null && summary!.isNotEmpty ? '«${summary!}»' : invite,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: done && summary != null && summary!.isNotEmpty
                ? tokens.text.reflection
                : tokens.text.body.copyWith(color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: tokens.spacing.gap),
          Text(
            done ? l.journalHubEdit : l.journalHubOpen,
            style: tokens.text.bodyStrong.copyWith(
              fontSize: 13.5,
              color: tokens.colors.onAccentSoft,
            ),
          ),
        ],
      ),
    );
  }
}
