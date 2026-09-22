import 'package:flutter/material.dart';
import '../services/network_service.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  final NetworkService _service = NetworkService();
  NetworkStatus _currentStatus = NetworkStatus.offline;
  int _progress = 0;
  List<String> _queue = [];

  @override
  void initState() {
    super.initState();

    _service.statusStream.listen((status) {
      if (mounted) setState(() => _currentStatus = status);
    });

    _service.progressStream.listen((p) {
      if (mounted) setState(() => _progress = p);
    });

    _service.queueStream.listen((q) {
      if (mounted) setState(() => _queue = q);
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  IconData get _statusIcon {
    switch (_currentStatus) {
      case NetworkStatus.wifi:
        return Icons.wifi;
      case NetworkStatus.cellular:
        return Icons.signal_cellular_alt;
      case NetworkStatus.offline:
        return Icons.wifi_off;
    }
  }

  String get _statusLabel {
    switch (_currentStatus) {
      case NetworkStatus.wifi:
        return 'Wi-Fi';
      case NetworkStatus.cellular:
        return 'Cellular';
      case NetworkStatus.offline:
        return 'Offline';
    }
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case NetworkStatus.wifi:
        return Colors.green;
      case NetworkStatus.cellular:
        return Colors.blue;
      case NetworkStatus.offline:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Monitor')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Live status card =====
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _statusColor, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(_statusIcon, size: 64, color: _statusColor),
                        const SizedBox(height: 12),
                        Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _statusColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Current Network Interface',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ===== Request progress =====
                  Text(
                    'Long-Running Request',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Progress: $_progress%',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 16),

                  FilledButton.icon(
                    onPressed: () => _service.startSimulatedRequest(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Data Fetch'),
                  ),

                  const SizedBox(height: 24),

                  // ===== Queue display =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Queued Requests (${_queue.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_queue.isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _service.clearQueue(),
                          icon: const Icon(Icons.clear, size: 16),
                          label: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_queue.isEmpty)
                    const Text(
                      'No pending requests',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._queue.map(
                      (item) => Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.pending_actions,
                            color: Colors.orange,
                          ),
                          title: Text(item),
                          trailing: const Icon(Icons.hourglass_bottom),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ===== Info box =====
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🧪 How to test:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text('1. Tap "Start Data Fetch"'),
                        Text('2. Turn OFF Wi-Fi (or turn on Airplane Mode)'),
                        Text('3. Watch the progress stop & queue fill up'),
                        Text('4. Turn Wi-Fi back ON'),
                        Text('5. Watch the request auto-resume ✅'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
