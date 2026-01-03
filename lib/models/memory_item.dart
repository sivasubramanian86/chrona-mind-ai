import 'package:uuid/uuid.dart';

enum MemoryType { text, voice, image, video }

class MemoryItem {
  final String id;
  final String userId;
  final MemoryType type;
  final String title;
  final String? contentText;
  final String? audioPath;
  final String? imagePath;
  final DateTime timestamp;
  final List<String> tags;
  final String summary;
  final List<double> highlightTimestamps;
  final int? duration;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoryItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.contentText,
    this.audioPath,
    this.imagePath,
    required this.timestamp,
    required this.tags,
    required this.summary,
    required this.highlightTimestamps,
    this.duration,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemoryItem.create({
    required String userId,
    required MemoryType type,
    required String title,
    String? contentText,
    String? audioPath,
    String? imagePath,
    List<String>? tags,
    String? summary,
    int? duration,
  }) {
    final now = DateTime.now();
    return MemoryItem(
      id: const Uuid().v4(),
      userId: userId,
      type: type,
      title: title,
      contentText: contentText,
      audioPath: audioPath,
      imagePath: imagePath,
      timestamp: now,
      tags: tags ?? [],
      summary: summary ?? '',
      highlightTimestamps: [],
      duration: duration,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'title': title,
    'contentText': contentText,
    'audioPath': audioPath,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'tags': tags,
    'summary': summary,
    'highlightTimestamps': highlightTimestamps,
    'duration': duration,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
    id: json['id'] as String,
    userId: json['userId'] as String,
    type: MemoryType.values.firstWhere((e) => e.name == json['type']),
    title: json['title'] as String,
    contentText: json['contentText'] as String?,
    audioPath: json['audioPath'] as String?,
    imagePath: json['imagePath'] as String?,
    timestamp: DateTime.parse(json['timestamp'] as String),
    tags: List<String>.from(json['tags'] as List? ?? []),
    summary: json['summary'] as String? ?? '',
    highlightTimestamps: List<double>.from(json['highlightTimestamps'] as List? ?? []),
    duration: json['duration'] as int?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  MemoryItem copyWith({
    String? title,
    String? contentText,
    String? audioPath,
    String? imagePath,
    List<String>? tags,
    String? summary,
    List<double>? highlightTimestamps,
    int? duration,
  }) => MemoryItem(
    id: id,
    userId: userId,
    type: type,
    title: title ?? this.title,
    contentText: contentText ?? this.contentText,
    audioPath: audioPath ?? this.audioPath,
    imagePath: imagePath ?? this.imagePath,
    timestamp: timestamp,
    tags: tags ?? this.tags,
    summary: summary ?? this.summary,
    highlightTimestamps: highlightTimestamps ?? this.highlightTimestamps,
    duration: duration ?? this.duration,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
