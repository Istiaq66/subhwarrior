import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/share_card_service.dart';
import 'streak_share_card.dart';

/// Bottom sheet with a live preview of the streak card, a share action and a
/// dismiss, following the Stitch "Share your progress" comp.
///
/// The share button carries a busy state: capturing the preview rasterizes the
/// card at 3x and PNG-encodes it, which takes long enough to feel like a hang
/// if the button gives no feedback.
Future<void> showShareSheet(
  BuildContext context, {
  required int currentStreak,
  required int totalQualifyingDays,
  required int currentWeek,
}) {
  final boundaryKey = GlobalKey();
  // Shape, background and radius come from the shared bottomSheetTheme, so
  // this sheet matches the day-detail sheet and dialogs in both brightnesses.
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      final theme = Theme.of(sheetContext);
      // Lives in the outer builder's closure so it survives the
      // StatefulBuilder rebuilds it drives.
      var busy = false;

      return StatefulBuilder(
        builder: (context, setSheetState) {
          Future<void> share() async {
            if (busy) return;
            setSheetState(() => busy = true);

            final analytics = sheetContext.read<AnalyticsService>();
            final messenger = ScaffoldMessenger.of(sheetContext);
            final errorMessage = l10n.errorViewDefaultMessage;

            var succeeded = false;
            try {
              succeeded = await ShareCardService().shareBoundary(
                boundaryKey,
                text: l10n.shareCardFooter,
              );
            } catch (_) {
              succeeded = false;
            }

            if (succeeded) {
              await analytics.logEvent(
                AnalyticsEvents.shareCardSent,
                {'streak': currentStreak},
              );
            } else {
              messenger.showSnackBar(SnackBar(content: Text(errorMessage)));
            }

            if (sheetContext.mounted) setSheetState(() => busy = false);
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.shareCardSheetTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.primary),
                  ),
                  AppSpacing.vGapLg,
                  RepaintBoundary(
                    key: boundaryKey,
                    child: StreakShareCard(
                      currentStreak: currentStreak,
                      totalQualifyingDays: totalQualifyingDays,
                      currentWeek: currentWeek,
                    ),
                  ),
                  AppSpacing.vGapLg,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.share),
                      label: Text(l10n.shareCardButton),
                      onPressed: busy ? null : share,
                    ),
                  ),
                  AppSpacing.vGapSm,
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: busy
                          ? null
                          : () => Navigator.of(sheetContext).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.onSurfaceVariant,
                      ),
                      child: Text(l10n.settingsCancel),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}