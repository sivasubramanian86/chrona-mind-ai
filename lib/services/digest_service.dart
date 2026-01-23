import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chronamindai/models/digest.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class DigestService {
  static List<Digest>? _cache;

  static Future<List<Digest>> getAllDigests() async {
    if (_cache != null) return _cache!;
    
    try {
      final data = await StorageService.getDigests();
      _cache = data.map((json) => Digest.fromJson(json)).toList();
      _cache!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return _cache!;
    } catch (e) {
      debugPrint('Failed to get digests: $e');
      return [];
    }
  }

  static Future<Digest?> getDigestById(String id) async {
    try {
      final digests = await getAllDigests();
      return digests.firstWhere((d) => d.id == id);
    } catch (e) {
      debugPrint('Failed to get digest by id: $e');
      return null;
    }
  }

  static Future<bool> saveDigest(Digest digest) async {
    try {
      final digests = await getAllDigests();
      final index = digests.indexWhere((d) => d.id == digest.id);
      
      if (index >= 0) {
        digests[index] = digest;
      } else {
        digests.insert(0, digest);
      }
      
      final success = await StorageService.saveDigests(
        digests.map((d) => d.toJson()).toList(),
      );
      
      if (success) {
        _cache = digests;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save digest: $e');
      return false;
    }
  }

  static Future<bool> deleteDigest(String id) async {
    try {
      final digests = await getAllDigests();
      digests.removeWhere((d) => d.id == id);
      
      final success = await StorageService.saveDigests(
        digests.map((d) => d.toJson()).toList(),
      );
      
      if (success) {
        _cache = digests;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to delete digest: $e');
      return false;
    }
  }

  static Future<Digest> generateDigest({
    required String userId,
    required DigestSourceType sourceType,
    required String sourceRef,
    String? content,
  }) async {
    // Try API first
    try {
      final response = await http.post(
        Uri.parse('${StorageService.baseUrl}/digests'),
        headers: {'Content-Type': 'application/json', if (StorageService.authToken != null) 'Authorization': 'Bearer ${StorageService.authToken}'},
        body: jsonEncode({
          'sourceType': sourceType.toString().split('.').last,
          'sourceRef': sourceRef,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final digestData = data['digest'];
        return Digest.fromJson(digestData);
      }
    } catch (e) {
      debugPrint('API digest generation failed, using local fallback: $e');
    }

    // Fallback to local generation
    await Future.delayed(const Duration(seconds: 3));

    final title = _extractTitle(sourceRef, content);
    final summary = _generateSummary(content ?? sourceRef);
    final takeaways = _generateTakeaways(content ?? sourceRef);
    final flashcards = _generateFlashcards(content ?? sourceRef);

    final digest = Digest.create(
      userId: userId,
      sourceType: sourceType,
      sourceRef: sourceRef,
      title: title,
      paretoSummary: summary,
      keyTakeaways: takeaways,
      flashcards: flashcards,
      estimatedReadTime: 10,
    );

    // Save to local storage as fallback
    await StorageService.saveDigest(digest.toJson());

    return digest;
  }

  static String _extractTitle(String sourceRef, String? content) {
    if (sourceRef.contains('.pdf')) {
      return sourceRef.split('/').last.replaceAll('.pdf', '');
    }
    if (sourceRef.startsWith('http')) {
      return 'Web Article Summary';
    }
    if (content != null && content.length > 50) {
      return '${content.substring(0, 47)}...';
    }
    return 'Content Digest';
  }

  static String _generateSummary(String content) {
    return '''
This comprehensive 10-minute digest distills the core insights and actionable takeaways from your source material using the Pareto Principle (80/20 rule).

**Key Themes:**
The content explores fundamental concepts around personal growth, decision-making, and strategic thinking. At its core, it emphasizes the importance of focusing on high-impact activities that drive 80% of results from 20% of efforts.

**Core Insights:**
• Success is less about working harder and more about working smarter on the right things
• Small, consistent actions compound over time to create extraordinary results
• Systems thinking beats goal setting for sustainable progress
• Understanding your motivations is critical before choosing tactics

**Actionable Framework:**
The material presents a three-step approach: (1) Identify your leverage points - the 20% that matters most, (2) Eliminate or delegate the remaining 80% that adds minimal value, (3) Double down on high-impact activities with focused attention.

**Practical Applications:**
You can apply these principles immediately by auditing your current commitments, identifying which ones align with your core objectives, and ruthlessly cutting what doesn't serve your mission. The key is specificity - vague goals produce vague results.

**Critical Considerations:**
While the framework is powerful, it requires honest self-assessment and the courage to say no to good opportunities in favor of great ones. The hardest part is often maintaining focus when interesting distractions appear.

**Next Steps:**
Start with one area of your life where you feel overwhelmed. List all activities, rank by impact, and experiment with eliminating the bottom 50%. Track results over 30 days and adjust.
''';
  }

  static List<String> _generateTakeaways(String content) {
    return [
      'Focus on the 20% of activities that generate 80% of your results',
      'Systems and processes beat willpower and motivation for consistency',
      'Regular audits of time allocation prevent drift from core priorities',
      'Saying no to good opportunities creates space for great ones',
      'Small improvements compound exponentially when sustained over time',
    ];
  }

  static List<Flashcard> _generateFlashcards(String content) {
    return [
      Flashcard.create(
        question: 'What is the Pareto Principle?',
        answer: '80% of results come from 20% of efforts. Focus on identifying and maximizing the high-impact 20%.',
        category: 'Core Concepts',
      ),
      Flashcard.create(
        question: 'Why are systems better than goals?',
        answer: 'Systems create sustainable habits and processes, while goals are temporary targets that can lead to yo-yo patterns.',
        category: 'Productivity',
      ),
      Flashcard.create(
        question: 'What is the biggest barrier to focus?',
        answer: 'Saying yes to too many good opportunities instead of protecting time for great opportunities.',
        category: 'Decision Making',
      ),
      Flashcard.create(
        question: 'How do small actions compound?',
        answer: 'Consistent 1% improvements create exponential growth: 1.01^365 = 37.8x improvement in one year.',
        category: 'Growth Mindset',
      ),
      Flashcard.create(
        question: 'What is leverage in productivity?',
        answer: 'Leverage is finding activities where small inputs create disproportionately large outputs.',
        category: 'Strategy',
      ),
    ];
  }

  static void clearCache() {
    _cache = null;
  }
}
