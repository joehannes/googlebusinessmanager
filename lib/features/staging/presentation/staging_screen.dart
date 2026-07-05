import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ads_service.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';
import 'package:google_business_profile_manager/features/staging/data/staging_publisher.dart';
import 'package:google_business_profile_manager/shared/widgets/empty_state.dart';
import 'package:google_business_profile_manager/shared/widgets/price_chip.dart';

final stagingItemsProvider = StreamProvider.family<List<StagingItem>, int>((ref, businessId) {
  return ref.watch(businessRepositoryProvider).watchStagingItems(businessId);
});

/// Human-in-the-loop staging catalog: review AI drafts, verify prices,
/// then bulk-publish to the linked GBP location.
class StagingScreen extends ConsumerStatefulWidget {
  const StagingScreen({super.key});

  @override
  ConsumerState<StagingScreen> createState() => _StagingScreenState();
}

class _StagingScreenState extends ConsumerState<StagingScreen> {
  bool _publishing = false;

  Future<void> _publishAll(BusinessProfile business, List<StagingItem> items) async {
    setState(() => _publishing = true);
    try {
      final report = await ref.read(stagingPublisherProvider).publish(
            business: business,
            items: items,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(report.summary),
        duration: const Duration(seconds: 6),
      ));
      if (report.published > 0) {
        // High-value flow completed — show the (mobile-only) interstitial.
        ref.read(adsServiceProvider).maybeShowInterstitial();
      }
    } on GbpException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  Future<void> _addManually(BusinessProfile business) async {
    final id = await ref.read(businessRepositoryProvider).insertStagingItem(
          StagingItemsCompanion.insert(
            businessId: business.id,
            title: 'New entry',
          ),
        );
    if (mounted) context.push('/staging/editor/$id');
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(activeBusinessProvider);

    if (business == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Staging Catalog')),
        body: EmptyState(
          icon: Icons.inventory_2_outlined,
          title: 'No business selected',
          message: 'Create a business workspace first — staged catalog entries belong to a business.',
          action: FilledButton(
            onPressed: () => context.push('/businesses/new'),
            child: const Text('Create business'),
          ),
        ),
      );
    }

    final itemsAsync = ref.watch(stagingItemsProvider(business.id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Staging — ${business.name}'),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'staging-manual',
            tooltip: 'Add entry manually',
            onPressed: () => _addManually(business),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'staging-bulk',
            onPressed: () => context.push('/staging/bulk'),
            icon: const Icon(Icons.auto_awesome_motion),
            label: const Text('Bulk AI create'),
          ),
        ],
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            EmptyState(icon: Icons.error_outline, title: 'Could not load staging', message: '$error'),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.auto_awesome_motion,
              title: 'Staging catalog is empty',
              message: 'Use "Bulk AI create" to photograph or select up to 20 product images, '
                  'speak your instructions, and let the AI draft the whole catalog for review.',
            );
          }
          final drafts = items.where((item) => item.status != 'published').length;
          final unverified =
              items.where((item) => item.status != 'published' && item.priceIsAiEstimate && item.priceAmount.isNotEmpty).length;
          final ready = drafts - unverified;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        unverified > 0
                            ? '$drafts drafts • $unverified amber prices still need your verification'
                            : '$drafts drafts accepted',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: ready == 0 ? null : () => context.push('/staging/sync'),
                      icon: const Icon(Icons.storefront),
                      label: Text('Sync products${ready == 0 ? '' : ' ($ready)'}'),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'More actions',
                      enabled: !_publishing,
                      onSelected: (action) async {
                        switch (action) {
                          case 'verify-all':
                            await ref
                                .read(businessRepositoryProvider)
                                .verifyAllStagingPrices(business.id);
                            ref.invalidate(stagingItemsProvider(business.id));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('All draft prices marked as verified.')));
                            }
                          case 'publish-posts':
                            await _publishAll(business, items);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'verify-all',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.done_all),
                            title: Text('Accept all prices'),
                            subtitle: Text('Clear every amber AI-estimate flag'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'publish-posts',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.article_outlined),
                            title: Text('Publish as posts (API)'),
                            subtitle: Text('Automatic — appears as posts,\nnot in the Products tab'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _StagingCard(item: items[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StagingCard extends StatelessWidget {
  const _StagingCard({required this.item});

  final StagingItem item;

  @override
  Widget build(BuildContext context) {
    final published = item.status == 'published';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/staging/editor/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: item.imagePath == null || kIsWeb
                        ? const Icon(Icons.image_outlined, size: 40)
                        : Image.file(File(item.imagePath!), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Chip(
                      label: Text(published ? 'PUBLISHED' : item.kind.toUpperCase()),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: published
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surface,
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      label: Text(item.language.toUpperCase()),
                      visualDensity: VisualDensity.compact,
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 6),
                  PriceChip(
                    amount: item.priceAmount,
                    currencyCode: item.currencyCode,
                    isAiEstimate: item.priceIsAiEstimate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
