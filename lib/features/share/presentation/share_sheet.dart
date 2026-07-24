import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/share_card_service.dart';
import 'streak_share_card.dart';

/// Bottom sheet with a live preview of the streak card and a share button.
Future<void> showShareSheet(
  BuildContext context, {
  required int currentStreak,
  required int totalQualifyingDays,
  required int currentWeek,
}) {
  final boundaryKey = GlobalKey();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext)!;
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.shareCardSheetTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              AppSpacing.vGapMd,
              RepaintBoundary(
                key: boundaryKey,
                child: StreakShareCard(
                  currentStreak: currentStreak,
                  totalQualifyingDays: totalQualifyingDays,
                  currentWeek: currentWeek,
                ),
              ),
              AppSpacing.vGapMd,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l10n.shareCardButton),
                  onPressed: () async {
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
                      await analytics.logEvent(AnalyticsEvents.shareCardSent,
                          {'streak': currentStreak});
                    } else {
                      messenger
                          .showSnackBar(SnackBar(content: Text(errorMessage)));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
