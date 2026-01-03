import 'package:uuid/uuid.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final bool voicePersonaOptIn;
  final bool encryptionEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.voicePersonaOptIn,
    required this.encryptionEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.create({
    required String name,
    required String email,
    bool voicePersonaOptIn = false,
    bool encryptionEnabled = false,
  }) {
    final now = DateTime.now();
    return UserProfile(
      id: const Uuid().v4(),
      name: name,
      email: email,
      voicePersonaOptIn: voicePersonaOptIn,
      encryptionEnabled: encryptionEnabled,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'voicePersonaOptIn': voicePersonaOptIn,
    'encryptionEnabled': encryptionEnabled,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    voicePersonaOptIn: json['voicePersonaOptIn'] as bool? ?? false,
    encryptionEnabled: json['encryptionEnabled'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  UserProfile copyWith({
    String? name,
    String? email,
    bool? voicePersonaOptIn,
    bool? encryptionEnabled,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    voicePersonaOptIn: voicePersonaOptIn ?? this.voicePersonaOptIn,
    encryptionEnabled: encryptionEnabled ?? this.encryptionEnabled,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );
}
