/// The kind of work logged for a day. Some types do not count toward a
/// qualifying day (passive/admin/social).
enum WorkType {
  deepWork,
  strategicPlanning,
  learning,
  creativeProjects,
  importantCommunication,
  passiveConsumption,
  routineAdmin,
  socialMedia,
}

extension WorkTypeX on WorkType {
  /// Whether work of this type counts toward a qualifying day.
  bool get isQualifying =>
      this != WorkType.passiveConsumption &&
      this != WorkType.routineAdmin &&
      this != WorkType.socialMedia;
}
