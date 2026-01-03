import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chronamindai/models/simulation.dart' as model;
import 'package:chronamindai/services/simulation_service.dart';
import 'package:chronamindai/services/user_service.dart';
import 'package:chronamindai/theme.dart';
import 'package:intl/intl.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  List<model.Simulation> _simulations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSimulations();
  }

  Future<void> _loadSimulations() async {
    setState(() => _isLoading = true);
    try {
      final simulations = await SimulationService.getAllSimulations();
      if (mounted) {
        setState(() {
          _simulations = simulations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateSimulationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final optionAController = TextEditingController();
    final optionBController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Future Simulation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Decision Title',
                  hintText: 'e.g., Should I change careers?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: optionAController,
                decoration: const InputDecoration(
                  labelText: 'Option A',
                  hintText: 'e.g., Stay at current job',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: optionBController,
                decoration: const InputDecoration(
                  labelText: 'Option B',
                  hintText: 'e.g., Join startup',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || 
                  optionAController.text.isEmpty || 
                  optionBController.text.isEmpty) {
                return;
              }
              Navigator.pop(context);
              _createSimulation(
                titleController.text,
                descriptionController.text,
                optionAController.text,
                optionBController.text,
              );
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSimulation(
    String title,
    String description,
    String optionA,
    String optionB,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Simulating futures...'),
              ],
            ),
          ),
        ),
      ),
    );

    final user = await UserService.getCurrentUser();
    if (user == null) return;

    final simulation = await SimulationService.createSimulation(
      userId: user.id,
      title: title,
      description: description,
      optionA: optionA,
      optionB: optionB,
    );

    await SimulationService.saveSimulation(simulation);

    if (mounted) {
      // Dismiss the loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Navigate to the new simulation detail
      context.push('/simulator/${simulation.id}');
      _loadSimulations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Future Simulator'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _simulations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSimulations,
                  child: ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: _simulations.length,
                    itemBuilder: (context, index) => _buildSimulationCard(_simulations[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateSimulationDialog,
        icon: const Icon(Icons.account_tree),
        label: const Text('New Simulation'),
      ),
    );
  }

  Widget _buildSimulationCard(model.Simulation simulation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/simulator/${simulation.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_tree,
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          simulation.title,
                          style: context.textStyles.titleMedium?.bold,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(simulation.createdAt),
                          style: context.textStyles.bodySmall?.withColor(
                            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (simulation.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  simulation.description,
                  style: context.textStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.call_split,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${simulation.rootChoice.childChoices.length} branches',
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 80,
              color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No simulations yet',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first future simulation to visualize potential outcomes',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
