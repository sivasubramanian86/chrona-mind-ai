import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:chronamindai/services/user_service.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:chronamindai/models/user_profile.dart';
import 'package:chronamindai/theme.dart';
import 'package:chronamindai/utils/file_download_stub.dart'
    if (dart.library.html) 'package:chronamindai/utils/file_download_web.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final user = await UserService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final jsonData = await StorageService.exportAllData();
      
      if (kIsWeb) {
        downloadFile(
          jsonData,
          'chronamind_export_${DateTime.now().millisecondsSinceEpoch}.json',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This will permanently remove all your data and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.deleteAllData();
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  Future<void> _updateUserProfile() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final emailController = TextEditingController(text: _user!.email);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text,
              'email': emailController.text,
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updatedUser = _user!.copyWith(
        name: result['name'],
        email: result['email'],
      );
      await UserService.updateUser(updatedUser);
      _loadUser();
    }
  }

  Future<void> _toggleVoicePersona(bool value) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(voicePersonaOptIn: value);
    await UserService.updateUser(updatedUser);
    setState(() => _user = updatedUser);
  }

  Future<void> _toggleEncryption(bool value) async {
    if (_user == null) return;

    final updatedUser = _user!.copyWith(encryptionEnabled: value);
    await UserService.updateUser(updatedUser);
    setState(() => _user = updatedUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: context.textStyles.titleMedium?.bold.withColor(
                            Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      title: Text(_user?.name ?? 'User'),
                      subtitle: Text(_user?.email ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _updateUserProfile,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Privacy',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        Container(
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Voice Persona',
                                      style: context.textStyles.titleSmall?.bold,
                                    ),
                                    Text(
                                      'Enable AI voice narration',
                                      style: context.textStyles.bodySmall?.withColor(
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _user?.voicePersonaOptIn ?? false,
                                onChanged: _toggleVoicePersona,
                                activeColor: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Container(
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.surface,
                                Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Encryption',
                                      style: context.textStyles.titleSmall?.bold,
                                    ),
                                    Text(
                                      'Encrypt data at rest',
                                      style: context.textStyles.bodySmall?.withColor(
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _user?.encryptionEnabled ?? false,
                                onChanged: _toggleEncryption,
                                activeColor: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Data Management',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: const Text('Export Data'),
                          subtitle: const Text('Download all your data as JSON'),
                          onTap: _exportData,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.delete_forever,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            'Delete Account',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          subtitle: const Text('Permanently delete all data'),
                          onTap: _deleteAccount,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'About',
                    style: context.textStyles.titleLarge?.bold,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('ChronaMindAI - EchoTwin'),
                      subtitle: const Text('Version 1.0.0 (MVP)\nRelive your past, simulate your future'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
