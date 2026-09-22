import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: context.read<AppState>().userName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Profile',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  onSubmitted: (val) =>
                      context.read<AppState>().updateName(val),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    context
                        .read<AppState>()
                        .updateName(_nameController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated!')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Name'),
                ),
                const Divider(height: 40),
                Text('Appearance',
                    style: Theme.of(context).textTheme.titleMedium),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Applies across the entire app'),
                  value: appState.isDarkMode,
                  onChanged: (val) =>
                      context.read<AppState>().toggleTheme(val),
                  secondary: Icon(
                    appState.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}