import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _userKey = 'user_profile';
  static const String _memoriesKey = 'memories';
  static const String _digestsKey = 'digests';
  static const String _simulationsKey = 'simulations';
  static const String _onboardingKey = 'onboarding_complete';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  static Future<bool> saveUser(Map<String, dynamic> user) async {
    try {
      return await prefs.setString(_userKey, jsonEncode(user));
    } catch (e) {
      debugPrint('Failed to save user: $e');
      return false;
    }
  }

  static Map<String, dynamic>? getUser() {
    try {
      final data = prefs.getString(_userKey);
      return data != null ? jsonDecode(data) as Map<String, dynamic> : null;
    } catch (e) {
      debugPrint('Failed to get user: $e');
      return null;
    }
  }

  static Future<bool> saveMemories(List<Map<String, dynamic>> memories) async {
    try {
      return await prefs.setString(_memoriesKey, jsonEncode(memories));
    } catch (e) {
      debugPrint('Failed to save memories: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> getMemories() {
    try {
      final data = prefs.getString(_memoriesKey);
      if (data == null) return [];
      final decoded = jsonDecode(data);
      return List<Map<String, dynamic>>.from(decoded as List);
    } catch (e) {
      debugPrint('Failed to get memories: $e');
      return [];
    }
  }

  static Future<bool> saveDigests(List<Map<String, dynamic>> digests) async {
    try {
      return await prefs.setString(_digestsKey, jsonEncode(digests));
    } catch (e) {
      debugPrint('Failed to save digests: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> getDigests() {
    try {
      final data = prefs.getString(_digestsKey);
      if (data == null) return [];
      final decoded = jsonDecode(data);
      return List<Map<String, dynamic>>.from(decoded as List);
    } catch (e) {
      debugPrint('Failed to get digests: $e');
      return [];
    }
  }

  static Future<bool> saveSimulations(List<Map<String, dynamic>> simulations) async {
    try {
      return await prefs.setString(_simulationsKey, jsonEncode(simulations));
    } catch (e) {
      debugPrint('Failed to save simulations: $e');
      return false;
    }
  }

  static List<Map<String, dynamic>> getSimulations() {
    try {
      final data = prefs.getString(_simulationsKey);
      if (data == null) return [];
      final decoded = jsonDecode(data);
      return List<Map<String, dynamic>>.from(decoded as List);
    } catch (e) {
      debugPrint('Failed to get simulations: $e');
      return [];
    }
  }

  static Future<bool> setOnboardingComplete(bool complete) async {
    try {
      return await prefs.setBool(_onboardingKey, complete);
    } catch (e) {
      debugPrint('Failed to set onboarding status: $e');
      return false;
    }
  }

  static bool isOnboardingComplete() {
    try {
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      debugPrint('Failed to get onboarding status: $e');
      return false;
    }
  }

  static Future<String> exportAllData() async {
    try {
      final data = {
        'user': getUser(),
        'memories': getMemories(),
        'digests': getDigests(),
        'simulations': getSimulations(),
        'exportedAt': DateTime.now().toIso8601String(),
      };
      return jsonEncode(data);
    } catch (e) {
      debugPrint('Failed to export data: $e');
      return '{}';
    }
  }

  static Future<bool> deleteAllData() async {
    try {
      await prefs.clear();
      return true;
    } catch (e) {
      debugPrint('Failed to delete all data: $e');
      return false;
    }
  }
}
