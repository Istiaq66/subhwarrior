import 'package:flutter/material.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/features/prayer_times/data/fajr_call_service.dart';

/// Lays the Fajr call screen over [child] while the call is ringing.
///
/// Sits in `MaterialApp.builder` rather than on the navigator, so it covers
/// the splash on a cold launch as well as whatever screen was open, and boot
/// routing underneath carries on untouched.
class FajrCallOverlay extends StatelessWidget {
  const FajrCallOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: FajrCallService.ringing,
      child: child,
      builder: (context, ringing, child) => Stack(
        children: [
          child!,
          if (ringing) const Positioned.fill(child: _FajrCallScreen()),
        ],
      ),
    );
  }
}

class _FajrCallScreen extends StatelessWidget {
  const _FajrCallScreen();

  static const _background = Color(0xFF0F5233);
  static const _accept = Color(0xFF339C6B);
  static const _decline = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: _background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.mosque_rounded, size: 72, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                FajrCallService.callerName,
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.notifFajrBody,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(color: Colors.white70),
              ),
              const Spacer(flex: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallButton(
                    color: _decline,
                    icon: Icons.close_rounded,
                    label: l10n.fajrCallDecline,
                    onPressed: FajrCallService.dismiss,
                  ),
                  _CallButton(
                    color: _accept,
                    icon: Icons.wb_twilight_rounded,
                    label: l10n.fajrCallAccept,
                    onPressed: FajrCallService.answer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.color,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: RawMaterialButton(
            onPressed: onPressed,
            fillColor: color,
            shape: const CircleBorder(),
            constraints: const BoxConstraints.tightFor(width: 72, height: 72),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
