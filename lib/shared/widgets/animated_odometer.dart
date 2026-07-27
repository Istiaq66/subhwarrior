import 'package:flutter/material.dart';

/// Odometer-style rolling number display: each digit animates
/// independently, and only digits whose value actually changed roll —
/// unchanged digits (and comma separators) render as plain, static
/// `Text` that never touches the animation.
///
/// ## Animation model
///
/// A single [AnimationController] (owned by this widget's `State`) drives
/// every digit that needs to move, in lockstep — not one controller per
/// digit. Each *changed* digit wraps itself in its own small
/// [AnimatedBuilder] listening to that shared controller, so only that
/// digit's subtree rebuilds on each tick; the row itself and any
/// unchanged digits are built once per value change and are otherwise
/// left alone.
///
/// A changing digit is rendered as a 2-layer [Stack] clipped to a fixed
/// height: the old digit slides straight up and out while the new digit
/// slides straight up into place from below — the classic mechanical
/// odometer roll.
///
/// ## Handling a change in digit count (999 -> 1000, 1000 -> 999)
///
/// The shorter of the previous/current formatted strings is left-padded
/// (with a sentinel, not a visible character) to match the longer one.
/// A digit column that's appearing (no previous digit at that position)
/// animates its *width* from 0 up to the digit's natural width at the
/// same time it rolls in from "0"; a column that's disappearing does the
/// reverse. This avoids the whole number visibly jumping sideways when
/// it gains or loses a digit.
class AnimatedOdometer extends StatefulWidget {
  const AnimatedOdometer({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOutCubic,
    required this.textStyle,
    this.digitSpacing = 2,
    this.digitHeight,
    this.useGrouping = false,
    this.digitGlyph,
  });

  /// The number to display. Changing this value (e.g. via `setState` in
  /// the parent) triggers a roll animation from whatever was previously
  /// shown to this new value.
  final int value;

  /// How long each roll takes.
  final Duration duration;

  /// Easing curve applied to every rolling/growing/shrinking digit.
  final Curve curve;

  /// Style applied to every digit and separator. Must specify a
  /// [TextStyle.fontSize] (used to size each digit's roll slot).
  final TextStyle textStyle;

  /// Horizontal gap between adjacent digit/separator columns.
  final double digitSpacing;

  /// Height of each digit's roll slot. Defaults to the text style's own
  /// measured single-line height if not supplied — this is what keeps a
  /// rolling digit vertically aligned with a plain sibling `Text` using
  /// the same style. Only override this if you deliberately want extra
  /// vertical padding around the roll.
  final double? digitHeight;

  /// Group digits with commas every 3 places from the right (e.g.
  /// 1234567 -> "1,234,567").
  final bool useGrouping;

  /// Maps a raw ASCII digit character ('0'-'9') to whatever glyph should
  /// actually be drawn — e.g. Bengali/Arabic-Indic numerals for a
  /// localized display. All internal diffing/padding still operates on
  /// the canonical ASCII digits; this only affects what's rendered.
  /// Defaults to identity (render the ASCII digit as-is).
  final String Function(String rawDigit)? digitGlyph;

  @override
  State<AnimatedOdometer> createState() => _AnimatedOdometerState();
}

/// Sentinel character marking a digit position that doesn't exist yet
/// (or no longer exists) on one side of a transition — distinct from any
/// real digit or the comma separator, so it can never collide with real
/// formatted output.
const String _kNoDigit = ' ';

