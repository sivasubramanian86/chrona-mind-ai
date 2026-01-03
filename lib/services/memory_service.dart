import 'package:chronamindai/models/memory_item.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class MemoryService {
  static List<MemoryItem>? _cache;

  static Future<List<MemoryItem>> getAllMemories() async {
    if (_cache != null) return _cache!;
    
    try {
      final data = StorageService.getMemories();
      _cache = data.map((json) => MemoryItem.fromJson(json)).toList();
      _cache!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return _cache!;
    } catch (e) {
      debugPrint('Failed to get memories: $e');
      return [];
    }
  }

  static Future<MemoryItem?> getMemoryById(String id) async {
    try {
      final memories = await getAllMemories();
      return memories.firstWhere((m) => m.id == id);
    } catch (e) {
      debugPrint('Failed to get memory by id: $e');
      return null;
    }
  }

  static Future<List<MemoryItem>> filterByType(MemoryType type) async {
    final memories = await getAllMemories();
    return memories.where((m) => m.type == type).toList();
  }

  static Future<List<MemoryItem>> filterByTags(List<String> tags) async {
    final memories = await getAllMemories();
    return memories.where((m) => m.tags.any((tag) => tags.contains(tag))).toList();
  }

  static Future<List<MemoryItem>> searchMemories(String query) async {
    if (query.isEmpty) return getAllMemories();
    
    final memories = await getAllMemories();
    final lowercaseQuery = query.toLowerCase();
    
    return memories.where((m) {
      return m.title.toLowerCase().contains(lowercaseQuery) ||
          m.summary.toLowerCase().contains(lowercaseQuery) ||
          (m.contentText?.toLowerCase().contains(lowercaseQuery) ?? false) ||
          m.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static Future<bool> saveMemory(MemoryItem memory) async {
    try {
      final memories = await getAllMemories();
      final index = memories.indexWhere((m) => m.id == memory.id);
      
      if (index >= 0) {
        memories[index] = memory;
      } else {
        memories.insert(0, memory);
      }
      
      final success = await StorageService.saveMemories(
        memories.map((m) => m.toJson()).toList(),
      );
      
      if (success) {
        _cache = memories;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to save memory: $e');
      return false;
    }
  }

  static Future<bool> deleteMemory(String id) async {
    try {
      final memories = await getAllMemories();
      memories.removeWhere((m) => m.id == id);
      
      final success = await StorageService.saveMemories(
        memories.map((m) => m.toJson()).toList(),
      );
      
      if (success) {
        _cache = memories;
      }
      return success;
    } catch (e) {
      debugPrint('Failed to delete memory: $e');
      return false;
    }
  }

  static Future<void> initializeSampleData(String userId) async {
    final existing = await getAllMemories();
    if (existing.isNotEmpty) return;

    final samples = _generateSampleMemories(userId);
    for (final memory in samples) {
      await saveMemory(memory);
    }
  }

  static List<MemoryItem> _generateSampleMemories(String userId) {
    final now = DateTime.now();
    
    return [
      MemoryItem(
        id: 'sample_1',
        userId: userId,
        type: MemoryType.text,
        title: 'Career Reflection',
        contentText: 'Today I realized that my passion for AI and user experience design could merge into something extraordinary. The conversation with Sarah about ethical AI really opened my eyes to new possibilities.',
        timestamp: now.subtract(const Duration(days: 2)),
        tags: const ['career', 'ai', 'reflection'],
        summary: 'A pivotal moment of career clarity blending AI and UX design',
        highlightTimestamps: const [0.0, 5.5, 12.3],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      
      MemoryItem(
        id: 'sample_2',
        userId: userId,
        type: MemoryType.voice,
        title: 'Morning Meditation Insight',
        contentText: 'During meditation, I had a breakthrough about letting go of perfectionism. The voice recording captures my raw emotions and the clarity that followed.',
        audioPath: 'mock_audio_meditation.mp3',
        timestamp: now.subtract(const Duration(days: 5)),
        tags: const ['mindfulness', 'personal-growth', 'meditation'],
        summary: 'Breakthrough meditation on releasing perfectionism',
        highlightTimestamps: const [15.0, 45.0, 120.0],
        duration: 180,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      
      MemoryItem(
        id: 'sample_3',
        userId: userId,
        type: MemoryType.image,
        title: 'Sunset at the Beach',
        contentText: 'The most peaceful moment of the year. This sunset reminded me why I started this journey in the first place.',
        imagePath: 'mock_image_sunset.jpg',
        timestamp: now.subtract(const Duration(days: 10)),
        tags: const ['travel', 'peace', 'inspiration'],
        summary: 'Peaceful beach sunset sparking renewed purpose',
        highlightTimestamps: const [],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      
      MemoryItem(
        id: 'sample_4',
        userId: userId,
        type: MemoryType.text,
        title: 'Book Notes: Atomic Habits',
        contentText: 'Key insight: Small changes compound over time. Identity-based habits are more sustainable than outcome-based ones. Focus on who you want to become, not just what you want to achieve.',
        timestamp: now.subtract(const Duration(days: 15)),
        tags: const ['learning', 'books', 'habits'],
        summary: 'Identity-based habits lead to lasting change',
        highlightTimestamps: const [0.0, 8.0],
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      
      MemoryItem(
        id: 'sample_5',
        userId: userId,
        type: MemoryType.voice,
        title: 'Decision: Should I Take the Startup Offer?',
        contentText: 'Recording my thoughts on the startup opportunity. Pros: equity, impact, learning. Cons: stability, risk, uncertainty. My gut says go for it.',
        audioPath: 'mock_audio_decision.mp3',
        timestamp: now.subtract(const Duration(days: 20)),
        tags: const ['career', 'decision', 'startup'],
        summary: 'Weighing startup opportunity - leaning toward taking the leap',
        highlightTimestamps: const [30.0, 120.0, 210.0],
        duration: 240,
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
    ];
  }

  static void clearCache() {
    _cache = null;
  }
}
