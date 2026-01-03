import 'dart:convert';
import 'package:http/http.dart' as http;
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
    // Try API first
    try {
      final response = await http.post(
        Uri.parse('${StorageService.baseUrl}/simulations'),
        headers: StorageService._headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'optionA': optionA,
          'optionB': optionB,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final simulationData = data['simulation'];

        // Convert API response to frontend Simulation model
        return Simulation.fromJson({
          'id': simulationData['id'],
          'userId': userId,
          'title': simulationData['title'],
          'description': simulationData['description'],
          'rootChoice': {
            'label': simulationData['title'],
            'description': simulationData['description'],
            'childChoices': [
              {
                'label': simulationData['optionA']['text'],
                'description': 'Path A: ${simulationData['optionA']['text']}',
                'outcomes': simulationData['optionA']['outcomes'].map((o) => o['description']).toList(),
                'confidence': 0.65,
              },
              {
                'label': simulationData['optionB']['text'],
                'description': 'Path B: ${simulationData['optionB']['text']}',
                'outcomes': simulationData['optionB']['outcomes'].map((o) => o['description']).toList(),
                'confidence': 0.55,
              }
            ],
            'confidence': 1.0,
          },
          'createdAt': simulationData['createdAt'],
          'updatedAt': simulationData['updatedAt'],
        });
      }
    } catch (e) {
      debugPrint('API simulation creation failed, using local fallback: $e');
    }

    // Fallback to local generation
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
    
    final simulation = Simulation.create(
      userId: userId,
      title: title,
      description: description,
      rootChoice: root,
    );

    // Save to local storage as fallback
    await StorageService.saveSimulation(simulation.toJson());

    return simulation;
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
