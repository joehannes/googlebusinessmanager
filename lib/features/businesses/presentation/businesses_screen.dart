import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

final businessesProvider = StreamProvider<List<BusinessProfile>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.watchBusinesses();
});

class BusinessesScreen extends ConsumerWidget {
  const BusinessesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business Profiles')),
      body: businesses.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final business = items[index];
            return Card(
              child: ListTile(
                title: Text(business.name),
                subtitle: Text('${business.category} • ${business.location}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
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
