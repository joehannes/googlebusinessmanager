import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';
import 'package:google_business_profile_manager/features/staging/presentation/staging_screen.dart';
import 'package:google_business_profile_manager/shared/widgets/empty_state.dart';

final postsProvider = StreamProvider.family<List<BusinessPost>, int>((ref, businessId) {
  return ref.watch(businessRepositoryProvider).watchPosts(businessId);
});

/// Blog / GBP post drafts: generate with AI (per product, per category, or
/// free-form specs), edit locally, publish to the linked location.
class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  bool _generating = false;

  Future<void> _generate(BusinessProfile business) async {
    final ai = ref.read(aiServiceProvider);
    if (!ai.isConfigured) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Add your free AI key in Settings first (Gemini or OpenRouter/Qwen).'),
      ));
      return;
    }

    final stagingItems = ref.read(stagingItemsProvider(business.id)).valueOrNull ?? const [];
    final request = await showDialog<_PostRequest>(
      context: context,
      builder: (context) => _GeneratePostsDialog(business: business, stagingItems: stagingItems),
    );
    if (request == null || !mounted) return;

    setState(() => _generating = true);
    try {
      final businessContext = [
        business.name,
        if (business.category.isNotEmpty) 'Category: ${business.category}',
        if (business.description.isNotEmpty) business.description,
        if (business.address.isNotEmpty) 'Located in ${business.address}',
        if (business.targetAudience != null) 'Audience: ${business.targetAudience}',
      ].join('. ');

      final drafts = await ai.draftPosts(
        businessContext: businessContext,
        specs: request.specs,
        productTitles: request.productTitles,
        languages: business.languages.split(',').where((code) => code.isNotEmpty).toList(),
      );

      final repository = ref.read(businessRepositoryProvider);
      for (final draft in drafts) {
        await repository.insertPost(BusinessPostsCompanion.insert(
          businessId: business.id,
          title: draft.title,
          body: draft.body,
          language: Value(draft.language),
          topicType: Value(draft.topicType),
          source: Value(ai.sourceTag),
        ));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${drafts.length} post drafts created — review and publish when ready.'),
        ));
      }
    } on AiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(activeBusinessProvider);
    if (business == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts')),
        body: EmptyState(
          icon: Icons.article_outlined,
          title: 'No business selected',
          message: 'Create a business workspace first — posts belong to a business.',
          action: FilledButton(
            onPressed: () => context.push('/businesses/new'),
            child: const Text('Create business'),
          ),
        ),
      );
    }

    final postsAsync = ref.watch(postsProvider(business.id));

    return Scaffold(
      appBar: AppBar(title: Text('Posts — ${business.name}')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'generate-posts',
        onPressed: _generating ? null : () => _generate(business),
        icon: _generating
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.auto_awesome),
        label: Text(_generating ? 'Generating…' : 'Generate with AI'),
      ),
      body: postsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            EmptyState(icon: Icons.error_outline, title: 'Could not load posts', message: '$error'),
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(
              icon: Icons.article_outlined,
              title: 'No posts yet',
              message: 'Let the AI draft "What\'s new" posts and blog updates for your most '
                  'important products and categories — you review every word before publishing.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              final published = post.status == 'published';
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(published ? Icons.check : Icons.edit_note),
                  ),
                  title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    '${post.language.toUpperCase()} • ${post.topicType} • '
                    '${published ? 'published' : 'draft'}\n${post.body}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  onTap: () => context.push('/posts/editor/${post.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PostRequest {
  const _PostRequest({required this.specs, required this.productTitles});
  final String specs;
  final List<String> productTitles;
}

class _GeneratePostsDialog extends StatefulWidget {
  const _GeneratePostsDialog({required this.business, required this.stagingItems});

  final BusinessProfile business;
  final List<StagingItem> stagingItems;

  @override
  State<_GeneratePostsDialog> createState() => _GeneratePostsDialogState();
}

class _GeneratePostsDialogState extends State<_GeneratePostsDialog> {
  final _specs = TextEditingController();
  final Set<String> _selectedTitles = {};

  @override
  void dispose() {
    _specs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Offer each distinct staged product/category once.
    final titles = {for (final item in widget.stagingItems) item.title}.toList();

    return AlertDialog(
      title: const Text('Generate posts'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _specs,
                maxLines: 4,
                onChanged: (_) => setState(() {}), // re-evaluate Generate button
                decoration: const InputDecoration(
                  labelText: 'Specifications, wishes, goals',
                  hintText: 'e.g. Weekly what\'s-new post about our sunset cruise, friendly tone, '
                      'aimed at couples, include a call to book early',
                ),
              ),
              if (titles.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Write one post per selected product:',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final title in titles)
                      FilterChip(
                        label: Text(title, overflow: TextOverflow.ellipsis),
                        selected: _selectedTitles.contains(title),
                        onSelected: (selected) => setState(() {
                          selected ? _selectedTitles.add(title) : _selectedTitles.remove(title);
                        }),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _specs.text.trim().isEmpty && _selectedTitles.isEmpty
              ? null
              : () => Navigator.pop(
                    context,
                    _PostRequest(
                      specs: _specs.text.trim().isEmpty
                          ? 'Engaging update posts for the business'
                          : _specs.text.trim(),
                      productTitles: _selectedTitles.toList(),
                    ),
                  ),
          child: const Text('Generate'),
        ),
      ],
    );
  }
}
