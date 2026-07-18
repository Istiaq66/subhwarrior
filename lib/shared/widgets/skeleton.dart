import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A pulsing placeholder block used to build skeleton loading states.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 0.75).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton mimicking the prayer time card layout while times load.
class PrayerCardSkeleton extends StatelessWidget {
  const PrayerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 120, height: 20),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 40)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonBox(height: 40)),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 14),
          ],
        ),
      ),
    );
  }
}
