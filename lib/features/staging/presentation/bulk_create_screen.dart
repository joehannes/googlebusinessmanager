import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/core/services/location_service.dart';
import 'package:google_business_profile_manager/core/services/media_service.dart';
import 'package:google_business_profile_manager/core/services/speech_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';
import 'package:google_business_profile_manager/shared/widgets/empty_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

/// Flagship bulk-creation engine: select up to 20 product photos, speak
/// (or type) one instruction, and the AI drafts a full staging catalog —
/// titles, SEO descriptions, categories and local price estimations in
/// every configured language.
class BulkCreateScreen extends ConsumerStatefulWidget {
  const BulkCreateScreen({super.key});

  @override
  ConsumerState<BulkCreateScreen> createState() => _BulkCreateScreenState();
}

class _BulkCreateScreenState extends ConsumerState<BulkCreateScreen> {
  final _intent = TextEditingController();
  final List<XFile> _images = [];

  bool _listening = false;
  bool _processing = false;
  int _done = 0;
  final List<String> _errors = [];

  @override
  void dispose() {
    _intent.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final remaining = 20 - _images.length;
    if (remaining <= 0) return;
    final picked = await ref.read(mediaServiceProvider).pickMultipleImages(limit: remaining);
    if (picked.isNotEmpty && mounted) {
      setState(() => _images.addAll(picked));
    }
  }

  Future<void> _toggleMic() async {
    final speech = ref.read(speechServiceProvider);
    if (_listening) {
      await speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final started = await speech.start((transcript) {
      if (mounted) setState(() => _intent.text = transcript);
    });
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Voice input is not available on this device — just type your instruction.'),
      ));
      return;
    }
    setState(() => _listening = true);
  }

  Future<void> _process(BusinessProfile business) async {
    final ai = ref.read(aiServiceProvider);
    if (!ai.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add your free AI key in Settings first (Gemini or OpenRouter/Qwen).'),
      ));
      return;
    }
    final speech = ref.read(speechServiceProvider);
    await speech.stop();

    setState(() {
      _processing = true;
      _listening = false;
      _done = 0;
      _errors.clear();
    });

    // Location context makes price estimations local instead of global.
    var locationContext = business.address;
    if (locationContext.isEmpty && business.latitude != null && business.longitude != null) {
      locationContext = await ref
              .read(locationServiceProvider)
              .reverseLookup(LatLng(business.latitude!, business.longitude!)) ??
          '';
    }
    final languages =
        business.languages.split(',').where((code) => code.isNotEmpty).toList();

    final media = ref.read(mediaServiceProvider);
    final repository = ref.read(businessRepositoryProvider);

    for (final image in List.of(_images)) {
      try {
        final bytes = await image.readAsBytes();
        // Re-read before each image so categories created earlier in this
        // batch are already offered for reuse on the next one.
        final categories = await repository.stagingCategories(business.id);
        final drafts = await ai.analyzeProductImage(
          imageBytes: bytes,
          mimeType: _mimeFor(image.name),
          intent: _intent.text.trim(),
          locationContext: locationContext.isEmpty ? null : locationContext,
          languages: languages.isEmpty ? const ['en'] : languages,
          existingCategories: categories,
        );
        final persistedPath = await media.persistImage(image);
        await repository.insertStagingItems([
          for (final draft in drafts)
            StagingItemsCompanion.insert(
              businessId: business.id,
              title: draft.title,
              kind: Value(draft.kind),
              category: Value(draft.category),
              description: Value(draft.description),
              language: Value(draft.language),
              priceAmount: Value(draft.priceAmount),
              currencyCode: Value(draft.currencyCode),
              priceIsAiEstimate: const Value(true),
              landingUrl: Value(draft.landingUrl.isEmpty ? null : draft.landingUrl),
              imagePath: Value(persistedPath),
              source: Value(ai.sourceTag),
            ),
        ]);
      } catch (error) {
        _errors.add('${image.name}: $error');
      }
      if (!mounted) return;
      setState(() => _done++);
    }

    if (!mounted) return;
    setState(() => _processing = false);
    final failed = _errors.length;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(failed == 0
          ? 'Catalog drafted! Review titles and amber prices in Staging before publishing.'
          : 'Drafted with $failed of ${_images.length} images failing — see details below.'),
    ));
    if (failed == 0) {
      context.go('/staging');
    }
  }

  String _mimeFor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(activeBusinessProvider);
    if (business == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bulk AI create')),
        body: EmptyState(
          icon: Icons.storefront_outlined,
          title: 'No business selected',
          message: 'Create or select a business workspace first.',
          action: FilledButton(
            onPressed: () => context.push('/businesses/new'),
            child: const Text('Create business'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bulk AI create')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Drafting for ${business.name}'),
              subtitle: Text(
                'Languages: ${business.languages.toUpperCase()}'
                '${business.address.isEmpty ? '' : ' • Pricing context: ${business.address}'}',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('1. Product photos (${_images.length}/20)',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (_images.isNotEmpty)
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = _images[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kIsWeb
                            ? Container(
                                width: 96,
                                height: 96,
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.image_outlined),
                              )
                            : Image.file(File(image.path), width: 96, height: 96, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _processing ? null : () => setState(() => _images.removeAt(index)),
                          child: const CircleAvatar(radius: 12, child: Icon(Icons.close, size: 14)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _processing || _images.length >= 20 ? null : _pickImages,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_images.isEmpty ? 'Select up to 20 images' : 'Add more images'),
          ),
          const SizedBox(height: 24),
          Text('2. Tell the AI what these are', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Example: "These are new beachfront rental properties. Target American and European '
            'investors. Generate descriptions in English and Spanish. Set prices based on typical '
            'seasonal rates."',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _intent,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Voice or typed instruction',
              suffixIcon: IconButton(
                tooltip: _listening ? 'Stop recording' : 'Speak the instruction',
                icon: Icon(_listening ? Icons.stop_circle : Icons.mic,
                    color: _listening ? Colors.red : null),
                onPressed: _processing ? null : _toggleMic,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_processing) ...[
            LinearProgressIndicator(value: _images.isEmpty ? null : _done / _images.length),
            const SizedBox(height: 8),
            Text('Processing image $_done of ${_images.length} — requests are paced to respect '
                'your free AI tier, so this can take a moment.'),
            const SizedBox(height: 16),
          ],
          if (_errors.isNotEmpty)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Issues', style: Theme.of(context).textTheme.titleSmall),
                    for (final error in _errors)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(error, style: Theme.of(context).textTheme.bodySmall),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _processing || _images.isEmpty ? null : () => _process(business),
            icon: _processing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_processing ? 'Drafting catalog…' : 'Draft catalog with AI'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
