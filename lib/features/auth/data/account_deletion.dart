/// Runs the steps of account deletion in the only order that is safe.
///
/// 1. [reauthenticate] — Firebase refuses to delete an account that has not
///    signed in recently. Doing it first means a cancelled Google chooser or a
///    wrong password stops everything before anything is lost.
/// 2. [deleteUserData] — the Firestore documents and local copies. This must
///    come before the account goes: once it is deleted the security rules no
///    longer recognise the caller, so the data could never be removed.
/// 3. [cleanUpDevice] — scheduled reminders and the Fajr alarm.
/// 4. [deleteAuthUser] — the account itself, last.
///
/// Any step that throws stops the run and the error reaches the caller, so a
/// failed server delete never leaves a signed-out user with orphaned data.
/// Every step is safe to repeat, so the user can simply try again.
Future<void> deleteAccount({
  required Future<void> Function() reauthenticate,
  required Future<void> Function() deleteUserData,
  required Future<void> Function() cleanUpDevice,
  required Future<void> Function() deleteAuthUser,
}) async {
  await reauthenticate();
  await deleteUserData();
  await cleanUpDevice();
  await deleteAuthUser();
}
