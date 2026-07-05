import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';

class StagingEditorScreen extends ConsumerWidget {
  const StagingEditorScreen({required this.product, super.key});

  final StagingProductData product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 16),
            Text('Est. USD: ${product.priceUsd}'),
            Text('Est. DOP: ${product.priceDop}'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.publish),
              label: const Text('Publish to GBP workflow'),
            ),
          ],
        ),
      ),
    );
  }
}
