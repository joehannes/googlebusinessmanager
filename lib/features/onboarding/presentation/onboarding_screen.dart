import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Local-first GBP operations',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Set up your Google Business Profile workspace, stage offers, and use AI to accelerate local content creation.',
              ),
              const SizedBox(height: 24),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('AI voice and image workflows'),
                  subtitle: const Text('Draft profiles from voice, photos, and local context.'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Local-first storage'),
                  subtitle: const Text('Your data stays on-device until you explicitly sync.'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: const Text('Bulk staging catalog'),
                  subtitle: const Text('Prepare offers and products before publishing them to GBP.'),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => context.go('/businesses'),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Launch workspace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
