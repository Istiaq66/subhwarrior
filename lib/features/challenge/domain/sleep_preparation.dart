/// An immutable record of pre-sleep preparation for the next day.
class SleepPreparation {
  final DateTime bedTime;
  final bool noScreens60Min;
  final bool hydratedWell;
  final bool avoidedCaffeine4Hours;

  const SleepPreparation({
    required this.bedTime,
    required this.noScreens60Min,
    required this.hydratedWell,
    required this.avoidedCaffeine4Hours,
  });

  /// Whether all sleep-prep targets were met (bed by 11 PM + all habits).
  bool get isOptimal =>
      bedTime.hour <= 23 &&
      noScreens60Min &&
      hydratedWell &&
      avoidedCaffeine4Hours;

  Map<String, dynamic> toJson() => {
        'bedTime': bedTime.toIso8601String(),
        'noScreens60Min': noScreens60Min,
        'hydratedWell': hydratedWell,
        'avoidedCaffeine4Hours': avoidedCaffeine4Hours,
      };

  factory SleepPreparation.fromJson(Map<String, dynamic> json) =>
      SleepPreparation(
        bedTime: DateTime.parse(json['bedTime']),
        noScreens60Min: json['noScreens60Min'],
        hydratedWell: json['hydratedWell'],
        avoidedCaffeine4Hours: json['avoidedCaffeine4Hours'],
      );
}
