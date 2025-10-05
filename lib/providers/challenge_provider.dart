import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ChallengeProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Challenge state
  DateTime? _challengeStartDate;
  List<DayLog> _dayLogs = [];
  int _currentStreak = 0;
  int _totalQualifyingDays = 0;
  int _currentWeek = 1;
  bool _isChallengeActive = false;

  // User settings
  String _userName = '';
  String _userLocation = '';
  double _userLatitude = 0.0;
  double _userLongitude = 0.0;

  // Sleep tracking
  final Map<DateTime, SleepPreparation> _sleepPreparations = {};

  ChallengeProvider(this.prefs) {
    _loadData();
  }

  // Getters
  DateTime? get challengeStartDate => _challengeStartDate;
  List<DayLog> get dayLogs => _dayLogs;
  int get currentStreak => _currentStreak;
  int get totalQualifyingDays => _totalQualifyingDays;
  int get currentWeek => _currentWeek;
  bool get isChallengeActive => _isChallengeActive;
  String get userName => _userName;
  String get userLocation => _userLocation;
  double get userLatitude => _userLatitude;
  double get userLongitude => _userLongitude;

  // Calculate progress
  double get overallProgress => _totalQualifyingDays / 16;
  int get daysRemaining => 28 - _getDaysSinceStart();

  Map<int, int> get weeklyProgress {
    Map<int, int> progress = {1: 0, 2: 0, 3: 0, 4: 0};
    for (var log in _dayLogs) {
      if (log.isQualifying) {
        int week = _getWeekNumber(log.date);
        progress[week] = (progress[week] ?? 0) + 1;
      }
    }
    return progress;
  }

  // Start a new challenge
  Future<void> startChallenge() async {
    _challengeStartDate = _getNextSunday();
    _isChallengeActive = true;
    _dayLogs = [];
    _currentStreak = 0;
    _totalQualifyingDays = 0;
    _currentWeek = 1;

    await _saveData();
    notifyListeners();

    // Save to Firestore
    await _saveToFirestore();
  }

  // End the challenge
  Future<void> endChallenge() async {
    _isChallengeActive = false;
    await _saveData();
    notifyListeners();
  }

  // Log a day's completion
  Future<bool> logDay({
    required bool prayedFajrOnTime,
    required bool prayedAtMasjid,
    required int minutesWorked,
    required String workDescription,
    required WorkType workType,
    String? reflection,
  }) async {
    final now = DateTime.now();

    // Check if it's before 8 AM
    if (now.hour >= 8) {
      return false; // Must log before 8 AM
    }

    // Check if it's a weekend (cannot count weekends)
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return false; // Weekends don't qualify
    }

    // Check if already logged today
    final today = DateTime(now.year, now.month, now.day);
    if (_dayLogs.any((log) => _isSameDay(log.date, today))) {
      return false; // Already logged today
    }

    // Validate work type
    final isValidWork = _isQualifyingWork(workType);

    // Create new log
    final isQualifying = prayedFajrOnTime && minutesWorked >= 60 && isValidWork;
    final log = DayLog(
      date: now,
      prayedFajrOnTime: prayedFajrOnTime,
      prayedAtMasjid: prayedAtMasjid,
      minutesWorked: minutesWorked,
      workDescription: workDescription,
      workType: workType,
      reflection: reflection,
      isQualifying: isQualifying,
      loggedAt: now,
    );

    _dayLogs.add(log);

    // Update stats
    if (isQualifying) {
      _totalQualifyingDays++;
      _updateStreak();
    } else {
      _currentStreak = 0;
    }

    _currentWeek = _getWeekNumber(now);

    await _saveData();
    await _saveToFirestore();
    notifyListeners();

    return true;
  }

  // Log sleep preparation for next day
  Future<void> logSleepPreparation({
    required DateTime bedTime,
    required bool noScreens60Min,
    required bool hydratedWell,
    required bool avoidedCaffeine4Hours,
  }) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dateKey = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    _sleepPreparations[dateKey] = SleepPreparation(
      bedTime: bedTime,
      noScreens60Min: noScreens60Min,
      hydratedWell: hydratedWell,
      avoidedCaffeine4Hours: avoidedCaffeine4Hours,
    );

    await _saveData();
    notifyListeners();
  }

  // Check if work type qualifies
  bool _isQualifyingWork(WorkType type) {
    return type != WorkType.passiveConsumption &&
        type != WorkType.routineAdmin &&
        type != WorkType.socialMedia;
  }

  // Update user settings
  Future<void> updateUserSettings({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
  }) async {
    _userName = name;
    _userLocation = location;
    _userLatitude = latitude;
    _userLongitude = longitude;

    await _saveData();
    notifyListeners();
  }

  // Check if user can log today
  bool canLogToday() {
    final now = DateTime.now();
    if (now.hour >= 8) return false;

    final today = DateTime(now.year, now.month, now.day);
    return !_dayLogs.any((log) => _isSameDay(log.date, today));
  }

  // Get today's log if exists
  DayLog? getTodayLog() {
    final today = DateTime.now();
    try {
      return _dayLogs.firstWhere(
            (log) => _isSameDay(log.date, today),
      );
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  void _updateStreak() {
    _currentStreak = 0;
    final sortedLogs = List<DayLog>.from(_dayLogs)
      ..sort((a, b) => b.date.compareTo(a.date));

    DateTime? lastDate;
    for (var log in sortedLogs) {
      if (!log.isQualifying) break;

      if (lastDate == null) {
        _currentStreak = 1;
        lastDate = log.date;
      } else {
        final difference = lastDate.difference(log.date).inDays;
        if (difference == 1) {
          _currentStreak++;
          lastDate = log.date;
        } else {
          break;
        }
      }
    }
  }

  DateTime _getNextSunday() {
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) {
      return now.add(Duration(days: 7 + daysUntilSunday));
    }
    return now.add(Duration(days: daysUntilSunday));
  }

  int _getDaysSinceStart() {
    if (_challengeStartDate == null) return 0;
    return DateTime.now().difference(_challengeStartDate!).inDays;
  }

  int _getWeekNumber(DateTime date) {
    if (_challengeStartDate == null) return 1;
    final daysSinceStart = date.difference(_challengeStartDate!).inDays;
    return (daysSinceStart ~/ 7) + 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Data persistence
  Future<void> _loadData() async {
    final startDateStr = prefs.getString('challengeStartDate');
    if (startDateStr != null) {
      _challengeStartDate = DateTime.parse(startDateStr);
    }

    _isChallengeActive = prefs.getBool('isChallengeActive') ?? false;
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _totalQualifyingDays = prefs.getInt('totalQualifyingDays') ?? 0;
    _currentWeek = prefs.getInt('currentWeek') ?? 1;

    _userName = prefs.getString('userName') ?? '';
    _userLocation = prefs.getString('userLocation') ?? '';
    _userLatitude = prefs.getDouble('userLatitude') ?? 0.0;
    _userLongitude = prefs.getDouble('userLongitude') ?? 0.0;

    final logsJson = prefs.getString('dayLogs');
    if (logsJson != null) {
      final logsList = json.decode(logsJson) as List;
      _dayLogs = logsList.map((e) => DayLog.fromJson(e)).toList();
    }
  }

  Future<void> _saveData() async {
    if (_challengeStartDate != null) {
      await prefs.setString('challengeStartDate', _challengeStartDate!.toIso8601String());
    }

    await prefs.setBool('isChallengeActive', _isChallengeActive);
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('totalQualifyingDays', _totalQualifyingDays);
    await prefs.setInt('currentWeek', _currentWeek);

    await prefs.setString('userName', _userName);
    await prefs.setString('userLocation', _userLocation);
    await prefs.setDouble('userLatitude', _userLatitude);
    await prefs.setDouble('userLongitude', _userLongitude);

    final logsJson = json.encode(_dayLogs.map((e) => e.toJson()).toList());
    await prefs.setString('dayLogs', logsJson);
  }

  Future<void> _saveToFirestore() async {
    if (_userName.isEmpty) return;

    try {
      await _firestore.collection('challenges').doc(_userName).set({
        'userName': _userName,
        'location': _userLocation,
        'startDate': _challengeStartDate?.toIso8601String(),
        'currentStreak': _currentStreak,
        'totalQualifyingDays': _totalQualifyingDays,
        'lastUpdated': FieldValue.serverTimestamp(),
        'logs': _dayLogs.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Error saving to Firestore: $e');
    }
  }
}

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

  DayLog({
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

class SleepPreparation {
  final DateTime bedTime;
  final bool noScreens60Min;
  final bool hydratedWell;
  final bool avoidedCaffeine4Hours;

  SleepPreparation({
    required this.bedTime,
    required this.noScreens60Min,
    required this.hydratedWell,
    required this.avoidedCaffeine4Hours,
  });

  bool get isOptimal =>
      bedTime.hour <= 23 && // Bed by 11 PM
          noScreens60Min &&
          hydratedWell &&
          avoidedCaffeine4Hours;

  Map<String, dynamic> toJson() => {
    'bedTime': bedTime.toIso8601String(),
    'noScreens60Min': noScreens60Min,
    'hydratedWell': hydratedWell,
    'avoidedCaffeine4Hours': avoidedCaffeine4Hours,
  };

  factory SleepPreparation.fromJson(Map<String, dynamic> json) => SleepPreparation(
    bedTime: DateTime.parse(json['bedTime']),
    noScreens60Min: json['noScreens60Min'],
    hydratedWell: json['hydratedWell'],
    avoidedCaffeine4Hours: json['avoidedCaffeine4Hours'],
  );
}