import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_spacing.dart';

/// Standard error state with an icon, message, optional detail and retry.
/// When [message] is null, a localized default message is shown.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.message,
    this.detail,
    this.onRetry,
  });

  final String? message;
  final String? detail;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Callers embed this in tight slots — PrayerTimeCard gives it about 112px —
    // where a 60px icon plus message, detail and retry button cannot fit, and
    // a bare Column overflows. Scrolling absorbs the shortfall, and the icon
    // shrinks (then drops out) as the box gets shorter so the message and the
    // retry action stay the priority.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight;
        final isTight = maxH.isFinite && maxH < 200;
        final isVeryTight = maxH.isFinite && maxH < 140;
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTight ? AppSpacing.md : AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isVeryTight) ...[
                  Icon(
                    Icons.error_outline,
                    size: isTight ? 32 : 60,
                    color: scheme.error,
                  ),
                  isTight ? AppSpacing.vGapSm : AppSpacing.vGapMd,
                ],
                Text(
                  message ??
                      AppLocalizations.of(context)!.errorViewDefaultMessage,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                if (detail != null && !isTight) ...[
                  AppSpacing.vGapSm,
                  Text(
                    detail!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (onRetry != null) ...[
                  isTight ? AppSpacing.vGapSm : AppSpacing.vGapMd,
                  FilledButton.tonalIcon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(
                      AppLocalizations.of(context)!.errorViewRetryButton,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
