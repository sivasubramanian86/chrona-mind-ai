import 'package:flutter/material.dart';
import 'package:chronamindai/theme.dart';

class CaptureModal extends StatefulWidget {
  final Function(String text, List<String> attachments, String? voicePath)
      onSave;

  const CaptureModal({super.key, required this.onSave});

  @override
  State<CaptureModal> createState() => _CaptureModalState();
}

class _CaptureModalState extends State<CaptureModal> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _attachments = [];
  String? _voicePath;
  bool _isRecording = false;

  void _handleAttachment() async {
    // Placeholder for image picker logic
    // In production, use ImagePicker or FilePicker
    setState(() {
      _attachments.add('placeholder_image.jpg');
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _voicePath = 'temp_recording.aac';
      }
    });
  }

  void _handleSave() {
    if (_textController.text.isNotEmpty ||
        _attachments.isNotEmpty ||
        _voicePath != null) {
      widget.onSave(_textController.text, _attachments, _voicePath);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + keyboardHeight,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capture Memory',
                style: context.textStyles.titleLarge?.bold,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _textController,
            maxLines: 4,
            minLines: 2,
            decoration: InputDecoration(
              hintText: 'What\'s on your mind?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_attachments.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _attachments.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(Icons.image, color: theme.colorScheme.onTertiaryContainer),
                ),
              ),
            ),
          if (_voicePath != null)
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.graphic_eq),
                  const SizedBox(width: 8),
                  const Text('Audio recording attached'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => setState(() => _voicePath = null),
                  )
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              IconButton(
                onPressed: _handleAttachment,
                icon: const Icon(Icons.image_outlined),
                tooltip: 'Add Image',
              ),
              IconButton(
                onPressed: _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic_none,
                  color: _isRecording ? theme.colorScheme.error : null,
                ),
                tooltip: 'Record Voice',
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _handleSave,
                child: const Text('Save Memory'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
