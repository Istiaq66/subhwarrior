/// Outcome of attempting to log a day, so the UI can show a precise reason
/// instead of a bare `false` (IMPROVEMENT_PLAN A5).
enum LogResult {
  success,
  afterCutoff,
  weekend,
  alreadyLogged,
  invalidInput,
  noActiveChallenge,
}
