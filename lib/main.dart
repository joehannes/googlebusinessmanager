import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/routing/app_router.dart';
import 'package:google_business_profile_manager/core/services/ads_service.dart';
import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:google_business_profile_manager/core/theme/app_theme.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyStore = await KeyStoreService.create();
  final repository = BusinessRepository();
  final ads = AdsService();
  // Fire and forget: ad SDK warm-up must never block first frame.
  ads.initialize();

  runApp(
    ProviderScope(
      overrides: [
        keyStoreProvider.overrideWithValue(keyStore),
        businessRepositoryProvider.overrideWithValue(repository),
        adsServiceProvider.overrideWithValue(ads),
      ],
      child: const GBPApp(),
    ),
  );
}

class GBPApp extends ConsumerWidget {
  const GBPApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Business Profile Manager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
