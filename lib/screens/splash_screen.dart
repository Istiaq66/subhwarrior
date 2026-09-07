import 'dart:async';

import 'package:flutter/material.dart';

import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_spacing.dart';

/// Splash: full-bleed vertical green gradient, the app mark, the wordmark, and
/// an indeterminate loading bar, per the design comp.
///
/// The tagline under the wordmark comes from `splashTagline`, added to all
/// four ARB files and regenerated with `flutter gen-l10n`.
///
/// The app mark itself is deliberately untouched.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _splashDuration = Duration(seconds: 1);
  Timer? _navigationTimer;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<double> _scale = Tween<double>(begin: 0.8, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _navigationTimer = Timer(_splashDuration, () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Vertical, top to bottom, per the comp's `bg-gradient-to-b`. It ends on
    // the brand gradient stop rather than mint so the cream wordmark keeps a
    // comfortable contrast margin at the bottom of the screen.
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, context.appColors.brandGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.surfaceContainerLow
                                .withValues(alpha: 0.12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.mosque,
                            size: 72,
                            color: scheme.surfaceContainerLow,
                          ),
                        ),
                        AppSpacing.vGapXl,
                        Text(
                          AppLocalizations.of(context)!.splashTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: scheme.surfaceContainerLow,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          AppLocalizations.of(context)!.splashTagline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.surfaceContainerLow
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Indeterminate bar, `bottom-16` and capped width in the comp.
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: Center(
                  child: SizedBox(
                    width: 320,
                    child: ClipRRect(
                      borderRadius: AppRadius.brFull,
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        backgroundColor: scheme.surfaceContainerLow
                            .withValues(alpha: 0.20),
                        // Mint reads as progress everywhere else in the app,
                        // so the bar uses it rather than the comp's ochre.
                        valueColor:
                            AlwaysStoppedAnimation<Color>(scheme.secondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
