import 'package:uuid/uuid.dart';

class SimulationNode {
  final String id;
  final String label;
  final String description;
  final List<String> outcomes;
  final double confidence;
  final List<SimulationNode> childChoices;

  SimulationNode({
    required this.id,
    required this.label,
    required this.description,
    required this.outcomes,
    required this.confidence,
    required this.childChoices,
  });

  factory SimulationNode.create({
    required String label,
    required String description,
    List<String>? outcomes,
    double confidence = 0.5,
    List<SimulationNode>? childChoices,
  }) => SimulationNode(
    id: const Uuid().v4(),
    label: label,
    description: description,
    outcomes: outcomes ?? [],
    confidence: confidence,
    childChoices: childChoices ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'description': description,
    'outcomes': outcomes,
    'confidence': confidence,
    'childChoices': childChoices.map((c) => c.toJson()).toList(),
  };

  factory SimulationNode.fromJson(Map<String, dynamic> json) => SimulationNode(
    id: json['id'] as String,
    label: json['label'] as String,
    description: json['description'] as String,
    outcomes: List<String>.from(json['outcomes'] as List? ?? []),
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
    childChoices: (json['childChoices'] as List? ?? [])
        .map((c) => SimulationNode.fromJson(c as Map<String, dynamic>))
        .toList(),
  );

  SimulationNode copyWith({
    String? label,
    String? description,
    List<String>? outcomes,
    double? confidence,
    List<SimulationNode>? childChoices,
  }) => SimulationNode(
    id: id,
    label: label ?? this.label,
    description: description ?? this.description,
    outcomes: outcomes ?? this.outcomes,
    confidence: confidence ?? this.confidence,
    childChoices: childChoices ?? this.childChoices,
  );
}

class Simulation {
  final String id;
  final String userId;
  final String title;
  final String description;
  final SimulationNode rootChoice;
  final DateTime createdAt;
  final DateTime updatedAt;

  Simulation({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.rootChoice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Simulation.create({
    required String userId,
    required String title,
    required String description,
    required SimulationNode rootChoice,
  }) {
    final now = DateTime.now();
    return Simulation(
      id: const Uuid().v4(),
      userId: userId,
      title: title,
      description: description,
      rootChoice: rootChoice,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'description': description,
    'rootChoice': rootChoice.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Simulation.fromJson(Map<String, dynamic> json) => Simulation(
    id: json['id'] as String,
    userId: json['userId'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    rootChoice: SimulationNode.fromJson(json['rootChoice'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Simulation copyWith({
    String? title,
    String? description,
    SimulationNode? rootChoice,
  }) => Simulation(
    id: id,
    userId: userId,
    title: title ?? this.title,
    description: description ?? this.description,
    rootChoice: rootChoice ?? this.rootChoice,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
