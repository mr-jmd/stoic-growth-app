import 'dart:convert';
import 'dart:io';

import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/features/daily_quote/daily_quote.dart';
import 'package:app/src/features/home/virtue_progress_calculator.dart';
import 'package:app/src/shared/virtue.dart';
import 'package:app/src/shared/virtue_progress_state.dart';
import 'package:flutter_test/flutter_test.dart';

Habit _habit({
  required Virtue virtue,
  int streak = 0,
  bool archived = false,
}) =>
    Habit(
      id: streak + virtue.index * 100,
      label: 'h',
      virtue: virtue,
      currentStreakCount: streak,
      sortOrder: 0,
      archived: archived,
      createdAt: DateTime(2020),
    );

void main() {
  group('VirtueProgressCalculator', () {
    test('a virtue with no active habit reads as sinDesbastar (never empty)', () {
      final states = VirtueProgressCalculator.fromHabits(const []);
      expect(states.keys.toSet(), Virtue.values.toSet());
      expect(
        states.values.every((s) => s == VirtueProgressState.sinDesbastar),
        isTrue,
      );
    });

    test('streak thresholds map to material states', () {
      final states = VirtueProgressCalculator.fromHabits([
        _habit(virtue: Virtue.templanza, streak: 0),
        _habit(virtue: Virtue.coraje, streak: 3),
        _habit(virtue: Virtue.sabiduria, streak: 7),
      ]);
      expect(states[Virtue.templanza], VirtueProgressState.sinDesbastar);
      expect(states[Virtue.coraje], VirtueProgressState.tomandoColor);
      expect(states[Virtue.sabiduria], VirtueProgressState.pulida);
      expect(states[Virtue.justicia], VirtueProgressState.sinDesbastar);
    });

    test('multiple habits on one virtue take the best (max) streak', () {
      final states = VirtueProgressCalculator.fromHabits([
        _habit(virtue: Virtue.coraje, streak: 2),
        _habit(virtue: Virtue.coraje, streak: 9),
      ]);
      expect(states[Virtue.coraje], VirtueProgressState.pulida);
    });

    test('archived habits do not count toward a virtue', () {
      final states = VirtueProgressCalculator.fromHabits([
        _habit(virtue: Virtue.justicia, streak: 30, archived: true),
      ]);
      expect(states[Virtue.justicia], VirtueProgressState.sinDesbastar);
    });
  });

  group('daily quote', () {
    final quotes = [
      const DailyQuote(text: 'a', author: 'A', reflection: 'ra'),
      const DailyQuote(text: 'b', author: 'B', reflection: 'rb'),
      const DailyQuote(text: 'c', author: 'C', reflection: 'rc'),
    ];

    test('is stable within a day and advances by one each calendar day', () {
      final d1 = DateTime(2026, 7, 16, 8);
      final d1Late = DateTime(2026, 7, 16, 23, 59);
      final d2 = DateTime(2026, 7, 17, 8);

      expect(pickQuoteForDate(quotes, d1).text,
          pickQuoteForDate(quotes, d1Late).text);
      expect(pickQuoteForDate(quotes, d2).text,
          isNot(pickQuoteForDate(quotes, d1).text));
    });

    test('the shipped quotes.json is valid, non-empty, and fully formed', () {
      final raw = File('assets/content/quotes.json').readAsStringSync();
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => DailyQuote.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(list, isNotEmpty);
      for (final q in list) {
        expect(q.text, isNotEmpty);
        expect(q.author, isNotEmpty);
        expect(q.reflection, isNotEmpty);
      }
    });
  });

  group('MVP red-line audit', () {
    test('no ads / push-notification / analytics SDKs in pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      const banned = [
        'google_mobile_ads',
        'firebase_messaging',
        'admob',
        'onesignal',
        'firebase_analytics',
      ];
      for (final dep in banned) {
        expect(pubspec.contains(dep), isFalse,
            reason: '$dep must never be a dependency');
      }
    });

    test('no login/auth route in the router (no required account)', () {
      final router =
          File('lib/src/core/routing/app_router.dart').readAsStringSync().toLowerCase();
      expect(router.contains("'/login'"), isFalse);
      expect(router.contains("'/auth'"), isFalse);
      expect(router.contains("'/signin'"), isFalse);
    });
  });
}
