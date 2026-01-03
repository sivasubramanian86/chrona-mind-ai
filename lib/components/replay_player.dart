import 'package:flutter/material.dart';
import 'package:chronamindai/theme.dart';

class ReplayPlayer extends StatefulWidget {
  final String title;
  final Duration duration;
  final bool hasNarration;

  const ReplayPlayer({
    super.key,
    required this.title,
    required this.duration,
    this.hasNarration = false,
  });

  @override
  State<ReplayPlayer> createState() => _ReplayPlayerState();
}

class _ReplayPlayerState extends State<ReplayPlayer> {
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _narrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: Colors.black, // Cinematic feel
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Visualizer / Video Placeholder
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primaryContainer.withOpacity(0.2),
                  theme.colorScheme.tertiaryContainer.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 48,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Controls
          Row(
            children: [
               IconButton(
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: context.textStyles.titleSmall?.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: theme.colorScheme.primary,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (v) => setState(() => _progress = v),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.hasNarration)
                IconButton(
                  onPressed: () => setState(() => _narrationEnabled = !_narrationEnabled),
                  icon: Icon(
                    _narrationEnabled ? Icons.record_voice_over : Icons.voice_over_off,
                    color: _narrationEnabled ? theme.colorScheme.secondary : Colors.white24,
                  ),
                  tooltip: 'Narration',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
