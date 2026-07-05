import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ads_service.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

/// Edit one drafted post, ask the AI for rewrites/translations, and
/// publish it to the linked GBP location.
class PostEditorScreen extends ConsumerStatefulWidget {
  const PostEditorScreen({required this.postId, super.key});

  final int postId;

  @override
  ConsumerState<PostEditorScreen> createState() => _PostEditorScreenState();
}

class _PostEditorScreenState extends ConsumerState<PostEditorScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _language = TextEditingController();

  BusinessPost? _post;
  String _topicType = 'STANDARD';
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final post = await ref.read(businessRepositoryProvider).getPost(widget.postId);
    if (post != null && mounted) {
      _post = post;
      _title.text = post.title;
      _body.text = post.body;
      _language.text = post.language;
      _topicType = post.topicType;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _language.dispose();
    super.dispose();
  }

  Future<void> _save({bool pop = true}) async {
    await ref.read(businessRepositoryProvider).updatePost(
          widget.postId,
          BusinessPostsCompanion(
            title: Value(_title.text.trim()),
            body: Value(_body.text.trim()),
            language: Value(_language.text.trim().toLowerCase()),
            topicType: Value(_topicType),
          ),
        );
    if (pop && mounted) context.pop();
  }

  Future<void> _aiRewrite() async {
    final instruction = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Ask the AI to rework this post'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Translate to Spanish / make it shorter and friendlier',
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Rework'),
            ),
          ],
        );
      },
    );
    if (instruction == null || instruction.trim().isEmpty || !mounted) return;

    setState(() => _busy = true);
    try {
      final rewritten = await ref.read(aiServiceProvider).rewrite(
            text: '${_title.text}\n\n${_body.text}',
            instruction: instruction,
          );
      final lines = rewritten.trim().split('\n');
      if (mounted && lines.isNotEmpty) {
        setState(() {
          _title.text = lines.first.replaceAll(RegExp(r'^#+\s*'), '').trim();
          _body.text = lines.skip(1).join('\n').trim();
        });
      }
    } on AiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish() async {
    final post = _post;
    if (post == null) return;
    final business = await ref.read(businessRepositoryProvider).getBusiness(post.businessId);
    if (business == null || !mounted) return;
    if (business.gbpAccountName == null || business.gbpLocationName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Link this business to a GBP location first (business detail → Connect & link).'),
      ));
      return;
    }

    setState(() => _busy = true);
    try {
      await _save(pop: false);
      await ref.read(gbpApiServiceProvider).publishLocalPost(
            accountName: business.gbpAccountName!,
            locationName: business.gbpLocationName!,
            summary: '${_title.text.trim()}\n\n${_body.text.trim()}',
            topicType: _topicType,
            languageCode: _language.text.trim().toLowerCase(),
            ctaUrl: business.website,
          );
      await ref.read(businessRepositoryProvider).updatePost(
            widget.postId,
            const BusinessPostsCompanion(status: Value('published')),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post published to your Business Profile.')));
        ref.read(adsServiceProvider).maybeShowInterstitial();
        context.pop();
      }
    } on GbpException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete post draft?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(businessRepositoryProvider).deletePost(widget.postId);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_post == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Post no longer exists.')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit post'),
        actions: [
          IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            maxLines: 12,
            decoration: const InputDecoration(labelText: 'Post body'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _topicType,
                  decoration: const InputDecoration(labelText: 'Post type'),
                  items: const [
                    DropdownMenuItem(value: 'STANDARD', child: Text("What's new")),
                    DropdownMenuItem(value: 'OFFER', child: Text('Offer')),
                    DropdownMenuItem(value: 'EVENT', child: Text('Event')),
                  ],
                  onChanged: (value) => setState(() => _topicType = value ?? 'STANDARD'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _language,
                  decoration: const InputDecoration(labelText: 'Lang'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : _aiRewrite,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('AI rework / translate'),
              ),
              FilledButton.tonalIcon(
                onPressed: _busy ? null : () => _save(),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save draft'),
              ),
              FilledButton.icon(
                onPressed: _busy ? null : _publish,
                icon: _busy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.publish),
                label: const Text('Publish to GBP'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
