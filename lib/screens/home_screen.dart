import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/activity_card.dart';
import 'activity_one_screen.dart';
import 'network_monitor_screen.dart';
import 'network_diagnostic_dashboard.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome back,',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        appState.userName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        avatar: Icon(
                          appState.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          size: 18,
                        ),
                        label: Text(
                          appState.isDarkMode ? 'Dark Mode' : 'Light Mode',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Activity 1 — Counter & Color Picker (tabs)
                      ActivityCard(
                        title: 'Activity 1 — Counter & Color Picker',
                        subtitle: 'Two mini-apps in one screen (tabs)',
                        icon: Icons.add_circle_outline,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ActivityOneScreen(),
                          ),
                        ),
                      ),

                      // Activity 2 — Network Monitor
                      ActivityCard(
                        title: 'Activity 2 — Network Monitor',
                        subtitle: 'Real-time handover & request queueing',
                        icon: Icons.network_check,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NetworkMonitorScreen(),
                          ),
                        ),
                      ),

                      // Network Diagnostic Dashboard
                      ActivityCard(
                        title: 'Network Diagnostic Dashboard',
                        subtitle: 'Test ping, download & upload speed',
                        icon: Icons.speed,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NetworkDiagnosticDashboard(),
                          ),
                        ),
                      ),

                      // Settings
                      ActivityCard(
                        title: 'Settings',
                        subtitle: 'Change name & theme (global state)',
                        icon: Icons.settings_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
