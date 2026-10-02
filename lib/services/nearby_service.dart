import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';

class NearbyService {
  static const String serviceId = 'com.example.local_mesh_chat';

  final Nearby _nearby = Nearby();

  // ===== Advertising =====
  Future<bool> startAdvertising({
    required String deviceName,
    required Function(String, ConnectionInfo) onConnectionInitiated,
    required Function(String, Status) onConnectionResult,
    required Function(String) onDisconnected,
  }) async {
    try {
      await _nearby.startAdvertising(
        deviceName,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: onConnectionInitiated,
        onConnectionResult: onConnectionResult,
        onDisconnected: onDisconnected,
        serviceId: serviceId,
      );
      return true;
    } catch (e) {
      debugPrint('Advertising error: $e');
      return false;
    }
  }

  // ===== Discovery =====
  Future<bool> startDiscovery({
    required String deviceName,
    required Function(String, String, String) onEndpointFound,
    required Function(String?) onEndpointLost,
  }) async {
    try {
      await _nearby.startDiscovery(
        deviceName,
        Strategy.P2P_CLUSTER,
        onEndpointFound: onEndpointFound,
        onEndpointLost: onEndpointLost,
        serviceId: serviceId,
      );
      return true;
    } catch (e) {
      debugPrint('Discovery error: $e');
      return false;
    }
  }

  Future<void> stopDiscovery() async {
    await _nearby.stopDiscovery();
  }

  Future<void> stopAdvertising() async {
    await _nearby.stopAdvertising();
  }

  // ===== Connections =====
  Future<void> requestConnection({
    required String deviceName,
    required String endpointId,
    required Function(String, ConnectionInfo) onConnectionInitiated,
    required Function(String, Status) onConnectionResult,
    required Function(String) onDisconnected,
  }) async {
    await _nearby.requestConnection(
      deviceName,
      endpointId,
      onConnectionInitiated: onConnectionInitiated,
      onConnectionResult: onConnectionResult,
      onDisconnected: onDisconnected,
    );
  }

  Future<void> acceptConnection({
    required String endpointId,
    required Function(String, Payload) onPayloadReceived,
  }) async {
    await _nearby.acceptConnection(
      endpointId,
      onPayLoadRecieved: onPayloadReceived,
    );
  }

  Future<void> rejectConnection(String endpointId) async {
    await _nearby.rejectConnection(endpointId);
  }

  // ===== Messaging =====
  Future<void> sendBytes({
    required String endpointId,
    required Uint8List data,
  }) async {
    await _nearby.sendBytesPayload(endpointId, data);
  }

  // ===== Cleanup =====
  Future<void> stop() async {
    try {
      await _nearby.stopAdvertising();
    } catch (_) {}
    try {
      await _nearby.stopDiscovery();
    } catch (_) {}
    try {
      await _nearby.stopAllEndpoints();
    } catch (_) {}
  }
}
