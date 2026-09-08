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
/// This screen no longer owns a timer or navigates anywhere. It is shown by
/// `main.dart`'s boot gate for exactly as long as Firebase initialization and
/// the anonymous sign-in take, and is replaced the moment they finish — so its
/// lifetime reflects real work instead of a fixed delay. When that work fails
/// (offline first launch, Firebase misconfigured) [bootFailed] swaps the
/// progress bar for a retry action instead of spinning forever.
///
/// The app mark itself is deliberately untouched.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.bootFailed = false, this.onRetry});

  final bool bootFailed;
  final VoidCallback? onRetry;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onGradient = scheme.surfaceContainerLow;
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
                            color: onGradient.withValues(alpha: 0.12),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/icons/app_logo.png',
                            width: 72,
                            height: 72,
                          ),
                        ),
                        AppSpacing.vGapXl,
                        Text(
                          l10n.splashTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: onGradient,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          l10n.splashTagline,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: onGradient.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: Center(
                  child: widget.bootFailed
                      ? _BootFailed(onRetry: widget.onRetry)
                      : SizedBox(
                          // Indeterminate bar, `bottom-16` and capped width in
                          // the comp.
                          width: 320,
                          child: ClipRRect(
                            borderRadius: AppRadius.brFull,
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              backgroundColor:
                                  onGradient.withValues(alpha: 0.20),
                              // Mint reads as progress everywhere else in the
                              // app, so the bar uses it rather than the comp's
                              // ochre.
                              valueColor: AlwaysStoppedAnimation<Color>(
                                scheme.secondary,
                              ),
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

class _BootFailed extends StatelessWidget {
  const _BootFailed({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final onGradient = theme.colorScheme.surfaceContainerLow;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.errorViewDefaultMessage,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(color: onGradient),
        ),
        AppSpacing.vGapMd,
        if (onRetry != null)
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.errorViewRetryButton),
            style: OutlinedButton.styleFrom(
              foregroundColor: onGradient,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: onGradient.withValues(alpha: 0.6)),
            ),
          ),
      ],
    );
  }
}
