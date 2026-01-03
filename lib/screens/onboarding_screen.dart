import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:chronamindai/services/user_service.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:chronamindai/services/memory_service.dart';
import 'package:chronamindai/models/user_profile.dart';
import 'package:chronamindai/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _goalsController = TextEditingController();
  bool _voicePersonaOptIn = false;
  bool _analyticsOptIn = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and email')),
      );
      return;
    }

    final user = UserProfile.create(
      name: _nameController.text,
      email: _emailController.text,
      voicePersonaOptIn: _voicePersonaOptIn,
      encryptionEnabled: false,
    );

    await UserService.saveUser(user);
    await StorageService.setOnboardingComplete(true);
    await MemoryService.initializeSampleData(user.id);

    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/onboarding_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: AppSpacing.paddingLg,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentStep + 1) / 3,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingLg,
                  child: _buildStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildProfileStep();
      case 2:
        return _buildConsentStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildWelcomeStep() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Image.asset(
            'assets/images/illustrations/welcome_illustration.png',
            height: 200,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to\nChronaMindAI',
            style: context.textStyles.displaySmall?.bold,
          ),
          const SizedBox(height: 16),
          Text(
            'EchoTwin — Relive your past, simulate your future',
            style: context.textStyles.titleLarge?.withColor(
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Experience multimodal memory capture with cinematic replay and intelligent future simulation.',
            style: context.textStyles.bodyLarge,
          ),
          const SizedBox(height: 64),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Tell us about yourself',
            style: context.textStyles.headlineMedium?.bold,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Your Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _goalsController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'What brings you here? (Optional)',
              hintText: 'e.g., Track personal growth, make better decisions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 64),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 0),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 2),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsentStep() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text(
            'Privacy & Preferences',
            style: context.textStyles.headlineMedium?.bold,
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            value: _voicePersonaOptIn,
            onChanged: (val) => setState(() => _voicePersonaOptIn = val),
            title: const Text('Enable Voice Persona'),
            subtitle: const Text('Allow voice cloning for personalized narration (mock for MVP)'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _analyticsOptIn,
            onChanged: (val) => setState(() => _analyticsOptIn = val),
            title: const Text('Usage Analytics'),
            subtitle: const Text('Help improve the app with anonymous usage data'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your Privacy Matters',
                      style: context.textStyles.titleMedium?.bold.withColor(
                        Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'All data is stored locally on your device. You can export or delete everything anytime.',
                  style: context.textStyles.bodySmall?.withColor(
                    Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: AppSpacing.paddingMd,
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: AppSpacing.paddingMd,
                  ),
                  child: const Text('Start Journey'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
