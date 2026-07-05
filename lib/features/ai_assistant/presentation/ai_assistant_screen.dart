import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';
import 'package:google_business_profile_manager/core/services/media_service.dart';
import 'package:google_business_profile_manager/core/services/speech_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/active_business_provider.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

class _ChatMessage {
  const _ChatMessage({required this.text, required this.fromUser});
  final String text;
  final bool fromUser;
}

/// Conversational AI helper: speak or type instructions, get marketing
/// help, or turn a prompt/photo straight into staged catalog drafts.
class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _busy = false;
  bool _listening = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String? _businessContext(BusinessProfile? business) {
    if (business == null) return null;
    return [
      business.name,
      if (business.category.isNotEmpty) 'Category: ${business.category}',
      if (business.address.isNotEmpty) 'Location: ${business.address}',
      if (business.targetAudience != null) 'Audience: ${business.targetAudience}',
      'Languages: ${business.languages}',
    ].join('. ');
  }

  Future<void> _send(BusinessProfile? business) async {
    final prompt = _input.text.trim();
    if (prompt.isEmpty || _busy) return;
    final ai = ref.read(aiServiceProvider);
    setState(() {
      _messages.add(_ChatMessage(text: prompt, fromUser: true));
      _input.clear();
      _busy = true;
    });
    _scrollDown();
    try {
      final answer = await ai.chat(prompt: prompt, businessContext: _businessContext(business));
      if (mounted) setState(() => _messages.add(_ChatMessage(text: answer, fromUser: false)));
    } on AiException catch (error) {
      if (mounted) setState(() => _messages.add(_ChatMessage(text: '⚠ ${error.message}', fromUser: false)));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollDown();
    }
  }

  Future<void> _draftListing(BusinessProfile business) async {
    final prompt = _input.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Describe the offer first (voice or text), then tap "Draft catalog entry".'),
      ));
      return;
    }
    final ai = ref.read(aiServiceProvider);
    setState(() => _busy = true);
    try {
      final repository = ref.read(businessRepositoryProvider);
      final drafts = await ai.draftListings(
        prompt: prompt,
        locationContext: business.address.isEmpty ? null : business.address,
        languages: business.languages.split(',').where((code) => code.isNotEmpty).toList(),
        existingCategories: await repository.stagingCategories(business.id),
      );
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
            source: Value(ai.sourceTag),
          ),
      ]);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: '${drafts.length} draft(s) added to the staging catalog: '
              '${drafts.map((d) => d.title).join(', ')}. Review the amber prices there.',
          fromUser: false,
        ));
        _input.clear();
      });
    } on AiException catch (error) {
      if (mounted) setState(() => _messages.add(_ChatMessage(text: '⚠ ${error.message}', fromUser: false)));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollDown();
    }
  }

  Future<void> _analyzePhoto(BusinessProfile business) async {
    final media = ref.read(mediaServiceProvider);
    final image = await media.pickImage();
    if (image == null || !mounted) return;
    final ai = ref.read(aiServiceProvider);
    setState(() => _busy = true);
    try {
      final repository = ref.read(businessRepositoryProvider);
      final bytes = await image.readAsBytes();
      final drafts = await ai.analyzeProductImage(
        imageBytes: bytes,
        mimeType: 'image/jpeg',
        intent: _input.text.trim(),
        locationContext: business.address.isEmpty ? null : business.address,
        languages: business.languages.split(',').where((code) => code.isNotEmpty).toList(),
        existingCategories: await repository.stagingCategories(business.id),
      );
      final path = await media.persistImage(image);
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
            imagePath: Value(path),
            source: Value(ai.sourceTag),
          ),
      ]);
      if (!mounted) return;
      setState(() => _messages.add(_ChatMessage(
            text: 'Photo analyzed — ${drafts.length} draft(s) staged: '
                '${drafts.map((d) => '${d.title} (${d.priceAmount} ${d.currencyCode}, est.)').join(', ')}',
            fromUser: false,
          )));
    } on AiException catch (error) {
      if (mounted) setState(() => _messages.add(_ChatMessage(text: '⚠ ${error.message}', fromUser: false)));
    } finally {
      if (mounted) setState(() => _busy = false);
      _scrollDown();
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
      if (mounted) setState(() => _input.text = transcript);
    });
    if (!mounted) return;
    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Voice input is not available on this device — typing works everywhere.'),
      ));
      return;
    }
    setState(() => _listening = true);
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(activeBusinessProvider);
    final ai = ref.watch(aiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Chip(
                avatar: Icon(
                  ai.isConfigured ? Icons.check_circle : Icons.key_off,
                  size: 18,
                  color: ai.isConfigured ? Theme.of(context).colorScheme.secondary : null,
                ),
                label: Text(ai.isConfigured ? ai.providerLabel : 'No AI key'),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!ai.isConfigured)
            MaterialBanner(
              content: const Text('Add your free AI key (Gemini or OpenRouter/Qwen) to unlock the assistant.'),
              actions: [
                TextButton(onPressed: () => context.go('/settings'), child: const Text('Open Settings')),
              ],
            ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.smart_toy_outlined,
                                size: 56, color: Theme.of(context).colorScheme.outline),
                            const SizedBox(height: 16),
                            Text('Speak or type an instruction',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            const Text(
                              'Ask for descriptions, translations, marketing ideas — or dictate an '
                              'offer and turn it straight into a staged catalog entry.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return Align(
                        alignment: message.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(maxWidth: 560),
                          decoration: BoxDecoration(
                            color: message.fromUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: SelectableText(message.text),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (business != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.playlist_add, size: 18),
                            label: const Text('Draft catalog entry'),
                            onPressed: _busy ? null : () => _draftListing(business),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.image_search, size: 18),
                            label: const Text('Analyze a photo'),
                            onPressed: _busy ? null : () => _analyzePhoto(business),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          maxLines: 4,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: _listening ? 'Listening…' : 'Message the assistant',
                            suffixIcon: IconButton(
                              tooltip: _listening ? 'Stop recording' : 'Dictate',
                              icon: Icon(_listening ? Icons.stop_circle : Icons.mic,
                                  color: _listening ? Colors.red : null),
                              onPressed: _toggleMic,
                            ),
                          ),
                          onSubmitted: (_) => _send(business),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        tooltip: 'Send',
                        onPressed: _busy ? null : () => _send(business),
                        icon: _busy
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
