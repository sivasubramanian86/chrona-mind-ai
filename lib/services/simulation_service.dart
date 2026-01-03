import 'package:chronamindai/models/simulation.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class SimulationService {
  static List<Simulation>? _cache;

  static Future<List<Simulation>> getAllSimulations() async {
    if (_cache != null) return _cache!;
    
    try {
      final data = StorageService.getSimulations();
      _cache = data.map((json) => Simulation.fromJson(json)).toList();
      _cache!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _cache!;
    } catch (e) {
      debugPrint('Failed to get simulations: $e');
      return [];
    }
  }

  static Future<Simulation?> getSimulationById(String id) async {
    try {
      final simulations = await getAllSimulations();
      return simulations.firstWhere((s) => s.id == id);
    } catch (e) {
      debugPrint('Failed to get simulation by id: $e');
      return null;
    }
  }

  static Future<bool> saveSimulation(Simulation simulation) async {
    try {
      final simulations = await getAllSimulations();
      final index = simulations.indexWhere((s) => s.id == simulation.id);
      
      if (index >= 0) {
        simulations[index] = simulation;
      } else {
        simulations.insert(0, simulation);
      }
      
      final success = await StorageService.saveSimulations(
        simulations.map((s) => s.toJson()).toList(),
      );
      
      if (success) {
        _cache = simulations;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save simulation: $e');
      return false;
    }
  }

  static Future<bool> deleteSimulation(String id) async {
    try {
      final simulations = await getAllSimulations();
      simulations.removeWhere((s) => s.id == id);
      
      final success = await StorageService.saveSimulations(
        simulations.map((s) => s.toJson()).toList(),
      );
      
      if (success) {
        _cache = simulations;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to delete simulation: $e');
      return false;
    }
  }

  static Future<Simulation> createSimulation({
    required String userId,
    required String title,
    required String description,
    required String optionA,
    required String optionB,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final choiceA = SimulationNode.create(
      label: optionA,
      description: 'Path A: $optionA',
      outcomes: _generateOutcomes(optionA, isPositive: true),
      confidence: 0.65,
    );
    
    final choiceB = SimulationNode.create(
      label: optionB,
      description: 'Path B: $optionB',
      outcomes: _generateOutcomes(optionB, isPositive: false),
      confidence: 0.55,
    );
    
    final root = SimulationNode.create(
      label: title,
      description: description,
      childChoices: [choiceA, choiceB],
      confidence: 1.0,
    );
    
    return Simulation.create(
      userId: userId,
      title: title,
      description: description,
      rootChoice: root,
    );
  }

  static List<String> _generateOutcomes(String choice, {required bool isPositive}) {
    if (isPositive) {
      return [
        '✓ Higher potential for growth and learning',
        '✓ Increased long-term satisfaction',
        '✓ Better alignment with core values',
        '⚠ Requires adaptation period (3-6 months)',
        '⚠ Initial uncertainty and discomfort',
      ];
    } else {
      return [
        '✓ Maintains current stability and comfort',
        '✓ Predictable short-term outcomes',
        '⚠ Limited growth opportunities',
        '⚠ Potential for long-term regret',
        '⚠ May not align with evolving goals',
      ];
    }
  }

  static void clearCache() {
    _cache = null;
  }
}
