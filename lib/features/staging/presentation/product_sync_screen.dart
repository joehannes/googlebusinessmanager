import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ads_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';
import 'package:google_business_profile_manager/shared/widgets/empty_state.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

/// Guided one-by-one sync of accepted catalog entries into the Google
/// Business Profile **Product Editor**.
///
/// Google exposes no public API for the Products tab (verified July 2026),
/// and scripting the web UI would violate their ToS — so this assistant does
/// the next best thing: it walks every accepted product, offers one-tap copy
/// for each field (limits match the editor: name ≤58, description ≤1000),
/// opens business.google.com for you, and tracks what's already synced.
class ProductSyncScreen extends ConsumerStatefulWidget {
  const ProductSyncScreen({super.key});

  @override
  ConsumerState<ProductSyncScreen> createState() => _ProductSyncScreenState();
}

class _ProductSyncScreenState extends ConsumerState<ProductSyncScreen> {
  List<StagingItem> _queue = const [];
  int _index = 0;
  int _synced = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final business = ref.read(activeBusinessProvider);
    if (business == null) {
      setState(() => _loading = false);
      return;
    }
    final all = await ref
        .read(businessRepositoryProvider)
        .watchStagingItems(business.id)
        .first;
    // Only accepted entries: drafts whose price is verified (or price-less).
    _queue = all
        .where((item) =>
            item.status == 'draft' &&
            (!item.priceIsAiEstimate || item.priceAmount.isEmpty))
        .toList();
    if (mounted) setState(() => _loading = false);
  }

  StagingItem? get _current => _index < _queue.length ? _queue[_index] : null;

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('$label copied to clipboard'),
          duration: const Duration(seconds: 1),
        ));
    }
  }

  Future<void> _openProductEditor() async {
    await launchUrl(Uri.parse('https://business.google.com/'),
        mode: LaunchMode.externalApplication);
  }

  Future<void> _revealPhoto(StagingItem item) async {
    final path = item.imagePath;
    if (path == null) return;
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS ||
            defaultTargetPlatform == TargetPlatform.windows)) {
      // Open the containing folder so the photo can be drag-&-dropped into
      // the "Drag a photo here" zone of the Product Editor.
      await launchUrl(Uri.file(p.dirname(path)));
    } else {
      _copy('Photo path', path);
    }
  }

  Future<void> _markSyncedAndNext() async {
    final item = _current;
    if (item == null) return;
    await ref.read(businessRepositoryProvider).updateStagingItem(
          item.id,
          const StagingItemsCompanion(status: Value('published')),
        );
    _synced++;
    _advance();
  }

  void _advance() {
    if (_index + 1 >= _queue.length) {
      // Whole batch handled — high-value flow completed.
      if (_synced > 0) ref.read(adsServiceProvider).maybeShowInterstitial();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$_synced of ${_queue.length} products synced to your Business Profile.'),
        duration: const Duration(seconds: 5),
      ));
      context.pop();
      return;
    }
    setState(() => _index++);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final item = _current;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sync products')),
        body: const EmptyState(
          icon: Icons.rule,
          title: 'Nothing ready to sync',
          message: 'Accept your drafts first: open each entry in the staging catalog and verify '
              'its amber AI price (or clear it). Verified entries appear here.',
        ),
      );
    }

    final fields = <(String, String)>[
      ('Product name', item.title),
      ('Category', item.category),
      if (item.priceAmount.isNotEmpty) ('Price (${item.currencyCode})', item.priceAmount),
      ('Description', item.description),
      if (item.landingUrl != null && item.landingUrl!.isNotEmpty)
        ('Landing page URL', item.landingUrl!),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Sync product ${_index + 1} of ${_queue.length}')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: theme.colorScheme.secondaryContainer,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Google offers no public API for the Products tab, so this assistant guides '
                    'you through business.google.com → "Edit products" → "Add product": copy each '
                    'field below, drop the photo in, hit Publish there, then mark it done here.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (item.imagePath != null && !kIsWeb)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 3,
                        child: Image.file(File(item.imagePath!), fit: BoxFit.cover),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.folder_open),
                        title: const Text('Reveal photo for drag & drop'),
                        subtitle: Text(item.imagePath!,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => _revealPhoto(item),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    for (final (label, value) in fields)
                      ListTile(
                        title: Text(label, style: theme.textTheme.labelMedium),
                        subtitle: Text(value, maxLines: 4, overflow: TextOverflow.ellipsis),
                        trailing: IconButton(
                          tooltip: 'Copy $label',
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () => _copy(label, value),
                        ),
                        onTap: () => _copy(label, value),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: _openProductEditor,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open business.google.com (Edit products)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _advance,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _markSyncedAndNext,
                      icon: const Icon(Icons.check),
                      label: const Text('Added on Google — next'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
