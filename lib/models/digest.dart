import 'package:uuid/uuid.dart';

enum DigestSourceType { pdf, url, text }

class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String category;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  factory Flashcard.create({
    required String question,
    required String answer,
    required String category,
  }) => Flashcard(
    id: const Uuid().v4(),
    question: question,
    answer: answer,
    category: category,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'category': category,
  };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
    id: json['id'] as String,
    question: json['question'] as String,
    answer: json['answer'] as String,
    category: json['category'] as String,
  );
}

class Digest {
  final String id;
  final String userId;
  final DigestSourceType sourceType;
  final String sourceRef;
  final String title;
  final String paretoSummary;
  final List<String> keyTakeaways;
  final List<Flashcard> flashcards;
  final int estimatedReadTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Digest({
    required this.id,
    required this.userId,
    required this.sourceType,
    required this.sourceRef,
    required this.title,
    required this.paretoSummary,
    required this.keyTakeaways,
    required this.flashcards,
    required this.estimatedReadTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Digest.create({
    required String userId,
    required DigestSourceType sourceType,
    required String sourceRef,
    required String title,
    String paretoSummary = '',
    List<String>? keyTakeaways,
    List<Flashcard>? flashcards,
    int estimatedReadTime = 10,
  }) {
    final now = DateTime.now();
    return Digest(
      id: const Uuid().v4(),
      userId: userId,
      sourceType: sourceType,
      sourceRef: sourceRef,
      title: title,
      paretoSummary: paretoSummary,
      keyTakeaways: keyTakeaways ?? [],
      flashcards: flashcards ?? [],
      estimatedReadTime: estimatedReadTime,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'sourceType': sourceType.name,
    'sourceRef': sourceRef,
    'title': title,
    'paretoSummary': paretoSummary,
    'keyTakeaways': keyTakeaways,
    'flashcards': flashcards.map((f) => f.toJson()).toList(),
    'estimatedReadTime': estimatedReadTime,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Digest.fromJson(Map<String, dynamic> json) => Digest(
    id: json['id'] as String,
    userId: json['userId'] as String,
    sourceType: DigestSourceType.values.firstWhere((e) => e.name == json['sourceType']),
    sourceRef: json['sourceRef'] as String,
    title: json['title'] as String,
    paretoSummary: json['paretoSummary'] as String? ?? '',
    keyTakeaways: List<String>.from(json['keyTakeaways'] as List? ?? []),
    flashcards: (json['flashcards'] as List? ?? [])
        .map((f) => Flashcard.fromJson(f as Map<String, dynamic>))
        .toList(),
    estimatedReadTime: json['estimatedReadTime'] as int? ?? 10,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Digest copyWith({
    String? title,
    String? paretoSummary,
    List<String>? keyTakeaways,
    List<Flashcard>? flashcards,
    int? estimatedReadTime,
  }) => Digest(
    id: id,
    userId: userId,
    sourceType: sourceType,
    sourceRef: sourceRef,
    title: title ?? this.title,
    paretoSummary: paretoSummary ?? this.paretoSummary,
    keyTakeaways: keyTakeaways ?? this.keyTakeaways,
    flashcards: flashcards ?? this.flashcards,
    estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
