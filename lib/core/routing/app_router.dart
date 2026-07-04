import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/presentation/business_detail_screen.dart';
import 'package:google_business_profile_manager/features/businesses/presentation/businesses_screen.dart';
import 'package:google_business_profile_manager/features/onboarding/presentation/onboarding_screen.dart';
import 'package:google_business_profile_manager/features/settings/presentation/settings_screen.dart';
import 'package:google_business_profile_manager/features/staging/presentation/staging_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/businesses/detail',
        builder: (context, state) {
          final business = state.extra as BusinessProfile?;
          return BusinessDetailScreen(business: business!);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ResponsiveShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/staging', builder: (context, state) => const StagingScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/assistant', builder: (context, state) => const AIAssistantScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: navigationShell.goBranch,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.business), label: Text('Businesses')),
                NavigationRailDestination(icon: Icon(Icons.inventory_2), label: Text('Staging')),
                NavigationRailDestination(icon: Icon(Icons.smart_toy), label: Text('AI')),
                NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
              ],
            ),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.business), label: 'Businesses'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Staging'),
          NavigationDestination(icon: Icon(Icons.smart_toy), label: 'AI'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
