import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/utils/whatsapp.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';
import 'package:google_business_profile_manager/features/location/presentation/location_picker_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

/// Create/edit form for a business workspace: identity, smart contact
/// (country-aware phone → auto wa.me link), map-pinned coordinates,
/// languages and audience for AI content.
class BusinessEditScreen extends ConsumerStatefulWidget {
  const BusinessEditScreen({this.businessId, super.key});

  final int? businessId;

  @override
  ConsumerState<BusinessEditScreen> createState() => _BusinessEditScreenState();
}

class _BusinessEditScreenState extends ConsumerState<BusinessEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _description = TextEditingController();
  final _address = TextEditingController();
  final _website = TextEditingController();
  final _email = TextEditingController();
  final _notes = TextEditingController();
  final _audience = TextEditingController();

  static const _languageChoices = ['en', 'es', 'fr', 'de', 'pt', 'it', 'nl'];
  final Set<String> _languages = {'en'};

  String _phoneIso = 'US';
  String _phoneNumber = '';
  LatLng? _coordinates;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => widget.businessId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.businessId;
    if (id != null) {
      final business = await ref.read(businessRepositoryProvider).getBusiness(id);
      if (business != null && mounted) {
        _name.text = business.name;
        _category.text = business.category;
        _description.text = business.description;
        _address.text = business.address;
        _website.text = business.website ?? '';
        _email.text = business.email ?? '';
        _notes.text = business.notes ?? '';
        _audience.text = business.targetAudience ?? '';
        _phoneIso = business.phoneCountryIso ?? 'US';
        _phoneNumber = business.phoneNumber ?? '';
        _languages
          ..clear()
          ..addAll(business.languages.split(',').where((code) => code.isNotEmpty));
        if (_languages.isEmpty) _languages.add('en');
        if (business.latitude != null && business.longitude != null) {
          _coordinates = LatLng(business.latitude!, business.longitude!);
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    for (final controller in [_name, _category, _description, _address, _website, _email, _notes, _audience]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final picked = await context.push<LatLng>(
      '/location-picker',
      extra: LocationPickerArgs(point: _coordinates, title: 'Pin ${_name.text.isEmpty ? 'the business' : _name.text}'),
    );
    if (picked != null && mounted) {
      setState(() => _coordinates = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repository = ref.read(businessRepositoryProvider);
    final waLink = whatsappLinkFor(_phoneNumber);
    final entry = BusinessProfilesCompanion(
      name: Value(_name.text.trim()),
      category: Value(_category.text.trim()),
      description: Value(_description.text.trim()),
      address: Value(_address.text.trim()),
      latitude: Value(_coordinates?.latitude),
      longitude: Value(_coordinates?.longitude),
      phoneCountryIso: Value(_phoneIso),
      phoneNumber: Value(_phoneNumber.isEmpty ? null : _phoneNumber),
      whatsappLink: Value(waLink),
      website: Value(_website.text.trim().isEmpty ? null : _website.text.trim()),
      email: Value(_email.text.trim().isEmpty ? null : _email.text.trim()),
      notes: Value(_notes.text.trim().isEmpty ? null : _notes.text.trim()),
      languages: Value(_languages.join(',')),
      targetAudience: Value(_audience.text.trim().isEmpty ? null : _audience.text.trim()),
    );

    try {
      if (_isEditing) {
        await repository.updateBusiness(widget.businessId!, entry);
      } else {
        final id = await repository.insertBusiness(entry);
        ref.read(activeBusinessIdProvider.notifier).select(id);
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final waLink = whatsappLinkFor(_phoneNumber);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit business' : 'New business')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Business name *'),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Please enter the business name' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Real Estate, Tourism, Restaurant',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What does this business offer?',
              ),
            ),
            const SizedBox(height: 24),
            Text('Smart contact', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            IntlPhoneField(
              // With an existing "+…" number the widget derives the country
              // itself; otherwise preselect the stored/default country.
              initialCountryCode: _phoneNumber.isEmpty ? _phoneIso : null,
              initialValue: _phoneNumber.isEmpty ? null : _phoneNumber,
              disableLengthCheck: true, // phone stays optional
              decoration: const InputDecoration(
                labelText: 'Business phone / mobile',
                helperText: 'Pick the country for the right prefix — WhatsApp link is derived automatically',
              ),
              onChanged: (phone) => setState(() {
                _phoneIso = phone.countryISOCode;
                _phoneNumber = phone.number.isEmpty ? '' : phone.completeNumber;
              }),
            ),
            if (waLink != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    avatar: const Icon(Icons.chat, size: 18, color: Color(0xFF25D366)),
                    label: Text(waLink.replaceFirst('https://', '')),
                    tooltip: 'WhatsApp chat link — created automatically from the phone number. Tap to test.',
                    onPressed: () => launchUrl(Uri.parse(waLink), mode: LaunchMode.externalApplication),
                  ),
                ),
              ),
            TextFormField(
              controller: _website,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'Website', hintText: 'https://…'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            Text('Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _address,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street, city, country — also used as AI pricing context',
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(
                  _coordinates == null ? Icons.location_off_outlined : Icons.location_on,
                  color: _coordinates == null ? null : Theme.of(context).colorScheme.secondary,
                ),
                title: Text(_coordinates == null
                    ? 'No map position yet'
                    : 'Pinned: ${_coordinates!.latitude.toStringAsFixed(5)}, ${_coordinates!.longitude.toStringAsFixed(5)}'),
                subtitle: const Text('Free OpenStreetMap — no API key needed'),
                trailing: FilledButton.tonalIcon(
                  onPressed: _pickLocation,
                  icon: const Icon(Icons.map),
                  label: Text(_coordinates == null ? 'Pin on map' : 'Move pin'),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('AI content preferences', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('Languages the AI should produce descriptions and posts in:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final code in _languageChoices)
                  FilterChip(
                    label: Text(code.toUpperCase()),
                    selected: _languages.contains(code),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _languages.add(code);
                      } else if (_languages.length > 1) {
                        _languages.remove(code);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _audience,
              decoration: const InputDecoration(
                labelText: 'Typical customers / target audience',
                hintText: 'e.g. American and European investors, families on vacation',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notes & goals'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Save changes' : 'Create business'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
