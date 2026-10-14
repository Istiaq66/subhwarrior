import 'package:flutter/material.dart';
import 'package:flutter_alarm_call/flutter_alarm_call.dart';

/// Lays the Fajr call screen over [child] while the call is ringing.
///
/// Sits in `MaterialApp.builder` rather than on the navigator, so it covers
/// the splash on a cold launch as well as whatever screen was open, and boot
/// routing underneath carries on untouched. The screen is flutter_alarm_call's,
/// with the mosque in place of its alarm clock.
class FajrCallOverlay extends StatelessWidget {
  const FajrCallOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AlarmCallOverlay(
      screenBuilder: (context, call) =>
          AlarmCallScreen(call: call, icon: Icons.mosque_rounded),
      child: child,
    );
  }
}
