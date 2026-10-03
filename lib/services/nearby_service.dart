import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyService {
  static const String serviceId = 'com.example.local_mesh_chat';

  final Nearby _nearby = Nearby();

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<bool> requestPermissions() async {
    if (kIsWeb) return true;

    final permissions = <Permission>[
      Permission.location,
      Permission.locationWhenInUse,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.nearbyWifiDevices,
    ];

    final Map<Permission, PermissionStatus> statuses = await permissions
        .request();

    statuses.forEach((permission, status) {
      debugPrint('Permission $permission: $status');
    });

    final locationGranted = statuses[Permission.location]?.isGranted ?? false;
    final bluetoothGranted =
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false);

    if (Platform.isAndroid) {
      if (!locationGranted || !bluetoothGranted) {
        debugPrint(
          'CRITICAL: Missing permissions! '
          'Location: $locationGranted, Bluetooth: $bluetoothGranted',
        );
        return false;
      }
    }
    return true;
  }

  Future<bool> hasPermissions() async {
    if (kIsWeb) return true;
    final location = await Permission.location.status;
    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;

    return location.isGranted &&
        bluetoothScan.isGranted &&
        bluetoothConnect.isGranted;
  }

  Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }

  // ============================================================
  // ADVERTISING
  // ============================================================

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
      debugPrint('Advertising started as "$deviceName"');
      return true;
    } catch (e) {
      debugPrint('Advertising error: $e');
      return false;
    }
  }

  // ============================================================
  // DISCOVERY
  // ============================================================

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
      debugPrint('Discovery started as "$deviceName"');
      return true;
    } catch (e) {
      debugPrint('Discovery error: $e');
      return false;
    }
  }

  Future<void> stopDiscovery() async {
    try {
      await _nearby.stopDiscovery();
      debugPrint('Discovery stopped');
    } catch (e) {
      debugPrint('stopDiscovery error: $e');
    }
  }

  Future<void> stopAdvertising() async {
    try {
      await _nearby.stopAdvertising();
      debugPrint('Advertising stopped');
    } catch (e) {
      debugPrint('stopAdvertising error: $e');
    }
  }

  // ============================================================
  // CONNECTIONS
  // ============================================================

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

  // ============================================================
  // MESSAGING
  // ============================================================

  Future<void> sendBytes({
    required String endpointId,
    required Uint8List data,
  }) async {
    await _nearby.sendBytesPayload(endpointId, data);
  }

  // ============================================================
  // CLEANUP
  // ============================================================

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
