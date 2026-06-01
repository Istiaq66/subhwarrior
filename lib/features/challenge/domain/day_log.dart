import 'work_type.dart';

/// An immutable record of a single logged day in the challenge.
class DayLog {
  final DateTime date;
  final bool prayedFajrOnTime;
  final bool prayedAtMasjid;
  final int minutesWorked;
  final String workDescription;
  final WorkType workType;
  final String? reflection;
  final bool isQualifying;
  final DateTime loggedAt;

  const DayLog({
    required this.date,
    required this.prayedFajrOnTime,
    this.prayedAtMasjid = true,
    required this.minutesWorked,
    required this.workDescription,
    required this.workType,
    this.reflection,
    required this.isQualifying,
    required this.loggedAt,
  });

  DayLog copyWith({
    DateTime? date,
    bool? prayedFajrOnTime,
    bool? prayedAtMasjid,
    int? minutesWorked,
    String? workDescription,
    WorkType? workType,
    String? reflection,
    bool? isQualifying,
    DateTime? loggedAt,
  }) {
    return DayLog(
      date: date ?? this.date,
      prayedFajrOnTime: prayedFajrOnTime ?? this.prayedFajrOnTime,
      prayedAtMasjid: prayedAtMasjid ?? this.prayedAtMasjid,
      minutesWorked: minutesWorked ?? this.minutesWorked,
      workDescription: workDescription ?? this.workDescription,
      workType: workType ?? this.workType,
      reflection: reflection ?? this.reflection,
      isQualifying: isQualifying ?? this.isQualifying,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'prayedFajrOnTime': prayedFajrOnTime,
        'prayedAtMasjid': prayedAtMasjid,
        'minutesWorked': minutesWorked,
        'workDescription': workDescription,
        'workType': workType.index,
        'reflection': reflection,
        'isQualifying': isQualifying,
        'loggedAt': loggedAt.toIso8601String(),
      };

  factory DayLog.fromJson(Map<String, dynamic> json) => DayLog(
        date: DateTime.parse(json['date']),
        prayedFajrOnTime: json['prayedFajrOnTime'],
        prayedAtMasjid: json['prayedAtMasjid'] ?? false,
        minutesWorked: json['minutesWorked'],
        workDescription: json['workDescription'],
        workType: WorkType.values[json['workType'] ?? 0],
        reflection: json['reflection'],
        isQualifying: json['isQualifying'],
        loggedAt: DateTime.parse(json['loggedAt']),
      );
}
