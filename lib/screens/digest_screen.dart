import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chronamindai/models/digest.dart';
import 'package:chronamindai/services/digest_service.dart';
import 'package:chronamindai/services/user_service.dart';
import 'package:chronamindai/theme.dart';
import 'package:intl/intl.dart';

class DigestScreen extends StatefulWidget {
  const DigestScreen({super.key});

  @override
  State<DigestScreen> createState() => _DigestScreenState();
}

class _DigestScreenState extends State<DigestScreen> {
  List<Digest> _digests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDigests();
  }

  Future<void> _loadDigests() async {
    setState(() => _isLoading = true);
    try {
      final digests = await DigestService.getAllDigests();
      if (mounted) {
        setState(() {
          _digests = digests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateDigestDialog() {
    final contentController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Pareto Digest'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Paste text, URL, or describe content...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mock: This will generate a summary using templates',
                style: context.textStyles.bodySmall?.withColor(
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _createDigest(contentController.text);
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  Future<void> _createDigest(String content) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generating digest...'),
              ],
            ),
          ),
        ),
      ),
    );

    final user = await UserService.getCurrentUser();
    if (user == null) return;

    final digest = await DigestService.generateDigest(
      userId: user.id,
      sourceType: DigestSourceType.text,
      sourceRef: content.substring(0, content.length > 50 ? 50 : content.length),
      content: content,
    );

    await DigestService.saveDigest(digest);

    if (mounted) {
      // Dismiss the loading dialog
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      // Navigate to the new digest detail
      context.push('/digest/${digest.id}');
      _loadDigests();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pareto Digest'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _digests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadDigests,
                  child: ListView.builder(
                    padding: AppSpacing.paddingMd,
                    itemCount: _digests.length,
                    itemBuilder: (context, index) => _buildDigestCard(_digests[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDigestDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Digest'),
      ),
    );
  }

  Widget _buildDigestCard(Digest digest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/digest/${digest.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          digest.title,
                          style: context.textStyles.titleMedium?.bold,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(digest.createdAt),
                          style: context.textStyles.bodySmall?.withColor(
                            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${digest.estimatedReadTime} min read',
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.style,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${digest.flashcards.length} flashcards',
                    style: context.textStyles.bodySmall?.withColor(
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No digests yet',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first 10-minute Pareto digest from any content',
              style: context.textStyles.bodyMedium?.withColor(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
