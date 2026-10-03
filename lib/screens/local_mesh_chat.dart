import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

import '../models/chat_message.dart';
import '../services/nearby_service.dart';

class LocalMeshChat extends StatefulWidget {
  const LocalMeshChat({super.key});

  @override
  State<LocalMeshChat> createState() => _LocalMeshChatState();
}

class _LocalMeshChatState extends State<LocalMeshChat> {
  final NearbyService _nearbyService = NearbyService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];
  final Map<String, String> _nearbyDevices = {};

  String? _connectedEndpoint;
  String? _connectedDeviceName;

  String? _pendingConnectionEndpoint;
  String? _pendingConnectionName;
  ConnectionInfo? _pendingConnectionInfo;

  // ignore: unused_field
  String _status = 'Ready';

  bool _isDiscovering = false;

  // ignore: unused_field
  bool _isAdvertising = false;

  bool _webDemoConnected = false;

  static const Color forestGreen = Color(0xFF075B48);
  static const Color darkForest = Color(0xFF064536);
  static const Color softGreen = Color(0xFF71B98C);
  static const Color lightGreen = Color(0xFFE7F2E5);
  static const Color paleGreen = Color(0xFFF1F7EA);
  static const Color cream = Color(0xFFF8F7ED);
  static const Color incomingBubble = Color(0xFFEAE9DF);
  static const Color darkText = Color(0xFF12352D);

  bool get _hasIncomingConnection =>
      _pendingConnectionEndpoint != null && _pendingConnectionInfo != null;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;
    await _nearbyService.requestPermissions();
  }

  // ============================================================
  // ADVERTISING
  // ============================================================

  Future<void> _startAdvertising() async {
    if (kIsWeb) {
      setState(() {
        _isAdvertising = true;
        _status = 'Demo mode • Ready to connect';
      });
      return;
    }

    try {
      final result = await _nearbyService.startAdvertising(
        deviceName: 'Local Chat Device',
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );

      if (!mounted) return;

      setState(() {
        _isAdvertising = result;
        _status = result
            ? 'Your device is visible nearby'
            : 'Could not start broadcasting';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Broadcast error: $e');
    }
  }

  // ============================================================
  // DISCOVERY
  // ============================================================

  Future<void> _startDiscovery() async {
    if (kIsWeb) {
      setState(() {
        _isDiscovering = true;
        _status = 'Searching for nearby devices...';
      });
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _nearbyDevices
          ..clear()
          ..['demo-phone-01'] = "Claire's Phone";
        _isDiscovering = false;
        _status = '1 device found nearby';
      });
      return;
    }

    try {
      setState(() {
        _isDiscovering = true;
        _status = 'Searching for nearby devices...';
      });

      final result = await _nearbyService.startDiscovery(
        deviceName: 'Local Chat Device',
        onEndpointFound:
            (String endpointId, String endpointName, String serviceId) {
              if (!mounted) return;
              if (serviceId != NearbyService.serviceId) return;

              setState(() {
                _nearbyDevices[endpointId] = endpointName;
                _status = '${_nearbyDevices.length} device(s) found nearby';
              });
            },
        onEndpointLost: (String? endpointId) {
          if (!mounted || endpointId == null) return;
          setState(() {
            _nearbyDevices.remove(endpointId);
            _status = _nearbyDevices.isEmpty
                ? 'No nearby devices'
                : '${_nearbyDevices.length} device(s) found nearby';
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _isDiscovering = result;
        if (!result) _status = 'Discovery could not start';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDiscovering = false;
        _status = 'Discovery error: $e';
      });
    }
  }

  Future<void> _stopDiscovery() async {
    if (kIsWeb) {
      if (!mounted) return;
      setState(() {
        _isDiscovering = false;
        _status = _nearbyDevices.isEmpty
            ? 'Ready'
            : '${_nearbyDevices.length} devices found nearby';
      });
      return;
    }

    await _nearbyService.stopDiscovery();
    if (!mounted) return;
    setState(() {
      _isDiscovering = false;
      _status = 'Discovery stopped';
    });
  }

  // ============================================================
  // CONNECT
  // ============================================================

  Future<void> _connectToDevice(String endpointId, String endpointName) async {
    if (kIsWeb) {
      setState(() => _status = 'Connecting to $endpointName...');
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _webDemoConnected = true;
        _connectedEndpoint = endpointId;
        _connectedDeviceName = endpointName;
        _status = 'Connected nearby';
        _nearbyDevices.remove(endpointId);
      });
      _addDemoWelcomeMessages();
      return;
    }

    try {
      setState(() => _status = 'Connecting to $endpointName...');

      await _nearbyService.requestConnection(
        deviceName: 'Local Chat Device',
        endpointId: endpointId,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Connection error: $e');
    }
  }

  void _addDemoWelcomeMessages() {
    if (_messages.isNotEmpty) return;
    final now = DateTime.now();
    setState(() {
      _messages.addAll([
        ChatMessage(
          text: 'Hello! 👋',
          isMine: false,
          timestamp: now.subtract(const Duration(minutes: 3)),
        ),
        ChatMessage(
          text: 'Hi! Nice to meet you!',
          isMine: true,
          timestamp: now.subtract(const Duration(minutes: 2)),
        ),
        ChatMessage(
          text:
              'This is a local connection using Nearby Connections.\nNo internet needed!',
          isMine: false,
          timestamp: now.subtract(const Duration(minutes: 1)),
        ),
        ChatMessage(
          text: "Awesome! Let's chat! 🌿",
          isMine: true,
          timestamp: now,
        ),
      ]);
    });
    _scrollToBottom();
  }

  // ============================================================
  // CALLBACKS
  // ============================================================

  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    if (!mounted) return;
    setState(() {
      _pendingConnectionEndpoint = endpointId;
      _pendingConnectionName = info.endpointName;
      _pendingConnectionInfo = info;
      _status = 'Incoming connection request';
    });
  }

  Future<void> _acceptIncomingConnection() async {
    final endpointId = _pendingConnectionEndpoint;
    final info = _pendingConnectionInfo;
    if (endpointId == null || info == null) return;

    try {
      await _nearbyService.acceptConnection(
        endpointId: endpointId,
        onPayloadReceived: _onPayloadReceived,
      );
      if (!mounted) return;
      setState(() {
        _connectedEndpoint = endpointId;
        _connectedDeviceName = info.endpointName;
        _pendingConnectionEndpoint = null;
        _pendingConnectionName = null;
        _pendingConnectionInfo = null;
        _status = 'Connected nearby';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Connection error: $e';
        _pendingConnectionEndpoint = null;
        _pendingConnectionName = null;
        _pendingConnectionInfo = null;
      });
    }
  }

  Future<void> _rejectIncomingConnection() async {
    final endpointId = _pendingConnectionEndpoint;
    if (endpointId != null) {
      await _nearbyService.rejectConnection(endpointId);
    }
    if (!mounted) return;
    setState(() {
      _pendingConnectionEndpoint = null;
      _pendingConnectionName = null;
      _pendingConnectionInfo = null;
      _status = 'Ready';
    });
  }

  void _onConnectionResult(String endpointId, Status status) {
    if (!mounted) return;
    setState(() {
      if (status == Status.CONNECTED) {
        _connectedEndpoint = endpointId;
        _connectedDeviceName =
            _connectedDeviceName ??
            _nearbyDevices[endpointId] ??
            'Nearby Device';
        _status = 'Connected nearby';
        _nearbyDevices.remove(endpointId);
      } else {
        _connectedEndpoint = null;
        _connectedDeviceName = null;
        _status = 'Connection failed: $status';
      }
    });
  }

  void _onDisconnected(String endpointId) {
    if (!mounted) return;
    setState(() {
      if (_connectedEndpoint == endpointId) {
        _connectedEndpoint = null;
        _connectedDeviceName = null;
        _webDemoConnected = false;
      }
      _status = 'Device disconnected';
    });
  }

  void _onPayloadReceived(String endpointId, Payload payload) {
    if (payload.type != PayloadType.BYTES) return;
    final Uint8List? bytes = payload.bytes;
    if (bytes == null) return;
    final String text = utf8.decode(bytes);
    if (!mounted) return;
    setState(() {
      _messages.add(
        ChatMessage(text: text, isMine: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final String text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (_connectedEndpoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: darkForest,
          content: Text('Connect to a nearby device first.'),
        ),
      );
      return;
    }

    if (kIsWeb && _webDemoConnected) {
      setState(() {
        _messages.add(
          ChatMessage(text: text, isMine: true, timestamp: DateTime.now()),
        );
      });
      _messageController.clear();
      _scrollToBottom();
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted || !_webDemoConnected) return;
      setState(() {
        _messages.add(
          ChatMessage(
            text: 'Message received! 👋',
            isMine: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
      return;
    }

    try {
      final Uint8List data = Uint8List.fromList(utf8.encode(text));
      await _nearbyService.sendBytes(
        endpointId: _connectedEndpoint!,
        data: data,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(text: text, isMine: true, timestamp: DateTime.now()),
        );
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text('Message failed: $e'),
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool connected = _connectedEndpoint != null;

    return Scaffold(
      backgroundColor: cream,
      appBar: _buildAppBar(connected),
      body: Stack(
        children: [
          const Positioned.fill(child: _LeafBackground()),
          Column(
            children: [
              if (_hasIncomingConnection)
                Expanded(child: _buildIncomingConnectionPanel())
              else if (!connected)
                Expanded(child: _buildNearbyPanel())
              else
                _buildConnectedPanel(),
              if (!_hasIncomingConnection && !connected) _buildFeatureStrip(),
              if (connected) ...[
                Expanded(child: _buildMessages()),
                _buildFeatureStrip(),
                _buildMessageInput(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool connected) {
    return AppBar(
      backgroundColor: forestGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: true,
      titleSpacing: 0,
      toolbarHeight: 72,
      title: Row(
        children: [
          _appBarIcon(
            _hasIncomingConnection
                ? Icons.link_rounded
                : connected
                ? Icons.phone_android_rounded
                : Icons.forum_rounded,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hasIncomingConnection
                      ? 'Incoming Connection'
                      : connected
                      ? (_connectedDeviceName ?? 'Nearby Device')
                      : 'Local Mesh Chat',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: connected
                            ? const Color(0xFF52E28A)
                            : Colors.white70,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _hasIncomingConnection
                          ? 'Connection request'
                          : connected
                          ? 'Connected nearby'
                          : 'Offline • Nearby only',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          onSelected: (value) {
            if (value == 'broadcast') _startAdvertising();
            if (value == 'scan') _startDiscovery();
            if (value == 'stop') _stopDiscovery();
            if (value == 'info') _showDeviceInfo();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'broadcast',
              child: ListTile(
                leading: Icon(Icons.wifi_tethering_rounded),
                title: Text('Broadcast device'),
              ),
            ),
            const PopupMenuItem(
              value: 'scan',
              child: ListTile(
                leading: Icon(Icons.search_rounded),
                title: Text('Scan nearby'),
              ),
            ),
            if (_isDiscovering)
              const PopupMenuItem(
                value: 'stop',
                child: ListTile(
                  leading: Icon(Icons.stop_circle_outlined),
                  title: Text('Stop scanning'),
                ),
              ),
            const PopupMenuItem(
              value: 'info',
              child: ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('Connection info'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNearbyPanel() {
    final bool hasDevice = _nearbyDevices.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Column(
        children: [
          _buildDiscoveryHero(),
          if (hasDevice) ...[
            const SizedBox(height: 10),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Nearby Devices',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: darkText,
                          ),
                        ),
                      ),
                      Text(
                        '${_nearbyDevices.length} found',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._nearbyDevices.entries.map(
                    (entry) => _buildDeviceRow(entry.key, entry.value),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDiscoveryHero() {
    final bool hasDevices = _nearbyDevices.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softGreen.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 125,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _deviceOrb(
                  label: 'My Phone',
                  active: true,
                  icon: Icons.phone_android_rounded,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _connectionGraphic(
                    active: hasDevices || _isDiscovering,
                  ),
                ),
                const SizedBox(width: 6),
                _deviceOrb(
                  label: 'Nearby',
                  active: hasDevices,
                  icon: Icons.phone_android_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _isDiscovering
                ? 'Discovering nearby devices...'
                : hasDevices
                ? 'Nearby device found'
                : 'No devices found',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: darkText,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _isDiscovering
                ? 'Make sure the other device has\n'
                      'Local Mesh Chat open and is discoverable.'
                : hasDevices
                ? 'Select a nearby device below to connect.'
                : 'Make sure the other device has\n'
                      'Local Mesh Chat open and is discoverable.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 15),
          if (_isDiscovering)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.3,
                color: forestGreen,
              ),
            )
          else if (!hasDevices)
            FilledButton.icon(
              onPressed: _startDiscovery,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text('Try Again'),
              style: _greenButtonStyle(
                padding: const EdgeInsets.symmetric(
                  horizontal: 23,
                  vertical: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(String endpointId, String name) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: paleGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: softGreen.withValues(alpha: .28)),
      ),
      child: Row(
        children: [
          _iconCircle(Icons.phone_android_rounded),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Available nearby • ~2 m',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => _connectToDevice(endpointId, name),
            style: _greenButtonStyle(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingConnectionPanel() {
    final String deviceName = _pendingConnectionName ?? 'Nearby Device';
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: softGreen.withValues(alpha: .20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .025),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 130,
              child: Row(
                children: [
                  Expanded(
                    child: _incomingDeviceGraphic(
                      icon: Icons.phone_android_rounded,
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: forestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: _incomingDeviceGraphic(
                      icon: Icons.phone_android_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$deviceName wants to connect',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: darkText,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'This will establish a local connection\n'
              'for messaging.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rejectIncomingConnection,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkForest,
                      side: const BorderSide(color: forestGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _acceptIncomingConnection,
                    style: _greenButtonStyle(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomingDeviceGraphic({required IconData icon}) {
    return Center(
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: lightGreen,
          shape: BoxShape.circle,
          border: Border.all(color: softGreen.withValues(alpha: .18)),
        ),
        child: Container(
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .65),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: forestGreen, size: 37),
        ),
      ),
    );
  }

  Widget _buildConnectedPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 3),
      child: Column(
        children: [
          _sectionCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                _iconCircle(
                  Icons.phone_android_rounded,
                  size: 50,
                  iconSize: 27,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _connectedDeviceName ?? 'Nearby Device',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.circle, size: 7, color: Color(0xFF35B96D)),
                          SizedBox(width: 5),
                          Text(
                            'Connected nearby',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.signal_cellular_alt_rounded,
                  color: forestGreen,
                  size: 23,
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          _connectionInfoCard(),
        ],
      ),
    );
  }

  Widget _connectionInfoCard() {
    return _sectionCard(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _smallShield(),
              const SizedBox(width: 9),
              const Text(
                'Connection Info',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Status', 'Connected'),
          _infoRow('Mode', 'Nearby'),
          _infoRow('Internet', 'Not required'),
          _infoRow('Security', 'Secure connection'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 11.5,
                color: darkText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconCircle(Icons.forum_outlined, size: 72, iconSize: 34),
              const SizedBox(height: 14),
              const Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _connectedEndpoint == null
                    ? 'Connect to a nearby device to start chatting.'
                    : 'Send a message to start the conversation.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  height: 1.4,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(
          _messages[index],
          index == _messages.length - 1,
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool showTime) {
    final bool mine = message.isMine;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            _iconCircle(Icons.person_rounded, size: 38, iconSize: 21),
            const SizedBox(width: 7),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * .72,
              ),
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 8),
              decoration: BoxDecoration(
                color: mine ? forestGreen : incomingBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(mine ? 20 : 5),
                  bottomRight: Radius.circular(mine ? 5 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .025),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: mine ? Colors.white : darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: mine ? Colors.white70 : Colors.black45,
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureStrip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 3, 16, 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: lightGreen.withValues(alpha: .88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: softGreen.withValues(alpha: .18)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _FeatureItem(
              icon: Icons.wifi_off_rounded,
              title: 'No Internet',
              subtitle: 'Required',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.link_rounded,
              title: 'Local Connection',
              subtitle: '(nearby)',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.shield_rounded,
              title: 'Secure',
              subtitle: 'Connection',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final bool canSend = _connectedEndpoint != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 9),
      decoration: BoxDecoration(
        color: cream.withValues(alpha: .97),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _roundActionButton(
              icon: Icons.add_rounded,
              onPressed: canSend ? () {} : null,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: .06),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  enabled: canSend,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(color: darkText, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: canSend
                        ? 'Type a message...'
                        : _isDiscovering
                        ? 'Searching...'
                        : 'Connect to chat...',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 7),
            _roundActionButton(
              icon: Icons.send_rounded,
              onPressed: canSend ? _sendMessage : null,
              filled: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool filled = false,
  }) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: filled
            ? (onPressed != null ? forestGreen : Colors.grey.shade300)
            : (onPressed != null ? forestGreen : lightGreen),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 21),
        color: filled
            ? Colors.white
            : (onPressed != null ? Colors.white : forestGreen),
        tooltip: filled ? 'Send' : 'Add',
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(14),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .93),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: softGreen.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _deviceOrb({
    required String label,
    required bool active,
    required IconData icon,
  }) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: softGreen.withValues(alpha: .18)),
                ),
                child: Icon(icon, color: forestGreen, size: 36),
              ),
              if (active)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFF35B96D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionGraphic({required bool active}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 3,
                decoration: BoxDecoration(
                  color: active ? softGreen : softGreen.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            active ? Icons.link_rounded : Icons.close_rounded,
            color: forestGreen,
            size: 23,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            5,
            (index) => Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 3,
                decoration: BoxDecoration(
                  color: active ? softGreen : softGreen.withValues(alpha: .35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconCircle(IconData icon, {double size = 44, double iconSize = 23}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: lightGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: forestGreen, size: iconSize),
    );
  }

  Widget _appBarIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 23),
    );
  }

  Widget _smallShield() {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: lightGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.shield_rounded, size: 17, color: forestGreen),
    );
  }

  ButtonStyle _greenButtonStyle({
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 22,
      vertical: 11,
    ),
  }) {
    return FilledButton.styleFrom(
      backgroundColor: forestGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: padding,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  void _showDeviceInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                _iconCircle(
                  Icons.devices_other_rounded,
                  size: 56,
                  iconSize: 29,
                ),
                const SizedBox(height: 11),
                const Text(
                  'Local Mesh Chat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Nearby device-to-device messaging.\n'
                  'No internet connection is required.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                if (kIsWeb)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Chrome Preview Mode\n'
                      'Nearby devices are simulated for UI testing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: forestGreen,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final int hour = time.hour;
    final int minute = time.minute;
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour:'
        '${minute.toString().padLeft(2, '0')} '
        '$period';
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _nearbyService.stop();
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ================================================================
// FEATURE ITEM
// ================================================================

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 17, color: _LocalMeshChatState.forestGreen),
        const SizedBox(height: 3),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: _LocalMeshChatState.darkText,
          ),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 8, color: Colors.black54),
        ),
      ],
    );
  }
}

// ================================================================
// VERTICAL DIVIDER
// ================================================================

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: _LocalMeshChatState.softGreen.withValues(alpha: .25),
    );
  }
}

// ================================================================
// LEAF BACKGROUND
// ================================================================

class _LeafBackground extends StatelessWidget {
  const _LeafBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _LeafPainter()));
  }
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBD7A8).withValues(alpha: .22)
      ..style = PaintingStyle.fill;

    _leaf(canvas, paint, Offset(size.width - 25, 115), 30, -0.7);
    _leaf(canvas, paint, Offset(size.width - 52, 150), 25, -0.45);
    _leaf(canvas, paint, Offset(18, size.height - 70), 28, 2.7);
    _leaf(canvas, paint, Offset(48, size.height - 43), 23, 2.95);
    _leaf(canvas, paint, Offset(size.width - 25, size.height - 105), 23, -0.7);
  }

  void _leaf(
    Canvas canvas,
    Paint paint,
    Offset center,
    double length,
    double angle,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * .65, -length * .55, length, 0)
      ..quadraticBezierTo(length * .62, length * .55, 0, 0)
      ..close();
    canvas.drawPath(path, paint);
    final vein = Paint()
      ..color = const Color(0xFF7FAE76).withValues(alpha: .20)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), Offset(length * .82, 0), vein);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
