import 'package:flutter/material.dart';
import 'package:chronamindai/theme.dart';

class DigestDashboard extends StatelessWidget {
  final Map<String, int> stats;
  final VoidCallback onGenerateDigest;

  const DigestDashboard({
    super.key,
    required this.stats,
    required this.onGenerateDigest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, theme),
        const SizedBox(height: AppSpacing.lg),
        _buildStatsGrid(context, theme),
        const SizedBox(height: AppSpacing.lg),
        _buildActionCard(context, theme),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Digest',
          style: context.textStyles.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Your memories synthesized into insights.',
          style: context.textStyles.bodyMedium?.withColor(
            theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            label: 'Memories',
            value: '${stats['memories'] ?? 0}',
            icon: Icons.history,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            label: 'Topics',
            value: '${stats['topics'] ?? 0}',
            icon: Icons.topic,
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: context.textStyles.headlineMedium?.bold,
          ),
          Text(
            label,
            style: context.textStyles.labelMedium?.withColor(
              theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: onGenerateDigest,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              color: theme.colorScheme.onPrimary,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Generate New Digest',
              style: context.textStyles.titleMedium?.bold.withColor(
                theme.colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Analyze this week\'s entries',
              style: context.textStyles.bodySmall?.withColor(
                theme.colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
