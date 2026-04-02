import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._();

  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static final String _baseUrl = _envBaseUrl.isNotEmpty
      ? _envBaseUrl
      : const bool.fromEnvironment('dart.vm.product')
          ? 'https://api.auralixpe.xyz'
          : 'http://localhost:8080';

  static String get baseUrl => _baseUrl;

  static Uri get baseUri => Uri.parse(_baseUrl);

  static String get baseAuthority {
    final uri = baseUri;
    if (uri.hasPort) return '${uri.host}:${uri.port}';
    return uri.host;
  }

  static String buildAbsoluteUrl(String endpoint) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '${baseUri.toString().replaceAll(RegExp(r'/+$'), '')}$normalized';
  }

  final CookieJar _cookieJar = CookieJar();

  late final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 600,
    ),
  );

  ApiClient._() {
    if (kDebugMode) debugPrint('> ApiClient.init baseUrl=$_baseUrl');

    if (!kIsWeb) {
      _dio.interceptors.add(CookieManager(_cookieJar));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['x-device-fingerprint'] ??=
            await _DeviceFingerprint.instance();
        if (kDebugMode) {
          debugPrint(
              'ApiClient request: ${options.method} ${options.baseUrl}${options.path}');
          debugPrint('ApiClient request data: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint(
              'ApiClient response: ${response.statusCode} ${response.requestOptions.path}');
        }
        handler.next(response);
      },
      onError: (err, handler) {
        if (kDebugMode) {
          debugPrint('ApiClient error: ${err.message}');
          if (err.response != null) {
            debugPrint(
                'ApiClient error response: ${err.response?.statusCode} ${err.response?.data}');
          }
        }
        handler.next(err);
      },
    ));

    _dio.interceptors.add(_AuthInterceptor());
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? params}) =>
      _dio.get<T>(path, queryParameters: params);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);

  String? get activeBearerToken {
    final authHeader = _dio.options.headers['Authorization']?.toString();
    if (authHeader == null || authHeader.trim().isEmpty) return null;

    final value = authHeader.trim();
    if (value.toLowerCase().startsWith('bearer ')) {
      final token = value.substring(7).trim();
      return token.isEmpty ? null : token;
    }
    return value;
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['startTime'] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['startTime'] as int?;
    if (start != null) {
      response.extra['durationMs'] =
          DateTime.now().millisecondsSinceEpoch - start;
    }
    handler.next(response);
  }
}

class _DeviceFingerprint {
  static const _storageKey = 'hub_device_fingerprint_v1';
  static String? _cached;
  static Future<String>? _pending;

  static Future<String> instance() {
    if (_cached != null && _cached!.isNotEmpty) {
      return Future<String>.value(_cached!);
    }
    _pending ??= _loadOrCreate();
    return _pending!;
  }

  static Future<String> _loadOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _cached = saved.trim();
      return _cached!;
    }

    final random = Random.secure();
    final randomBytes =
        List<int>.generate(32, (_) => random.nextInt(256), growable: false);
    final seed =
        '${DateTime.now().microsecondsSinceEpoch}:${base64UrlEncode(randomBytes)}';
    final fingerprint = sha256.convert(utf8.encode(seed)).toString();

    await prefs.setString(_storageKey, fingerprint);
    _cached = fingerprint;
    return fingerprint;
  }
}
