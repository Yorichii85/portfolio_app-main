import 'dart:async';
import 'package:dio/dio.dart';

/// Represents a single diagnostic test result
class DiagnosticResult {
  final double? idlePingMs;
  final double? downloadMbps;
  final double? downloadPingMs;
  final double? uploadMbps;
  final double? uploadPingMs;
  final double? packetLossPercent;
  final String? error;

  const DiagnosticResult({
    this.idlePingMs,
    this.downloadMbps,
    this.downloadPingMs,
    this.uploadMbps,
    this.uploadPingMs,
    this.packetLossPercent,
    this.error,
  });
}

/// Service that performs network diagnostics
class NetworkDiagnosticService {
  final Dio _dio;

  static const String _pingUrl = 'https://httpbin.org/get';
  static const String _downloadUrl = 'https://httpbin.org/bytes/1048576'; // 1MB
  static const String _uploadUrl = 'https://httpbin.org/post';

  NetworkDiagnosticService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  /// Step 1: Measure baseline "idle ping"
  Future<double> _measureIdlePing() async {
    final pings = <double>[];
    final stopwatch = Stopwatch();

    for (int i = 0; i < 5; i++) {
      try {
        stopwatch.reset();
        stopwatch.start();
        await _dio.get(_pingUrl);
        stopwatch.stop();
        pings.add(stopwatch.elapsedMilliseconds.toDouble());
      } catch (_) {}
    }

    if (pings.isEmpty) return 1000;
    pings.sort();
    return pings[pings.length ~/ 2]; // Return median
  }

  /// Step 2: Compute download bandwidth while measuring ping
  Future<({double downloadMbps, double pingMs})> _measureDownload() async {
    final stopwatch = Stopwatch();
    final pingStopwatch = Stopwatch();
    final pings = <double>[];

    stopwatch.start();
    pingStopwatch.start();

    try {
      final response = await _dio.get(
        _downloadUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (pings.length < 5 && pingStopwatch.elapsedMilliseconds > 200) {
            pingStopwatch.reset();
            pings.add(pingStopwatch.elapsedMilliseconds.toDouble());
          }
        },
      );

      stopwatch.stop();

      final bytes = response.data.length as int;
      final bits = bytes * 8;
      final seconds = stopwatch.elapsedMilliseconds / 1000.0;
      final downloadMbps = seconds > 0 ? (bits / seconds) / 1000000 : 0.0;

      final avgPing = pings.isEmpty
          ? 0.0
          : pings.reduce((a, b) => a + b) / pings.length;

      return (downloadMbps: downloadMbps.toDouble(), pingMs: avgPing);
    } catch (e) {
      return (downloadMbps: 0.0, pingMs: 1000.0);
    }
  }

  /// Step 3: Calculate upload bandwidth while tracking upload ping
  Future<({double uploadMbps, double pingMs})> _measureUpload() async {
    final stopwatch = Stopwatch();
    final pingStopwatch = Stopwatch();
    final pings = <double>[];

    final payload = List<int>.filled(524288, 0); // 512KB

    stopwatch.start();
    pingStopwatch.start();

    try {
      await _dio.post(
        _uploadUrl,
        data: payload,
        options: Options(
          contentType: 'application/octet-stream',
          headers: {'Content-Length': payload.length},
        ),
        onSendProgress: (sent, total) {
          if (pings.length < 5 && pingStopwatch.elapsedMilliseconds > 200) {
            pingStopwatch.reset();
            pings.add(pingStopwatch.elapsedMilliseconds.toDouble());
          }
        },
      );

      stopwatch.stop();

      final bits = payload.length * 8;
      final seconds = stopwatch.elapsedMilliseconds / 1000.0;
      final uploadMbps = seconds > 0 ? (bits / seconds) / 1000000 : 0.0;

      final avgPing = pings.isEmpty
          ? 0.0
          : pings.reduce((a, b) => a + b) / pings.length;

      return (uploadMbps: uploadMbps.toDouble(), pingMs: avgPing);
    } catch (e) {
      return (uploadMbps: 0.0, pingMs: 1000.0);
    }
  }

  /// Runs the full diagnostic sequence
  Future<DiagnosticResult> runFullDiagnostic() async {
    try {
      final idlePing = await _measureIdlePing();
      final downloadResult = await _measureDownload();
      final uploadResult = await _measureUpload();

      return DiagnosticResult(
        idlePingMs: idlePing,
        downloadMbps: downloadResult.downloadMbps,
        downloadPingMs: downloadResult.pingMs,
        uploadMbps: uploadResult.uploadMbps,
        uploadPingMs: uploadResult.pingMs,
        packetLossPercent: 0,
      );
    } catch (e) {
      return DiagnosticResult(error: e.toString());
    }
  }
}
