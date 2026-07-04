import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/routing/app_router.dart';
import 'package:google_business_profile_manager/core/theme/app_theme.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = BusinessRepository();
  await repository.initialize();
  runApp(
    ProviderScope(
      overrides: [businessRepositoryProvider.overrideWithValue(repository)],
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
      title: 'Google Business Profile Manager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      routerConfig: router,
    );
  }
}
