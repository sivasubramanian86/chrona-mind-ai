import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/digest')) {
      return 1;
    }
    if (location.startsWith('/simulator')) {
      return 2;
    }
    if (location.startsWith('/settings')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/digest');
        break;
      case 2:
        context.go('/simulator');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/nav_home_icon.png',
              width: 24,
              height: 24,
              color: selectedIndex == 0
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  color: selectedIndex == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                );
              },
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/nav_digest_icon.png',
              width: 24,
              height: 24,
              color: selectedIndex == 1
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  selectedIndex == 1 ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                  color: selectedIndex == 1
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                );
              },
            ),
            label: 'Digest',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/nav_simulator_icon.png',
              width: 24,
              height: 24,
              color: selectedIndex == 2
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  selectedIndex == 2 ? Icons.account_tree : Icons.account_tree_outlined,
                  color: selectedIndex == 2
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                );
              },
            ),
            label: 'Simulator',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/icons/nav_settings_icon.png',
              width: 24,
              height: 24,
              color: selectedIndex == 3
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  selectedIndex == 3 ? Icons.settings : Icons.settings_outlined,
                  color: selectedIndex == 3
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                );
              },
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
