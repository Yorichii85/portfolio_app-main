import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { wifi, cellular, offline }

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  // ===== Status stream =====
  final StreamController<NetworkStatus> _statusController =
      StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get statusStream => _statusController.stream;

  NetworkStatus _currentStatus = NetworkStatus.offline;
  NetworkStatus get currentStatus => _currentStatus;

  // ===== Request queue system =====
  final List<String> _pendingRequests = [];
  List<String> get pendingRequests => List.unmodifiable(_pendingRequests);

  final StreamController<List<String>> _queueController =
      StreamController<List<String>>.broadcast();
  Stream<List<String>> get queueStream => _queueController.stream;

  // ===== Progress (long-running request) =====
  Timer? _simulationTimer;
  int _progress = 0;
  final StreamController<int> _progressController =
      StreamController<int>.broadcast();
  Stream<int> get progressStream => _progressController.stream;

  NetworkService() {
    _init();
  }

  Future<void> _init() async {
    final result = await _connectivity.checkConnectivity();
    _updateStatus(result);

    _connectivity.onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    NetworkStatus newStatus = NetworkStatus.offline;

    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet) ||
        results.contains(ConnectivityResult.vpn)) {
      newStatus = NetworkStatus.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      newStatus = NetworkStatus.cellular;
    }

    final wasOffline = _currentStatus == NetworkStatus.offline;
    _currentStatus = newStatus;
    _statusController.add(newStatus);

    // Just came back online → resume queued requests
    if (wasOffline && newStatus != NetworkStatus.offline) {
      _resumeQueuedRequests();
    }

    // Went offline during an active request → queue it
    if (!wasOffline && newStatus == NetworkStatus.offline) {
      if (_simulationTimer != null && _simulationTimer!.isActive) {
        _simulationTimer?.cancel();
        _queueRequest('Resume data fetch from $_progress%');
      }
    }
  }

  // ===== Long-running request simulation =====
  void startSimulatedRequest() {
    if (_currentStatus == NetworkStatus.offline) {
      _queueRequest('Initial data fetch');
      return;
    }

    _progress = 0;
    _progressController.add(_progress);

    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 300), (
      timer,
    ) {
      if (_currentStatus == NetworkStatus.offline) {
        timer.cancel();
        _queueRequest('Resume data fetch from $_progress%');
        return;
      }

      _progress += 5;
      _progressController.add(_progress);

      if (_progress >= 100) {
        timer.cancel();
        _progressController.add(100);
      }
    });
  }

  void _queueRequest(String label) {
    _pendingRequests.add(label);
    _queueController.add(List.from(_pendingRequests));
  }

  Future<void> _resumeQueuedRequests() async {
    if (_pendingRequests.isEmpty) return;

    // Simulate retry delay
    await Future.delayed(const Duration(seconds: 1));

    if (_currentStatus == NetworkStatus.offline) return;
    if (_pendingRequests.isEmpty) return;

    _pendingRequests.removeLast();
    _queueController.add(List.from(_pendingRequests));

    startSimulatedRequest();
  }

  void clearQueue() {
    _pendingRequests.clear();
    _queueController.add([]);
  }

  void dispose() {
    _simulationTimer?.cancel();
    _statusController.close();
    _queueController.close();
    _progressController.close();
  }
}
