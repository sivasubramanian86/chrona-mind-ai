import 'package:go_router/go_router.dart';
import 'package:chronamindai/services/storage_service.dart';
import 'package:chronamindai/screens/onboarding_screen.dart';
import 'package:chronamindai/screens/home_timeline_screen.dart';
import 'package:chronamindai/screens/memory_detail_screen.dart';
import 'package:chronamindai/screens/digest_screen.dart';
import 'package:chronamindai/screens/digest_detail_screen.dart';
import 'package:chronamindai/screens/simulator_screen.dart';
import 'package:chronamindai/screens/simulator_detail_screen.dart';
import 'package:chronamindai/screens/settings_screen.dart';
import 'package:chronamindai/screens/main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final isOnboarded = StorageService.isOnboardingComplete();
      final isOnOnboarding = state.uri.path == AppRoutes.onboarding;

      if (!isOnboarded && !isOnOnboarding) {
        return AppRoutes.onboarding;
      }
      
      if (isOnboarded && isOnOnboarding) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => NoTransitionPage(
          child: const OnboardingScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const HomeTimelineScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.digest,
            name: 'digest',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const DigestScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.simulator,
            name: 'simulator',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SimulatorScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.memory}/:id',
        name: 'memory-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MemoryDetailScreen(memoryId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.digest}/:id',
        name: 'digest-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DigestDetailScreen(digestId: id);
        },
      ),
      GoRoute(
        path: '${AppRoutes.simulator}/:id',
        name: 'simulator-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SimulatorDetailScreen(simulationId: id);
        },
      ),
    ],
  );
}

class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String memory = '/memory';
  static const String digest = '/digest';
  static const String simulator = '/simulator';
  static const String settings = '/settings';
}
