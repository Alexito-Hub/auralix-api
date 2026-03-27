import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'dart:convert';
import 'package:hub_aura/features/auth/providers/auth_provider.dart';

/// WebSocket log entry model
class WsLogEntry {
  final String method;
  final String path;
  final int statusCode;
  final int durationMs;
  final int creditsUsed;
  final DateTime timestamp;

  WsLogEntry({
    required this.method,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.creditsUsed,
    required this.timestamp,
  });

  factory WsLogEntry.fromJson(Map<String, dynamic> j) => WsLogEntry(
        method: j['method'] ?? 'GET',
        path: j['path'] ?? '/',
        statusCode: j['statusCode'] ?? 200,
        durationMs: j['durationMs'] ?? 0,
        creditsUsed: j['creditsUsed'] ?? 0,
        timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(),
      );
}

/// Provider holding a live list of WebSocket log entries.
final wsLogsProvider =
    StateNotifierProvider<WsLogsNotifier, List<WsLogEntry>>((ref) {
  final notifier = WsLogsNotifier();

  // Connect when auth token is available
  ref.listen(authProvider, (_, next) {
    final token = next.valueOrNull;
    if (token != null) {
      notifier.connect();
    } else {
      notifier.disconnect();
    }
  });

  return notifier;
});

class WsLogsNotifier extends StateNotifier<List<WsLogEntry>> {
  WsLogsNotifier() : super([]);

  WebSocketChannel? _channel;
  static const String _wsUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: 'wss://api.auralixpe.xyz',
  );

  void connect({String? token}) {
    _channel?.sink.close(ws_status.normalClosure);

    // Use simple ws:// query param auth (Socket.IO path needs special handling in Flutter web)
    final uri = Uri.parse('$_wsUrl/api/hub/socket');
    try {
      _channel = WebSocketChannel.connect(uri);
    } catch (e) {
      // Failed to connect WebSocket (e.g. local development without live socket)
      Future.delayed(const Duration(seconds: 5), () => connect(token: token));
      return;
    }

    _channel!.stream.listen(
      (data) {
        try {
          final json = jsonDecode(data as String) as Map<String, dynamic>;
          if (json['method'] != null) {
            final entry = WsLogEntry.fromJson(json);
            // Keep last 200 entries
            state = [entry, ...state].take(200).toList();
          }
        } catch (_) {}
      },
      onError: (_) => Future.delayed(const Duration(seconds: 5), connect),
      onDone: () => Future.delayed(const Duration(seconds: 5), connect),
      cancelOnError: false,
    );
  }

  void disconnect() {
    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
