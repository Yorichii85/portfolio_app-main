import 'package:flutter/foundation.dart';
import '../services/network_diagnostic_service.dart';

enum ConnectionHealth { excellent, fair, poor, degraded, unknown }

extension ConnectionHealthLabel on ConnectionHealth {
  String get label {
    switch (this) {
      case ConnectionHealth.excellent:
        return 'Excellent';
      case ConnectionHealth.fair:
        return 'Fair';
      case ConnectionHealth.poor:
        return 'Poor';
      case ConnectionHealth.degraded:
        return 'Degraded';
      case ConnectionHealth.unknown:
        return 'Unknown';
    }
  }
}

class NetworkHealthProvider extends ChangeNotifier {
  final NetworkDiagnosticService _service = NetworkDiagnosticService();

  DiagnosticResult? result;
  ConnectionHealth health = ConnectionHealth.unknown;
  bool isTesting = false;
  String statusMessage = 'Ready';

  ConnectionHealth _categorize(DiagnosticResult r) {
    final download = r.downloadMbps ?? 0;
    final ping = r.downloadPingMs ?? r.idlePingMs ?? 0;

    if ((r.packetLossPercent ?? 0) > 20) return ConnectionHealth.degraded;
    if (ping > 500) return ConnectionHealth.degraded;
    if (download > 10) return ConnectionHealth.excellent;
    if (download >= 2) return ConnectionHealth.fair;
    return ConnectionHealth.poor;
  }

  Future<void> runDiagnostic() async {
    isTesting = true;
    statusMessage = 'Testing idle ping...';
    notifyListeners();

    final r = await _service.runFullDiagnostic();

    if (r.error != null) {
      isTesting = false;
      health = ConnectionHealth.degraded;
      statusMessage = 'Error: ${r.error}';
      notifyListeners();
      return;
    }

    result = r;
    health = _categorize(r);
    isTesting = false;
    statusMessage = 'Complete: ${health.label}';
    notifyListeners();
  }
}
