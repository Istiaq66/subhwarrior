import '../../../core/constants/app_constants.dart';

/// The next instant after [now] at which the daily logging window can open or
/// close by the clock alone: today's [AppConstants.logCutoffHour] cutoff if it
/// is still ahead, otherwise the coming midnight, when a new day can be
/// logged.
///
/// `ChallengeProvider.canLogToday` reads the clock, but nothing rebuilds the
/// UI when the clock crosses one of these instants. Screens that show the
/// window schedule a rebuild for this time.
DateTime nextLogWindowChange(DateTime now) {
  final cutoff =
      DateTime(now.year, now.month, now.day, AppConstants.logCutoffHour);
  if (now.isBefore(cutoff)) return cutoff;
  return DateTime(now.year, now.month, now.day + 1);
}
