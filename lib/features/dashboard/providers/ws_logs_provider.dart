import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:hub_aura/features/auth/providers/auth_provider.dart';
import 'package:hub_aura/core/network/api_client.dart';

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
        statusCode: _asInt(j['statusCode']) ?? 200,
        durationMs: _asInt(j['durationMs']) ?? 0,
        creditsUsed: _asInt(j['creditsUsed']) ?? 0,
        timestamp: DateTime.tryParse(j['timestamp'] ?? '') ?? DateTime.now(),
      );

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}

/// Provider holding a live list of WebSocket log entries.
final wsLogsProvider =
    StateNotifierProvider<WsLogsNotifier, List<WsLogEntry>>((ref) {
  final notifier = WsLogsNotifier();

  final currentUser = ref.read(authProvider).valueOrNull;
  if (currentUser != null) {
    notifier.connect();
  }

  ref.listen(authProvider, (_, next) {
    if (next.isLoading) return;

    final user = next.valueOrNull;
    if (user != null) {
      notifier.connect();
    } else {
      notifier.disconnect();
      notifier.clear();
    }
  });

  return notifier;
});

class WsLogsNotifier extends StateNotifier<List<WsLogEntry>> {
  WsLogsNotifier() : super([]);

  io.Socket? _socket;
  Timer? _retryTimer;
  bool _disposed = false;
  bool _connecting = false;
  bool _shouldReconnect = false;
  int _retryCount = 0;

  static const int _maxRetries = 4;
  static const Duration _retryDelay = Duration(seconds: 4);
  static const String _socketEnvUrl = String.fromEnvironment(
    'WS_BASE_URL',
    defaultValue: '',
  );

  static final String _socketBaseUrl = _socketEnvUrl.isNotEmpty
      ? _sanitizeSocketBaseUrl(_socketEnvUrl)
      : _sanitizeSocketBaseUrl(ApiClient.baseUrl);

  static String _sanitizeSocketBaseUrl(String rawUrl) {
    final uri = Uri.parse(rawUrl.trim());
    final scheme =
        uri.scheme == 'https' || uri.scheme == 'wss' ? 'https' : 'http';
    final normalized = uri.replace(
      scheme: scheme,
      path: '',
      query: null,
      fragment: null,
    );
    final text = normalized.toString();
    return text.endsWith('/') ? text.substring(0, text.length - 1) : text;
  }

  Uri _buildSocketUri() {
    final base = Uri.parse(_socketBaseUrl);
    return base.replace(
      path: '/hub/socket',
      query: null,
      fragment: null,
    );
  }

  void connect() {
    if (_disposed) return;
    _shouldReconnect = true;
    if (_connecting) return;
    if (_socket != null) return;
    _open();
  }

  void _open() {
    if (_disposed || !_shouldReconnect) return;

    _retryTimer?.cancel();
    _retryTimer = null;
    _teardownSocket();

    _connecting = true;
    final token = ApiClient.instance.activeBearerToken;
    if (token == null || token.trim().isEmpty) {
      _connecting = false;
      _scheduleReconnect();
      return;
    }

    try {
      final socket = io.io(
        _buildSocketUri().toString(),
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'path': '/socket.io',
          'auth': <String, dynamic>{'token': token},
        },
      );

      _socket = socket;

      socket.onConnect((_) {
        if (_disposed) return;
        _retryCount = 0;
        _connecting = false;
      });

      socket.on('request_log', (data) {
        if (_disposed) return;
        try {
          final json = _toJsonMap(data);
          if (json == null) return;
          if (json['method'] != null) {
            final entry = WsLogEntry.fromJson(json);
            state = [entry, ...state].take(200).toList();
            _retryCount = 0;
          }
        } catch (_) {}
      });

      socket.onConnectError((_) {
        if (_disposed) return;
        _handleSocketFailure();
      });
      socket.onError((_) {
        if (_disposed) return;
        _handleSocketFailure();
      });
      socket.onDisconnect((_) {
        if (_disposed) return;
        _handleSocketFailure();
      });
      socket.connect();
    } catch (_) {
      _connecting = false;
      _scheduleReconnect();
      return;
    }
  }

  void _handleSocketFailure() {
    if (_disposed) return;
    _teardownSocket();
    _connecting = false;
    _scheduleReconnect();
  }

  void _teardownSocket() {
    final socket = _socket;
    if (socket == null) return;
    socket.off('request_log');
    socket.off('connect');
    socket.off('connect_error');
    socket.off('error');
    socket.off('disconnect');
    socket.disconnect();
    _socket = null;
  }

  void _scheduleReconnect() {
    if (_disposed || !_shouldReconnect) return;
    if (_retryCount >= _maxRetries) return;

    _retryCount += 1;
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay * _retryCount, () {
      if (_disposed) return;
      _open();
    });
  }

  void disconnect() {
    _shouldReconnect = false;
    _retryCount = 0;
    _connecting = false;
    _retryTimer?.cancel();
    _retryTimer = null;
    _teardownSocket();
  }

  void clear() {
    state = [];
  }

  Map<String, dynamic>? _toJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    }
    return null;
  }

  @override
  void dispose() {
    _disposed = true;
    disconnect();
    super.dispose();
  }
}
