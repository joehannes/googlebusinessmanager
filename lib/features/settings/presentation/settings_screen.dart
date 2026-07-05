import 'package:flutter/material.dart';
import 'package:google_business_profile_manager/features/settings/presentation/api_setup_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ApiSetupCard(
            title: 'Qwen API key',
            subtitle: 'Paste your free Qwen-compatible key for drafting workflows.',
            icon: Icons.key,
          ),
          ApiSetupCard(
            title: 'Google Cloud Console',
            subtitle: 'Create the Business Profile API project and secure your credentials.',
            icon: Icons.cloud,
          ),
          ApiSetupCard(
            title: 'Privacy',
            subtitle: 'Your keys and data stay local by default.',
            icon: Icons.security,
          ),
          ApiSetupCard(
            title: 'Responsive shell',
            subtitle: 'Switches between bottom navigation and navigation rail automatically.',
            icon: Icons.dashboard_customize,
          ),
        ],
      ),
    );
  }
}
