import 'package:flutter/material.dart';
import 'package:chronamindai/theme.dart';

class SimulatorGraph extends StatelessWidget {
  const SimulatorGraph({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Placeholder for a complex graph visualization
    // In production, use fl_chart or custom painters
    return Container(
      height: 300,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Career Trajectory', style: context.textStyles.titleMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Optimistic',
                  style: context.textStyles.labelSmall?.bold.withColor(
                    theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: Stack(
              children: [
                // Simplified node visualization
                Center(
                  child: CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _GraphPainter(
                      color: theme.colorScheme.primary,
                      secondaryColor: theme.colorScheme.secondary,
                    ),
                  ),
                ),
                // Interactive slider overlay (mock)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      Text('2023', style: context.textStyles.labelSmall),
                      Expanded(
                        child: Slider(
                          value: 0.5,
                          onChanged: (v) {},
                          activeColor: theme.colorScheme.tertiary,
                        ),
                      ),
                      Text('2026', style: context.textStyles.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _GraphPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.2,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(path, paint);

    // Branch
    final branchPath = Path();
    branchPath.moveTo(size.width * 0.5, size.height * 0.48); // Intersection approx
    branchPath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.6,
      size.width,
      size.height * 0.9,
    );
    // canvas.drawPath(branchPath, branchPaint); // Hidden for now for cleaner look

    // Nodes
    final nodePaint = Paint()..color = color;
    canvas.drawCircle(Offset(0, size.height * 0.8), 6, nodePaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.48), 6, nodePaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.4), 6, nodePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
