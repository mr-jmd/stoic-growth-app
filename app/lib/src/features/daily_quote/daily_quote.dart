import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the bundled quotes live (declared in pubspec `assets:`).
const String kQuotesAsset = 'assets/content/quotes.json';

/// A public-domain Stoic quote (Epictetus / Seneca / Marcus Aurelius, README
/// 4.4) paired with a reflection question — both from the same JSON entry.
@immutable
class DailyQuote {
  const DailyQuote({
    required this.text,
    required this.author,
    required this.reflection,
  });

  final String text;
  final String author;
  final String reflection;

  factory DailyQuote.fromJson(Map<String, dynamic> json) => DailyQuote(
        text: json['quote'] as String,
        author: json['author'] as String,
        reflection: json['reflection'] as String,
      );
}

/// Deterministically picks "today's" quote: a date-seeded index so the same
/// quote shows all day and advances by one each calendar day. Pure (no clock,
/// no Drift table) — the date is passed in, which makes it trivially testable.
DailyQuote pickQuoteForDate(List<DailyQuote> quotes, DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  // Dart's `%` returns a non-negative result for a positive divisor.
  final index = day.difference(DateTime(2020, 1, 1)).inDays % quotes.length;
  return quotes[index];
}

/// Today's quote, loaded from the bundled asset (no external fetch). Overridable
/// in tests.
final dailyQuoteProvider = FutureProvider<DailyQuote>((ref) async {
  final raw = await rootBundle.loadString(kQuotesAsset);
  final list = (jsonDecode(raw) as List<dynamic>)
      .map((e) => DailyQuote.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
  return pickQuoteForDate(list, DateTime.now());
});
