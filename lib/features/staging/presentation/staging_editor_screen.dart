import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/media_service.dart';
import 'package:google_business_profile_manager/core/theme/app_theme.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

/// Full edit form for one staged catalog entry, including the explicit
/// "price verified" step that clears the amber AI-estimate warning.
class StagingEditorScreen extends ConsumerStatefulWidget {
  const StagingEditorScreen({required this.itemId, super.key});

  final int itemId;

  @override
  ConsumerState<StagingEditorScreen> createState() => _StagingEditorScreenState();
}

class _StagingEditorScreenState extends ConsumerState<StagingEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _currency = TextEditingController();
  final _language = TextEditingController();
  final _landingUrl = TextEditingController();

  StagingItem? _item;
  String _kind = 'product';
  bool _priceIsAiEstimate = true;
  String? _imagePath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final item = await ref.read(businessRepositoryProvider).getStagingItem(widget.itemId);
    if (item != null && mounted) {
      _item = item;
      _title.text = item.title;
      _category.text = item.category;
      _description.text = item.description;
      _price.text = item.priceAmount;
      _currency.text = item.currencyCode;
      _language.text = item.language;
      _landingUrl.text = item.landingUrl ?? '';
      _kind = item.kind;
      _priceIsAiEstimate = item.priceIsAiEstimate;
      _imagePath = item.imagePath;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final controller in [_title, _category, _description, _price, _currency, _language, _landingUrl]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage({bool camera = false}) async {
    final media = ref.read(mediaServiceProvider);
    final picked = await media.pickImage(fromCamera: camera);
    if (picked == null) return;
    final path = await media.persistImage(picked);
    if (mounted) setState(() => _imagePath = path);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await ref.read(businessRepositoryProvider).updateStagingItem(
            widget.itemId,
            StagingItemsCompanion(
              title: Value(_title.text.trim()),
              category: Value(_category.text.trim()),
              description: Value(_description.text.trim()),
              priceAmount: Value(_price.text.trim()),
              currencyCode: Value(_currency.text.trim().toUpperCase()),
              language: Value(_language.text.trim().toLowerCase()),
              landingUrl: Value(_landingUrl.text.trim().isEmpty ? null : _landingUrl.text.trim()),
              kind: Value(_kind),
              priceIsAiEstimate: Value(_priceIsAiEstimate),
              imagePath: Value(_imagePath),
            ),
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete staged entry?'),
        content: const Text('This only removes the local draft.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(businessRepositoryProvider).deleteStagingItem(widget.itemId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_item == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Entry no longer exists.')));
    }
    final media = ref.read(mediaServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit staged entry'),
        actions: [
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_item!.status == 'published')
              Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('Already published'),
                  subtitle: Text('Edits stay local; publishing again creates a new post.'),
                ),
              ),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: _imagePath == null || kIsWeb
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined, size: 48),
                            const SizedBox(height: 8),
                            Text('No photo yet', style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      )
                    : Image.file(File(_imagePath!), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose photo'),
                ),
                if (media.supportsCamera)
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(camera: true),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Take photo'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              maxLength: 58, // Google Product Editor name limit
              decoration: const InputDecoration(labelText: 'Product name *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'A product name is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _kind,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'product', child: Text('Product')),
                DropdownMenuItem(value: 'service', child: Text('Service')),
                DropdownMenuItem(value: 'offer', child: Text('Offer')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _kind = value ?? 'product'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 6,
              maxLength: 1000, // Google Product Editor description limit
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _landingUrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'Product landing page URL (optional)',
                hintText: 'Official brand page, Wikipedia, your web shop …',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                    onChanged: (_) {
                      // Touching the price counts as review — clear the flag.
                      if (_priceIsAiEstimate) setState(() => _priceIsAiEstimate = false);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _language,
                    decoration: const InputDecoration(labelText: 'Lang'),
                  ),
                ),
              ],
            ),
            if (_priceIsAiEstimate) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: aiEstimateBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: aiEstimateColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Color(0xFF92400E)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Estimated Price — Please Verify',
                            style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This is the typical local market price the AI estimated for your region — '
                      'not your price. Adjust it, or confirm it as-is. Unverified prices are never published.',
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => setState(() => _priceIsAiEstimate = false),
                      child: const Text('Price is correct — mark verified'),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: const Text('Save entry'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
