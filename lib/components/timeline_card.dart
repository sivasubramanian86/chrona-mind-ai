import 'package:flutter/material.dart';
import 'package:chronamindai/theme.dart';
import 'package:chronamindai/models/memory_item.dart';
import 'package:intl/intl.dart';

class TimelineCard extends StatelessWidget {
  final MemoryItem memory;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const TimelineCard({
    super.key,
    required this.memory,
    required this.onTap,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVoice = memory.type == MemoryType.voice;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: AppSpacing.paddingSm,
                  decoration: BoxDecoration(
                    color: _getTypeColor(theme, memory.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getTypeIcon(memory.type),
                    color: _getTypeColor(theme, memory.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: context.textStyles.titleMedium?.semiBold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        DateFormat('MMM d • h:mm a').format(memory.timestamp),
                        style: context.textStyles.bodySmall?.withColor(
                          theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVoice && onPlay != null)
                  IconButton(
                    onPressed: onPlay,
                    icon: const Icon(Icons.play_circle_fill),
                    color: theme.colorScheme.primary,
                    iconSize: 32,
                  ),
              ],
            ),
            if (memory.summary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                memory.summary,
                style: context.textStyles.bodyMedium?.withColor(
                  theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                ...memory.tags.take(3).map((tag) => Container(
                      margin: const EdgeInsets.only(right: AppSpacing.xs),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        tag,
                        style: context.textStyles.labelSmall?.medium,
                      ),
                    )),
                const Spacer(),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: theme.colorScheme.outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(MemoryType type) {
    switch (type) {
      case MemoryType.text:
        return Icons.article;
      case MemoryType.voice:
        return Icons.graphic_eq;
      case MemoryType.image:
        return Icons.image;
      case MemoryType.video:
        return Icons.videocam;
    }
  }

  Color _getTypeColor(ThemeData theme, MemoryType type) {
    switch (type) {
      case MemoryType.text:
        return theme.colorScheme.primary;
      case MemoryType.voice:
        return theme.colorScheme.secondary;
      case MemoryType.image:
        return theme.colorScheme.tertiary;
      case MemoryType.video:
        return theme.colorScheme.error;
    }
  }
}
