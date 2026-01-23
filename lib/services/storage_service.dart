import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StorageService {
  static const String _baseUrl = 'http://localhost:3000/api';
  static const String _userKey = 'user_profile';
  static const String _memoriesKey = 'memories';
  static const String _digestsKey = 'digests';
  static const String _simulationsKey = 'simulations';
  static const String _onboardingKey = 'onboarding_complete';

  static SharedPreferences? _prefs;
  static String? _authToken;

  static String get baseUrl {
    return dotenv.env['API_BASE_URL'] ?? _baseUrl;
  }

  static set authToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

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

  // Authentication methods with API first, local fallback
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        // Also save to local storage as backup
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString(_userKey, jsonEncode(data['user']));
        return data['user'];
      }
    } catch (e) {
      debugPrint('API login failed, using local fallback: $e');
    }

    // Fallback to local storage
    return getUser();
  }

  static Future<Map<String, dynamic>?> register(String email, String password, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        await prefs.setString('auth_token', _authToken!);
        await prefs.setString(_userKey, jsonEncode(data['user']));
        return data['user'];
      }
    } catch (e) {
      debugPrint('API registration failed, using local fallback: $e');
    }

    // Fallback: create local user
    final user = {'id': DateTime.now().millisecondsSinceEpoch.toString(), 'email': email, 'name': name, 'onboardingCompleted': false};
    await prefs.setString(_userKey, jsonEncode(user));
    return user;
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    // Try API first
    if (_authToken != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/auth/profile'),
          headers: _headers,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return data['user'];
        }
      } catch (e) {
        debugPrint('API get user failed: $e');
      }
    }

    // Fallback to local storage
    return getUser();
  }

  // Memory methods with API first, local fallback
  static Future<List<Map<String, dynamic>>> getMemories() async {
    // Try API first
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/memories'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['memories']);
      }
    } catch (e) {
      debugPrint('API get memories failed, using local fallback: $e');
    }

    // Fallback to local storage
    return getMemoriesSync();
  }

  static Future<bool> saveMemory(Map<String, dynamic> memory) async {
    // Try API first
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/memories'),
        headers: _headers,
        body: jsonEncode(memory),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('API save memory failed, using local fallback: $e');
    }

    // Fallback to local storage
    return saveMemories([...getMemoriesSync(), memory]);
  }

  // Digest methods with API first, local fallback
  static Future<List<Map<String, dynamic>>> getDigests() async {
    // Try API first
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/digests'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['digests']);
      }
    } catch (e) {
      debugPrint('API get digests failed, using local fallback: $e');
    }

    // Fallback to local storage
    return getDigestsSync();
  }

  static Future<bool> saveDigest(Map<String, dynamic> digest) async {
    // Try API first
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/digests'),
        headers: _headers,
        body: jsonEncode(digest),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('API save digest failed, using local fallback: $e');
    }

    // Fallback to local storage
    return saveDigests([...getDigestsSync(), digest]);
  }

  // Simulation methods with API first, local fallback
  static Future<List<Map<String, dynamic>>> getSimulations() async {
    // Try API first
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/simulations'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['simulations']);
      }
    } catch (e) {
      debugPrint('API get simulations failed, using local fallback: $e');
    }

    // Fallback to local storage
    return getSimulationsSync();
  }

  static Future<bool> saveSimulation(Map<String, dynamic> simulation) async {
    // Try API first
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/simulations'),
        headers: _headers,
        body: jsonEncode(simulation),
      );

      if (response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint('API save simulation failed, using local fallback: $e');
    }

    // Fallback to local storage
    return saveSimulations([...getSimulationsSync(), simulation]);
  }

  // Local storage methods (existing implementation)
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

  static List<Map<String, dynamic>> getMemoriesSync() {
    try {
      final data = prefs.getString(_memoriesKey);
      return data != null ? List<Map<String, dynamic>>.from(jsonDecode(data)) : [];
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

  static List<Map<String, dynamic>> getDigestsSync() {
    try {
      final data = prefs.getString(_digestsKey);
      return data != null ? List<Map<String, dynamic>>.from(jsonDecode(data)) : [];
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

  static List<Map<String, dynamic>> getSimulationsSync() {
    try {
      final data = prefs.getString(_simulationsKey);
      return data != null ? List<Map<String, dynamic>>.from(jsonDecode(data)) : [];
    } catch (e) {
      debugPrint('Failed to get simulations: $e');
      return [];
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

  static Future<bool> setOnboardingComplete(bool complete) async {
    try {
      return await prefs.setBool(_onboardingKey, complete);
    } catch (e) {
      debugPrint('Failed to set onboarding status: $e');
      return false;
    }
  }


  static Future<String> exportAllData() async {
    try {
      final data = {
        'user': getUser(),
        'memories': getMemoriesSync(),
        'digests': getDigestsSync(),
        'simulations': getSimulationsSync(),
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
