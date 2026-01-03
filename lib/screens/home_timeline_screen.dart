import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chronamindai/models/memory_item.dart';
import 'package:chronamindai/services/memory_service.dart';
import 'package:chronamindai/theme.dart';
import 'package:chronamindai/components/memory_card.dart';
import 'package:chronamindai/components/capture_modal.dart';

class HomeTimelineScreen extends StatefulWidget {
  const HomeTimelineScreen({super.key});

  @override
  State<HomeTimelineScreen> createState() => _HomeTimelineScreenState();
}

class _HomeTimelineScreenState extends State<HomeTimelineScreen> {
  List<MemoryItem> _memories = [];
  List<MemoryItem> _filteredMemories = [];
  MemoryType? _selectedFilter;
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    try {
      final memories = await MemoryService.getAllMemories();
      if (mounted) {
        setState(() {
          _memories = memories;
          _filteredMemories = memories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterMemories(MemoryType? type) {
    setState(() {
      _selectedFilter = type;
      if (type == null) {
        _filteredMemories = _memories;
      } else {
        _filteredMemories = _memories.where((m) => m.type == type).toList();
      }
    });
  }

  Future<void> _searchMemories(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredMemories = _memories);
      return;
    }
    
    final results = await MemoryService.searchMemories(query);
    setState(() => _filteredMemories = results);
  }

  void _showCaptureModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaptureModal(
        onSave: (text, attachments, voicePath) {
          Navigator.pop(context);
          _loadMemories();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'ChronaMindAI',
              style: context.textStyles.titleLarge?.bold,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/home_timeline_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMemories.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadMemories,
                          child: ListView.builder(
                            padding: AppSpacing.paddingMd,
                            itemCount: _filteredMemories.length,
                            itemBuilder: (context, index) => MemoryCard(
                              memory: _filteredMemories[index],
                              onTap: () => context.push('/memory/${_filteredMemories[index].id}'),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCaptureModal,
        icon: const Icon(Icons.add),
        label: const Text('Capture'),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.horizontalMd,
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _selectedFilter == null,
            onSelected: (_) => _filterMemories(null),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('📝 Text'),
            selected: _selectedFilter == MemoryType.text,
            onSelected: (_) => _filterMemories(MemoryType.text),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('🎙️ Voice'),
            selected: _selectedFilter == MemoryType.voice,
            onSelected: (_) => _filterMemories(MemoryType.voice),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('🖼️ Image'),
            selected: _selectedFilter == MemoryType.image,
            onSelected: (_) => _filterMemories(MemoryType.image),
          ),
        ],
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
              Icons.auto_stories,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No memories yet',
              style: context.textStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the Capture button to start recording your journey',
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Memories'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter keywords...',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            _searchMemories(query);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _searchMemories(_searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
