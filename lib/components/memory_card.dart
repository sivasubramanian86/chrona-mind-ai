import 'package:flutter/material.dart';
import 'package:chronamindai/models/memory_item.dart';
import 'package:chronamindai/theme.dart';
import 'package:intl/intl.dart';

class MemoryCard extends StatelessWidget {
  final MemoryItem memory;
  final VoidCallback onTap;

  const MemoryCard({
    super.key,
    required this.memory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTypeIcon(context),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memory.title,
                            style: context.textStyles.titleMedium?.bold,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(memory.timestamp),
                            style: context.textStyles.bodySmall?.withColor(
                              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (memory.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    memory.summary,
                    style: context.textStyles.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (memory.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: memory.tags.take(3).map((tag) => Chip(
                      label: Text(
                        tag,
                        style: context.textStyles.labelSmall,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                ],
                if (memory.duration != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(memory.duration! / 60).floor()}:${(memory.duration! % 60).toString().padLeft(2, '0')}',
                        style: context.textStyles.bodySmall?.withColor(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    String iconPath;
    Color color;

    switch (memory.type) {
      case MemoryType.text:
        iconPath = 'assets/images/icons/memory_text_icon.png';
        color = Theme.of(context).colorScheme.primary;
        break;
      case MemoryType.voice:
        iconPath = 'assets/images/icons/memory_voice_icon.png';
        color = Theme.of(context).colorScheme.secondary;
        break;
      case MemoryType.image:
        iconPath = 'assets/images/icons/memory_image_icon.png';
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case MemoryType.video:
        iconPath = 'assets/images/icons/memory_video_icon.png';
        color = Theme.of(context).colorScheme.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        iconPath,
        width: 24,
        height: 24,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to default Material icons
          IconData fallbackIcon;
          switch (memory.type) {
            case MemoryType.text:
              fallbackIcon = Icons.article;
              break;
            case MemoryType.voice:
              fallbackIcon = Icons.mic;
              break;
            case MemoryType.image:
              fallbackIcon = Icons.image;
              break;
            case MemoryType.video:
              fallbackIcon = Icons.videocam;
              break;
          }
          return Icon(fallbackIcon, color: color, size: 24);
        },
      ),
    );
  }
}
