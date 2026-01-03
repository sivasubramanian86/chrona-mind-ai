import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ElevenLabsService {
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  // In production, ensure ELEVENLABS_API_KEY is available in .env file
  // Load with: await dotenv.load(fileName: ".env");
  static String? get _apiKey => dotenv.env['ELEVENLABS_API_KEY'];

  static Future<String> synthesizeVoice(String text, {String? voiceId}) async {
    final effectiveVoiceId = voiceId ?? dotenv.env['ELEVENLABS_VOICE_ID'] ?? '21m00Tcm4TlvDq8ikWAM';
    
    // Check if API key is available
    if (_apiKey == null || _apiKey!.isEmpty) {
      debugPrint('ElevenLabs API key not found, using mock narration');
      return _generateMockNarration(text);
    }

    final cacheFile = await _getCacheFile(text, effectiveVoiceId);
    if (await cacheFile.exists()) {
      return cacheFile.path;
    }

    final url = Uri.parse('$_baseUrl/text-to-speech/$effectiveVoiceId');
    final headers = {
      'Accept': 'audio/mpeg',
      'Content-Type': 'application/json',
      'xi-api-key': _apiKey!,
    };

    final body = jsonEncode({
      'text': text,
      'model_id': 'eleven_monolingual_v1',
      'voice_settings': {
        'stability': 0.5,
        'similarity_boost': 0.5,
      },
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        await cacheFile.writeAsBytes(response.bodyBytes);
        return cacheFile.path;
      } else {
        debugPrint('ElevenLabs API error: ${response.statusCode} - ${response.body}');
        return _generateMockNarration(text);
      }
    } catch (e) {
      debugPrint('ElevenLabs Service Error: $e');
      return _generateMockNarration(text);
    }
  }

  static Future<File> _getCacheFile(String text, String voiceId) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/chronamindai/audio');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final hash = sha256.convert(utf8.encode('$text-$voiceId')).toString();
    return File('${cacheDir.path}/$hash.mp3');
  }

  // Use for clearing cache on logout or settings
  static Future<void> clearCache() async {
     final dir = await getApplicationDocumentsDirectory();
     final cacheDir = Directory('${dir.path}/chronamindai/audio');
     if (await cacheDir.exists()) {
       await cacheDir.delete(recursive: true);
     }
  }

  // Generate mock narration for fallback when API is unavailable
  static Future<String> _generateMockNarration(String text) async {
    try {
      // Create a mock audio file with silence
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/chronamindai/audio');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final hash = sha256.convert(utf8.encode('mock_$text')).toString();
      final mockFile = File('${cacheDir.path}/mock_$hash.wav');

      // Create a minimal WAV file with silence (44 bytes header + 1 second of silence)
      // This is a very basic WAV structure for demonstration
      final wavHeader = <int>[
        0x52, 0x49, 0x46, 0x46, // "RIFF"
        0x24, 0x08, 0x00, 0x00, // File size (little endian)
        0x57, 0x41, 0x56, 0x45, // "WAVE"
        0x66, 0x6D, 0x74, 0x20, // "fmt "
        0x10, 0x00, 0x00, 0x00, // Chunk size
        0x01, 0x00,             // Audio format (PCM)
        0x01, 0x00,             // Number of channels
        0x80, 0x3E, 0x00, 0x00, // Sample rate (16000 Hz)
        0x00, 0x7D, 0x00, 0x00, // Byte rate
        0x02, 0x00,             // Block align
        0x10, 0x00,             // Bits per sample
        0x64, 0x61, 0x74, 0x61, // "data"
        0x00, 0x08, 0x00, 0x00, // Data size
      ];

      // Add some silence data (8 bytes = 4 samples at 16-bit mono 16kHz = ~0.25ms)
      final silenceData = List<int>.filled(8, 0);
      final mockWavData = wavHeader + silenceData;

      await mockFile.writeAsBytes(mockWavData);
      return mockFile.path;
    } catch (e) {
      debugPrint('Failed to generate mock narration: $e');
      // Return empty string as ultimate fallback
      return '';
    }
  }
}