import 'package:chronamindai/models/user_profile.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static UserProfile? _currentUser;

  static Future<UserProfile?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    
    try {
      final data = StorageService.getUser();
      if (data != null) {
        _currentUser = UserProfile.fromJson(data);
        return _currentUser;
      }
    } catch (e) {
      debugPrint('Failed to get current user: $e');
    }
    return null;
  }

  static Future<bool> saveUser(UserProfile user) async {
    try {
      final success = await StorageService.saveUser(user.toJson());
      if (success) {
        _currentUser = user;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save user: $e');
      return false;
    }
  }

  static Future<bool> updateUser(UserProfile user) async => saveUser(user);

  static Future<UserProfile> createDefaultUser() async {
    final user = UserProfile.create(
      name: 'Demo User',
      email: 'demo@chronamind.ai',
      voicePersonaOptIn: false,
      encryptionEnabled: false,
    );
    await saveUser(user);
    return user;
  }

  static void clearCache() {
    _currentUser = null;
  }
}
