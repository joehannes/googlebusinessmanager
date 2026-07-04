import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.key),
            title: Text('Qwen API key'),
            subtitle: Text('Paste your free Qwen-compatible key for drafting workflows.'),
          ),
          ListTile(
            leading: Icon(Icons.cloud),
            title: Text('Google Cloud Console'),
            subtitle: Text('Create the Business Profile API project and secure your credentials.'),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacy'),
            subtitle: Text('Your keys and data stay local by default.'),
          ),
        ],
      ),
    );
  }
}
