import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_health_provider.dart';
import '../services/network_diagnostic_service.dart';

class NetworkDiagnosticDashboard extends StatelessWidget {
  const NetworkDiagnosticDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NetworkHealthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Network Diagnostic Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HealthStatusCard(health: state.health),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: state.isTesting
                    ? null
                    : () =>
                          context.read<NetworkHealthProvider>().runDiagnostic(),
                icon: state.isTesting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_check),
                label: Text(state.isTesting ? 'Testing...' : 'Run Diagnostic'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              if (state.result != null) ...[
                const Text(
                  'Diagnostic Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _ResultsCard(result: state.result!),
              ],
              const SizedBox(height: 16),
              Text(
                state.statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  const _HealthStatusCard({required this.health});

  final ConnectionHealth health;

  Color get _color {
    switch (health) {
      case ConnectionHealth.excellent:
        return Colors.green;
      case ConnectionHealth.fair:
        return Colors.orange;
      case ConnectionHealth.poor:
        return Colors.red;
      case ConnectionHealth.degraded:
        return Colors.deepOrange;
      case ConnectionHealth.unknown:
        return Colors.grey;
    }
  }

  IconData get _icon {
    switch (health) {
      case ConnectionHealth.excellent:
        return Icons.signal_cellular_alt;
      case ConnectionHealth.fair:
        return Icons.signal_cellular_alt_2_bar;
      case ConnectionHealth.poor:
        return Icons.signal_cellular_alt_1_bar;
      case ConnectionHealth.degraded:
        return Icons.warning_amber_rounded;
      case ConnectionHealth.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _color.withValues(alpha: 0.15),
              child: Icon(_icon, color: _color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connection Health',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    health.label,
                    style: TextStyle(
                      color: _color,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.result});

  final DiagnosticResult result;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry(
        'Idle ping',
        '${(result.idlePingMs ?? 0).toStringAsFixed(1)} ms',
      ),
      MapEntry(
        'Download',
        '${(result.downloadMbps ?? 0).toStringAsFixed(2)} Mbps',
      ),
      MapEntry(
        'Download ping',
        '${(result.downloadPingMs ?? 0).toStringAsFixed(1)} ms',
      ),
      MapEntry('Upload', '${(result.uploadMbps ?? 0).toStringAsFixed(2)} Mbps'),
      MapEntry(
        'Upload ping',
        '${(result.uploadPingMs ?? 0).toStringAsFixed(1)} ms',
      ),
      MapEntry(
        'Packet loss',
        '${(result.packetLossPercent ?? 0).toStringAsFixed(1)}%',
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      row.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(row.value),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
