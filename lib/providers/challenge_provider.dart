/// Backward-compatibility shim. The challenge feature moved to
/// `lib/features/challenge/` (IMPROVEMENT_PLAN B1–B3): domain models, a
/// repository + data sources, and a slim controller.
///
/// This file re-exports the public surface so existing screen imports keep
/// working. New code should import from `features/challenge/...` directly;
/// migrate screens off this shim in a follow-up.
library;

export '../features/challenge/presentation/challenge_controller.dart'
    show ChallengeProvider, kLogCutoffHour;
export '../features/challenge/domain/day_log.dart' show DayLog;
export '../features/challenge/domain/sleep_preparation.dart'
    show SleepPreparation;
export '../features/challenge/domain/work_type.dart' show WorkType, WorkTypeX;
export '../features/challenge/domain/log_result.dart' show LogResult;
