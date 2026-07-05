import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:google_business_profile_manager/features/ai_assistant/presentation/ai_assistant_screen.dart';
import 'package:google_business_profile_manager/features/businesses/presentation/business_detail_screen.dart';
import 'package:google_business_profile_manager/features/businesses/presentation/business_edit_screen.dart';
import 'package:google_business_profile_manager/features/businesses/presentation/businesses_screen.dart';
import 'package:google_business_profile_manager/features/location/presentation/location_picker_screen.dart';
import 'package:google_business_profile_manager/features/onboarding/presentation/onboarding_screen.dart';
import 'package:google_business_profile_manager/features/posts/presentation/post_editor_screen.dart';
import 'package:google_business_profile_manager/features/posts/presentation/posts_screen.dart';
import 'package:google_business_profile_manager/features/settings/presentation/settings_screen.dart';
import 'package:google_business_profile_manager/features/staging/presentation/bulk_create_screen.dart';
import 'package:google_business_profile_manager/features/staging/presentation/product_sync_screen.dart';
import 'package:google_business_profile_manager/features/staging/presentation/staging_editor_screen.dart';
import 'package:google_business_profile_manager/features/staging/presentation/staging_screen.dart';
import 'package:google_business_profile_manager/shared/widgets/ad_banner.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final keyStore = ref.watch(keyStoreProvider);
  return GoRouter(
    initialLocation: keyStore.onboardingCompleted ? '/businesses' : '/onboarding',
    redirect: (context, state) {
      final completed = keyStore.onboardingCompleted;
      if (!completed && state.matchedLocation != '/onboarding') return '/onboarding';
      if (completed && state.matchedLocation == '/onboarding') return '/businesses';
      return null;
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(
        path: '/businesses/new',
        builder: (context, state) => const BusinessEditScreen(),
      ),
      GoRoute(
        path: '/businesses/:id/edit',
        builder: (context, state) =>
            BusinessEditScreen(businessId: int.tryParse(state.pathParameters['id'] ?? '')),
      ),
      GoRoute(
        path: '/businesses/:id',
        builder: (context, state) =>
            BusinessDetailScreen(businessId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/staging/bulk',
        builder: (context, state) => const BulkCreateScreen(),
      ),
      GoRoute(
        path: '/staging/sync',
        builder: (context, state) => const ProductSyncScreen(),
      ),
      GoRoute(
        path: '/staging/editor/:id',
        builder: (context, state) =>
            StagingEditorScreen(itemId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/posts/editor/:id',
        builder: (context, state) =>
            PostEditorScreen(postId: int.parse(state.pathParameters['id']!)),
      ),
      // Full-screen map picker; pops with the chosen LatLng.
      GoRoute(
        path: '/location-picker',
        builder: (context, state) => LocationPickerScreen(
          initial: state.extra is LocationPickerArgs ? state.extra as LocationPickerArgs : null,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ResponsiveShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/businesses', builder: (context, state) => const BusinessesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/staging', builder: (context, state) => const StagingScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/posts', builder: (context, state) => const PostsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/assistant', builder: (context, state) => const AIAssistantScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});

/// Bottom navigation on phones, persistent rail on wide screens, with the
/// (mobile-only) ad banner at the top of the shell.
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (icon: Icons.business_outlined, selected: Icons.business, label: 'Businesses'),
    (icon: Icons.inventory_2_outlined, selected: Icons.inventory_2, label: 'Staging'),
    (icon: Icons.article_outlined, selected: Icons.article, label: 'Posts'),
    (icon: Icons.smart_toy_outlined, selected: Icons.smart_toy, label: 'AI'),
    (icon: Icons.settings_outlined, selected: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (isWide) {
      return Scaffold(
        body: Column(
          children: [
            const AdBanner(),
            Expanded(
              child: Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: navigationShell.goBranch,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selected),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          const AdBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selected),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
