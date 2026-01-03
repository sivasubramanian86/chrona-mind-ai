import 'package:flutter/material.dart';
import 'package:chronamindai/models/simulation.dart' as model;
import 'package:chronamindai/services/simulation_service.dart';
import 'package:chronamindai/theme.dart';

class SimulatorDetailScreen extends StatefulWidget {
  final String simulationId;

  const SimulatorDetailScreen({
    super.key,
    required this.simulationId,
  });

  @override
  State<SimulatorDetailScreen> createState() => _SimulatorDetailScreenState();
}

class _SimulatorDetailScreenState extends State<SimulatorDetailScreen> {
  model.Simulation? _simulation;

  @override
  void initState() {
    super.initState();
    _loadSimulation();
  }

  Future<void> _loadSimulation() async {
    final simulation = await SimulationService.getSimulationById(widget.simulationId);
    if (mounted) {
      setState(() => _simulation = simulation);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_simulation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulation'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_tree,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _simulation!.title,
                          style: context.textStyles.titleLarge?.bold.withColor(
                            Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ),
                        if (_simulation!.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            _simulation!.description,
                            style: context.textStyles.bodyMedium?.withColor(
                              Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Decision Tree',
              style: context.textStyles.headlineSmall?.bold,
            ),
            const SizedBox(height: 16),
            _buildBranchingGraph(),
            const SizedBox(height: 32),
            Text(
              'Outcome Comparison',
              style: context.textStyles.headlineSmall?.bold,
            ),
            const SizedBox(height: 16),
            _buildComparisonTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchingGraph() {
    final root = _simulation!.rootChoice;
    
    return Column(
      children: [
        _buildNodeCard(root, isRoot: true),
        if (root.childChoices.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildBranchColumn(root.childChoices[0], isLeft: true),
              ),
              if (root.childChoices.length > 1) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBranchColumn(root.childChoices[1], isLeft: false),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBranchColumn(model.SimulationNode node, {required bool isLeft}) {
    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 40),
          painter: BranchLinePainter(
            color: Theme.of(context).colorScheme.outline,
            isLeft: isLeft,
          ),
        ),
        _buildNodeCard(node),
      ],
    );
  }

  Widget _buildNodeCard(model.SimulationNode node, {bool isRoot = false}) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: isRoot
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.label,
            style: context.textStyles.titleMedium?.bold,
          ),
          if (node.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              node.description,
              style: context.textStyles.bodySmall,
            ),
          ],
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: node.confidence,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 4),
          Text(
            'Confidence: ${(node.confidence * 100).toInt()}%',
            style: context.textStyles.bodySmall?.withColor(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final root = _simulation!.rootChoice;
    if (root.childChoices.isEmpty) return const SizedBox();

    return Column(
      children: root.childChoices.map((choice) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      choice.label,
                      style: context.textStyles.titleMedium?.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(choice.confidence * 100).toInt()}%',
                      style: context.textStyles.labelSmall?.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...choice.outcomes.map((outcome) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outcome.startsWith('✓') ? '✓' : '⚠',
                      style: TextStyle(
                        color: outcome.startsWith('✓')
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        outcome.replaceFirst(RegExp(r'^[✓⚠]\s*'), ''),
                        style: context.textStyles.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class BranchLinePainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  BranchLinePainter({required this.color, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width / 2, size.height / 2);
      path.lineTo(size.width / 2, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height / 2);
      path.lineTo(size.width / 2, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