class _AnimatedOdometerState extends State<AnimatedOdometer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  late String _previousDigits;
  late String _currentDigits;

  /// Cached natural width/height of a digit glyph in [AnimatedOdometer.textStyle].
  /// Computed once (or whenever the style changes) so every column reserves
  /// identical width regardless of which digit it's showing — this is what
  /// keeps the display from jittering as digits change. The measured height
  /// also becomes the default digit-slot height (see [_measureDigitMetrics]).
  double? _digitWidth;
  double? _measuredHeight;
  TextStyle? _measuredForStyle;

  @override
  void initState() {
    super.initState();
    _currentDigits = widget.value.abs().toString();
    _previousDigits = _currentDigits;

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: widget.curve);

    // Once a roll finishes, drop the old value: this is what shrinks a
    // disappearing leading column's reserved width back to zero and out
    // of the layout, rather than leaving a permanent empty gap.
    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _previousDigits = _currentDigits);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedOdometer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.curve != widget.curve) {
      _animation = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    final newDigits = widget.value.abs().toString();
    if (newDigits != _currentDigits) {
      setState(() {
        _previousDigits = _currentDigits;
        _currentDigits = newDigits;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  /// Measures the widest digit glyph's width, plus the natural single-line
  /// height of this text style. Using the *measured* height (rather than
  /// a guessed `fontSize * 1.2`) as the digit slot's default height is
  /// what keeps a rolling digit vertically aligned with a plain sibling
  /// `Text` using the same style (e.g. the "h"/"m"/"s" suffix next to it)
  /// — a box taller or shorter than the glyph's own line box shifts where
  /// `Center` places it relative to that sibling.
  (double width, double height) _measureDigitMetrics(
    TextStyle style,
    String Function(String) glyph,
  ) {
    var widest = 0.0;
    var tallest = 0.0;
    for (var d = 0; d < 10; d++) {
      final painter = TextPainter(
        text: TextSpan(text: glyph('$d'), style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      if (painter.height > tallest) tallest = painter.height;
    }
    return (widest, tallest);
  }

  @override
  Widget build(BuildContext context) {
    final glyph = widget.digitGlyph ?? (String d) => d;
    // A custom glyph mapper is usually a fresh closure every build (it
    // typically closes over a locale-dependent formatter), so its width
    // can't be cached across builds the way the plain-ASCII default can.
    // Re-measuring 10 glyphs is cheap relative to how often this ticks.
    if (_measuredForStyle != widget.textStyle || widget.digitGlyph != null) {
      final (width, height) = _measureDigitMetrics(widget.textStyle, glyph);
      _digitWidth = width;
      _measuredHeight = height;
      _measuredForStyle = widget.textStyle;
    }
    final digitWidth = _digitWidth!;
    final digitHeight = widget.digitHeight ?? _measuredHeight!;

    final maxLen = _previousDigits.length > _currentDigits.length
        ? _previousDigits.length
        : _currentDigits.length;
    final oldPadded = _previousDigits.padLeft(maxLen);
    final newPadded = _currentDigits.padLeft(maxLen);

    final children = <Widget>[];
    for (var i = 0; i < maxLen; i++) {
      final oldChar = oldPadded[i];
      final newChar = newPadded[i];
      final posFromRight = maxLen - 1 - i;

      if (oldChar == newChar) {
        // Identical on both sides (including two sentinels, which can
        // happen for a position neither value has reached yet — not
        // possible in practice since padding always aligns to the
        // longer side, but harmless to guard) — static, no animation.
        children.add(_StaticDigit(
          char: newChar == _kNoDigit ? null : glyph(newChar),
          width: digitWidth,
          height: digitHeight,
          style: widget.textStyle,
        ));
      } else if (oldChar == _kNoDigit) {
        // A new leading column appearing (e.g. 999 -> 1000, this is the
        // "1"): width grows in from 0 while the digit rolls in from "0".
        children.add(_GrowingDigit(
          zeroChar: glyph('0'),
          newChar: glyph(newChar),
          fullWidth: digitWidth,
          height: digitHeight,
          style: widget.textStyle,
          animation: _animation,
        ));
      } else if (newChar == _kNoDigit) {
        // A leading column disappearing (e.g. 1000 -> 999): width shrinks
        // to 0 while the digit rolls out toward "0".
        children.add(_ShrinkingDigit(
          oldChar: glyph(oldChar),
          zeroChar: glyph('0'),
          fullWidth: digitWidth,
          height: digitHeight,
          style: widget.textStyle,
          animation: _animation,
        ));
      } else {
        children.add(_RollingDigit(
          oldChar: glyph(oldChar),
          newChar: glyph(newChar),
          width: digitWidth,
          height: digitHeight,
          style: widget.textStyle,
          animation: _animation,
        ));
      }

      final isLast = i == maxLen - 1;
      if (widget.useGrouping &&
          !isLast &&
          posFromRight != 0 &&
          posFromRight % 3 == 0) {
        children.add(
            _Separator(style: widget.textStyle, spacing: widget.digitSpacing));
      } else if (!isLast) {
        children.add(SizedBox(width: widget.digitSpacing));
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

/// A digit (or empty slot, for a not-yet-existing column) that isn't
/// currently changing. Plain `Text` — never subscribes to the animation.
class _StaticDigit extends StatelessWidget {
  const _StaticDigit({
    required this.char,
    required this.width,
    required this.height,
    required this.style,
  });

  final String? char;
  final double width;
  final double height;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: char == null ? null : Center(child: Text(char!, style: style)),
    );
  }
}

/// Static comma separator between digit groups.
class _Separator extends StatelessWidget {
  const _Separator({required this.style, required this.spacing});

  final TextStyle style;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing / 2),
      child: Text(',', style: style),
    );
  }
}

/// One digit column rolling from [oldChar] to [newChar]: the old digit
/// slides straight up and out, the new digit slides straight up into
/// place from below, clipped to the slot's own height.
class _RollingDigit extends StatelessWidget {
  const _RollingDigit({
    required this.oldChar,
    required this.newChar,
    required this.width,
    required this.height,
    required this.style,
    required this.animation,
  });

  final String oldChar;
  final String newChar;
  final double width;
  final double height;
  final TextStyle style;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                // Old digit: starts centered, slides up and out.
                Transform.translate(
                  offset: Offset(0, -t * height),
                  child: Center(child: Text(oldChar, style: style)),
                ),
                // New digit: starts one slot below, slides up into place.
                Transform.translate(
                  offset: Offset(0, (1 - t) * height),
                  child: Center(child: Text(newChar, style: style)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A digit column appearing for the first time (the number just gained a
/// digit, e.g. 999 -> 1000): width grows from 0 to [fullWidth] while the
/// digit itself rolls in from "0" to [newChar], in lockstep.
class _GrowingDigit extends StatelessWidget {
  const _GrowingDigit({
    required this.zeroChar,
    required this.newChar,
    required this.fullWidth,
    required this.height,
    required this.style,
    required this.animation,
  });

  /// Glyph-mapped "0" — not necessarily the literal ASCII character.
  final String zeroChar;
  final String newChar;
  final double fullWidth;
  final double height;
  final TextStyle style;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return SizedBox(
          width: fullWidth * t,
          height: height,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -t * height),
                  child: Center(child: Text(zeroChar, style: style)),
                ),
                Transform.translate(
                  offset: Offset(0, (1 - t) * height),
                  child: Center(child: Text(newChar, style: style)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A digit column disappearing (the number just lost a digit, e.g.
/// 1000 -> 999): width shrinks from [fullWidth] to 0 while the digit
/// rolls out from [oldChar] toward "0", in lockstep.
class _ShrinkingDigit extends StatelessWidget {
  const _ShrinkingDigit({
    required this.oldChar,
    required this.zeroChar,
    required this.fullWidth,
    required this.height,
    required this.style,
    required this.animation,
  });

  final String oldChar;

  /// Glyph-mapped "0" — not necessarily the literal ASCII character.
  final String zeroChar;
  final double fullWidth;
  final double height;
  final TextStyle style;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return SizedBox(
          width: fullWidth * (1 - t),
          height: height,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.translate(
                  offset: Offset(0, -t * height),
                  child: Center(child: Text(oldChar, style: style)),
                ),
                Transform.translate(
                  offset: Offset(0, (1 - t) * height),
                  child: Center(child: Text(zeroChar, style: style)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
