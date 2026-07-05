import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/gbp_import_service.dart';
import 'package:google_business_profile_manager/shared/widgets/empty_state.dart';

/// Workspace overview: one card per managed business.google.com entry.
/// Tapping a card selects it as the active workspace and opens the detail.
class BusinessesScreen extends ConsumerStatefulWidget {
  const BusinessesScreen({super.key});

  @override
  ConsumerState<BusinessesScreen> createState() => _BusinessesScreenState();
}

class _BusinessesScreenState extends ConsumerState<BusinessesScreen> {
  bool _importing = false;

  Future<void> _importFromGoogle() async {
    setState(() => _importing = true);
    try {
      final result = await ref.read(gbpImportServiceProvider).connectAndImport();
      _toast(result.imported > 0
          ? 'Imported ${result.imported} business${result.imported == 1 ? '' : 'es'} from Google'
              '${result.skipped > 0 ? ' (${result.skipped} already here)' : ''}.'
          : 'All ${result.total} Google listing${result.total == 1 ? ' is' : 's are'} already imported.');
    } on GbpException catch (error) {
      _toast(error.message);
    } catch (error) {
      _toast('Google import failed: $error');
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final businesses = ref.watch(businessesProvider);
    final active = ref.watch(activeBusinessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Profiles'),
        actions: [
          IconButton(
            tooltip: 'Import my businesses from Google',
            onPressed: _importing ? null : _importFromGoogle,
            icon: _importing
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_download_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-business',
        onPressed: () => context.push('/businesses/new'),
        icon: const Icon(Icons.add_business),
        label: const Text('Add business'),
      ),
      body: businesses.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No businesses yet',
              message: 'Import your listings from Google (cloud icon above) or create '
                  'your first workspace to start managing a Google Business Profile '
                  'with AI assistance.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final business = items[index];
              final isActive = business.id == active?.id;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(business.name.isEmpty ? '?' : business.name[0].toUpperCase()),
                  ),
                  title: Text(business.name),
                  subtitle: Text(
                    [business.category, business.address]
                        .where((part) => part.isNotEmpty)
                        .join(' • '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isActive
                      ? Chip(
                          label: const Text('Active'),
                          avatar: Icon(Icons.check_circle,
                              color: Theme.of(context).colorScheme.secondary, size: 18),
                          visualDensity: VisualDensity.compact,
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(activeBusinessIdProvider.notifier).select(business.id);
                    context.push('/businesses/${business.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load businesses',
          message: '$error',
        ),
      ),
    );
  }
}
