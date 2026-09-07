import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../utils/hijri_date.dart';
import 'app_localizations.dart';

/// Locale-aware number formatting for values interpolated directly in Dart
/// (values passed through ARB placeholders are localized by gen-l10n's
/// `decimalPattern` format instead).
extension LocalizedNumberX on BuildContext {
  /// Formats [value] with the current locale's digits (e.g. Bengali ৫,
  /// Arabic-Indic ٥) and separators.
  String localizeNumber(num value, {int fractionDigits = 0}) {
    final format =
        NumberFormat.decimalPattern(Localizations.localeOf(this).toString())
          ..minimumFractionDigits = fractionDigits
          ..maximumFractionDigits = fractionDigits;
    return format.format(value);
  }
}

/// Localized Hijri date formatting for the dashboard date line.
extension LocalizedHijriX on BuildContext {
  /// The Hijri month name for [month] (1 = Muharram) in the active locale.
  String hijriMonthName(int month) {
    final l10n = AppLocalizations.of(this)!;
    switch (month) {
      case 1:
        return l10n.hijriMonth1;
      case 2:
        return l10n.hijriMonth2;
      case 3:
        return l10n.hijriMonth3;
      case 4:
        return l10n.hijriMonth4;
      case 5:
        return l10n.hijriMonth5;
      case 6:
        return l10n.hijriMonth6;
      case 7:
        return l10n.hijriMonth7;
      case 8:
        return l10n.hijriMonth8;
      case 9:
        return l10n.hijriMonth9;
      case 10:
        return l10n.hijriMonth10;
      case 11:
        return l10n.hijriMonth11;
      default:
        return l10n.hijriMonth12;
    }
  }

  /// "27 Rabi' al-Awwal" — day and month only, matching the design's date
  /// line. Digits follow the locale, so Bengali and Arabic read natively.
  String formatHijri(DateTime date) {
    final hijri = HijriDate.fromDateTime(date);
    return '${localizeNumber(hijri.day)} ${hijriMonthName(hijri.month)}';
  }
}
