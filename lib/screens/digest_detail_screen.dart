import 'package:flutter/material.dart';
import 'package:chronamindai/models/digest.dart';
import 'package:chronamindai/services/digest_service.dart';
import 'package:chronamindai/theme.dart';

class DigestDetailScreen extends StatefulWidget {
  final String digestId;

  const DigestDetailScreen({
    super.key,
    required this.digestId,
  });

  @override
  State<DigestDetailScreen> createState() => _DigestDetailScreenState();
}

class _DigestDetailScreenState extends State<DigestDetailScreen> {
  Digest? _digest;
  int _currentFlashcardIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadDigest();
  }

  Future<void> _loadDigest() async {
    final digest = await DigestService.getDigestById(widget.digestId);
    if (mounted) {
      setState(() => _digest = digest);
    }
  }

  void _nextFlashcard() {
    setState(() {
      _showAnswer = false;
      _currentFlashcardIndex = (_currentFlashcardIndex + 1) % _digest!.flashcards.length;
    });
  }

  void _previousFlashcard() {
    setState(() {
      _showAnswer = false;
      _currentFlashcardIndex = (_currentFlashcardIndex - 1 + _digest!.flashcards.length) % _digest!.flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_digest == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _digest!.title,
                          style: context.textStyles.titleLarge?.bold.withColor(
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_digest!.estimatedReadTime} minute read',
                          style: context.textStyles.bodySmall?.withColor(
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Summary',
              style: context.textStyles.headlineSmall?.bold,
            ),
            const SizedBox(height: 16),
            Text(
              _digest!.paretoSummary,
              style: context.textStyles.bodyLarge,
            ),
            const SizedBox(height: 32),
            Text(
              'Key Takeaways',
              style: context.textStyles.headlineSmall?.bold,
            ),
            const SizedBox(height: 16),
            ..._digest!.keyTakeaways.map((takeaway) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      takeaway,
                      style: context.textStyles.bodyLarge,
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 32),
            Text(
              'Flashcards',
              style: context.textStyles.headlineSmall?.bold,
            ),
            const SizedBox(height: 16),
            if (_digest!.flashcards.isNotEmpty) _buildFlashcardCarousel(),
            const SizedBox(height: 32),
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_tree,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mind Map',
                    style: context.textStyles.titleMedium?.bold,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Visual mind map generation coming soon',
                    style: context.textStyles.bodyMedium?.withColor(
                      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlashcardCarousel() {
    final flashcard = _digest!.flashcards[_currentFlashcardIndex];
    
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _showAnswer = !_showAnswer),
          child: Container(
            height: 250,
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _showAnswer ? 'Answer' : 'Question',
                  style: context.textStyles.labelLarge?.withColor(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Text(
                      _showAnswer ? flashcard.answer : flashcard.question,
                      style: context.textStyles.titleLarge?.bold.withColor(Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to ${_showAnswer ? 'see question' : 'reveal answer'}',
                  style: context.textStyles.bodySmall?.withColor(
                    Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.outlined(
              icon: const Icon(Icons.arrow_back),
              onPressed: _currentFlashcardIndex > 0 ? _previousFlashcard : null,
            ),
            Text(
              '${_currentFlashcardIndex + 1} / ${_digest!.flashcards.length}',
              style: context.textStyles.bodyMedium,
            ),
            IconButton.outlined(
              icon: const Icon(Icons.arrow_forward),
              onPressed: _currentFlashcardIndex < _digest!.flashcards.length - 1 ? _nextFlashcard : null,
            ),
          ],
        ),
      ],
    );
  }
}
