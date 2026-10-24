import 'package:flutter/material.dart';

/// A rocket that climbs along a track as questions get answered.
class RocketProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const RocketProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const rocketSize = 32.0;
    const barHeight = 8.0;
    const duration = Duration(milliseconds: 400);

    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - rocketSize) *
            progress.clamp(0.0, 1.0).toDouble();

        return SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: barHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                height: barHeight,
                width: left + rocketSize / 2,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(barHeight / 2),
                ),
              ),
              AnimatedPositioned(
                duration: duration,
                curve: Curves.easeOut,
                left: left,
                child: Icon(
                  Icons.rocket_launch,
                  size: 28,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}