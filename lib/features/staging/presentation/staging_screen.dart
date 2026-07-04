import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

final stagingProductsProvider = FutureProvider<List<StagingProductData>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.fetchStagingProducts();
});

class StagingScreen extends ConsumerWidget {
  const StagingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(stagingProductsProvider);
    final activeBusinessId = ref.watch(activeBusinessIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk Staging Catalog')),
      body: products.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = items[index];
            final isVisible = activeBusinessId == null || product.businessId == activeBusinessId;
            if (!isVisible) {
              return const SizedBox.shrink();
            }
            return Card(
              child: ListTile(
                title: Text(product.title),
                subtitle: Text(product.description),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(product.priceUsd),
                    Text(product.priceDop),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
