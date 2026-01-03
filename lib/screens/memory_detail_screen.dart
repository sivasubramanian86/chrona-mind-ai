import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chronamindai/models/memory_item.dart';
import 'package:chronamindai/services/memory_service.dart';
import 'package:chronamindai/services/user_service.dart';
import 'package:chronamindai/services/elevenlabs_service.dart';
import 'package:chronamindai/models/user_profile.dart';
import 'package:chronamindai/theme.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class MemoryDetailScreen extends StatefulWidget {
  final String memoryId;

  const MemoryDetailScreen({
    super.key,
    required this.memoryId,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  MemoryItem? _memory;
  bool _isPlaying = false;
  double _playbackPosition = 0.0;
  UserProfile? _user;
  String? _narrationUrl;
  bool _isGeneratingNarration = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadMemory();
    _loadUser();
  }

  Future<void> _loadMemory() async {
    final memory = await MemoryService.getMemoryById(widget.memoryId);
    if (mounted) {
      setState(() => _memory = memory);
    }
  }

  Future<void> _loadUser() async {
    final user = await UserService.getCurrentUser();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _generateNarration() async {
    if (_user?.voicePersonaOptIn != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice narration requires opt-in in settings')),
      );
      return;
    }

    if (_memory?.summary.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No summary available for narration')),
      );
      return;
    }

    setState(() => _isGeneratingNarration = true);
    try {
      // Assume API key is set from env or somewhere. In production, load from secure storage.
      final url = await ElevenLabsService.synthesizeVoice(_memory!.summary);
      if (mounted) {
        setState(() => _narrationUrl = url);
        final isMock = url.isEmpty || url.contains('mock_');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isMock ? 'Mock narration generated (API key not configured)' : 'Narration generated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate narration: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingNarration = false);
      }
    }
  }

  Future<void> _simulatePlayback() async {
    final duration = _memory?.duration?.toDouble() ?? 30.0;
    while (_isPlaying && _playbackPosition < duration && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_isPlaying && mounted) {
        setState(() {
          _playbackPosition += 0.1;
          if (_playbackPosition >= duration) {
            _playbackPosition = duration;
            _isPlaying = false;
          }
        });
      }
    }
  }
  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _simulatePlayback();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_memory == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(_memory!.title),
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/backgrounds/memory_detail_background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _getIcon(),
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(_memory!.timestamp),
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_memory!.type == MemoryType.voice) _buildCinematicPlayer(),
                  if (_memory!.summary.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Summary',
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _memory!.summary,
                      style: context.textStyles.bodyLarge,
                    ),
                  ],
                  if (_memory!.contentText != null) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Content',
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _memory!.contentText!,
                      style: context.textStyles.bodyLarge,
                    ),
                  ],
                  if (_memory!.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Tags',
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _memory!.tags.map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicPlayer() {
    final duration = _memory?.duration?.toDouble() ?? 30.0;
    
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                iconSize: 64,
                color: Theme.of(context).colorScheme.primary,
                onPressed: _togglePlayback,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              Slider(
                value: _playbackPosition,
                max: duration,
                onChanged: (value) => setState(() => _playbackPosition = value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_playbackPosition),
                      style: context.textStyles.bodySmall,
                    ),
                    Text(
                      _formatDuration(duration),
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_user?.voicePersonaOptIn == true) ...[
            ElevatedButton.icon(
              onPressed: _isGeneratingNarration ? null : _generateNarration,
              icon: _isGeneratingNarration 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.record_voice_over),
              label: Text(_narrationUrl != null ? 'Regenerate Narration' : 'Generate Narration'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            if (_narrationUrl != null) ...[
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_narrationUrl == null || _narrationUrl!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No narration available')),
                    );
                    return;
                  }

                  try {
                    if (_narrationUrl!.contains('mock_')) {
                      // Mock narration - just show a message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playing mock narration (silent audio)')),
                      );
                    } else if (_narrationUrl!.startsWith('data:')) {
                      // For data URL, we can't play directly with audioplayers easily.
                      // In production, save to file or use a different approach.
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playing narration (simulated)')),
                      );
                    } else {
                      // Check if file exists
                      final file = File(_narrationUrl!);
                      if (await file.exists()) {
                        await _audioPlayer.play(UrlSource(_narrationUrl!));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Narration file not found')),
                        );
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to play narration: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Narration'),
              ),
            ],
          ] else ...[
            const Text('Voice narration requires opt-in in settings'),
          ],
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (_memory!.type) {
      case MemoryType.text:
        return Icons.article;
      case MemoryType.voice:
        return Icons.mic;
      case MemoryType.image:
        return Icons.image;
      case MemoryType.video:
        return Icons.videocam;
    }
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
