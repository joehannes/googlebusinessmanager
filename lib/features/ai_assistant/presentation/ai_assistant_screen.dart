import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  String _draft = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateDraft() async {
    final output = await _aiService.draftFromVoice(_controller.text);
    setState(() {
      _draft = '${output['title']}\n${output['description']}\nPrice: ${output['priceUsd']} / ${output['priceDop']}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Voice and image assistance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            const Text('Capture a voice note or image and let the assistant produce a draft profile update.'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Voice or prompt input',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _generateDraft,
                  icon: const Icon(Icons.mic),
                  label: const Text('Generate draft'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                  label: const Text('Analyze image'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_draft.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_draft),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
