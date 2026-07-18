import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
