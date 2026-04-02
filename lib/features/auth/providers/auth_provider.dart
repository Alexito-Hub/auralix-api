import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hub_aura/core/network/api_client.dart';
import 'package:hub_aura/shared/models/user_model.dart';

const hubAuthTokenStorageKey = 'hub_auth_token';

final authProvider =
    AsyncNotifierProvider<AuthNotifier, HubUser?>(AuthNotifier.new);

final authTokenProvider = FutureProvider<String?>((ref) async {
  // Recompute token when authentication state changes.
  ref.watch(authProvider);

  final inMemoryToken = ApiClient.instance.activeBearerToken;
  if (inMemoryToken != null && inMemoryToken.trim().isNotEmpty) {
    return inMemoryToken;
  }

  final prefs = await SharedPreferences.getInstance();
  final persisted = prefs.getString(hubAuthTokenStorageKey);
  if (persisted == null || persisted.trim().isEmpty) return null;
  return persisted.trim();
});

class AuthNotifier extends AsyncNotifier<HubUser?> {
  final _api = ApiClient.instance;
  static const _tokenKey = hubAuthTokenStorageKey;

  @override
  Future<HubUser?> build() async {
    _api.setUnauthorizedHandler(() async {
      await _clearSession();
    });
    ref.onDispose(_api.clearUnauthorizedHandler);

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_tokenKey);
    if (savedToken != null && savedToken.trim().isNotEmpty) {
      _api.setToken(savedToken);
    }

    try {
      final res = await _api.get('/hub/auth/me');
      if (res.statusCode == 200 && res.data['status'] == true) {
        final user = HubUser.fromJson(res.data['data']);
        final refreshedToken = res.data['token']?.toString();
        if (refreshedToken != null && refreshedToken.trim().isNotEmpty) {
          _api.setToken(refreshedToken);
          await prefs.setString(_tokenKey, refreshedToken);
        }
        return user;
      }
    } catch (_) {}

    await _clearSession(updateState: false);
    return null;
  }

  Future<String?> login(
      {required String email,
      required String password,
      required String captchaToken}) async {
    state = const AsyncLoading();
    try {
      final res = await _api.post('/hub/auth/login', data: {
        'email': email,
        'password': password,
        'captchaToken': captchaToken,
      });
      if (res.statusCode == 200 && res.data['status'] == true) {
        final user = HubUser.fromJson(res.data['data']);
        final token = res.data['token']?.toString();
        if (token != null && token.trim().isNotEmpty) {
          _api.setToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
        }
        state = AsyncData(user);
        return null;
      }
      state = const AsyncData(null);
      return res.data['msg']?.toString() ?? 'Login failed';
    } on DioException catch (e) {
      state = const AsyncData(null);
      return e.response?.data['msg']?.toString() ?? 'Connection error';
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String captchaToken,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _api.post('/hub/auth/register', data: {
        'email': email,
        'password': password,
        'captchaToken': captchaToken,
      });
      if ((res.statusCode == 200 || res.statusCode == 201) &&
          res.data['status'] == true) {
        final token = res.data['token']?.toString();
        if (token != null && token.trim().isNotEmpty) {
          _api.setToken(token);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
        }

        HubUser? user;
        final rawData = res.data['data'];
        if (rawData is Map<String, dynamic>) {
          try {
            user = HubUser.fromJson(rawData);
          } catch (_) {}
        } else if (rawData is Map) {
          try {
            user = HubUser.fromJson(
              rawData.map((key, value) => MapEntry(key.toString(), value)),
            );
          } catch (_) {}
        }

        if (user == null) {
          await _clearSession();
          return res.data['msg']?.toString() ??
              'Registration failed: invalid user payload';
        }

        state = AsyncData(user);
        return null;
      }
      state = const AsyncData(null);
      return res.data['msg']?.toString() ?? 'Registration failed';
    } on DioException catch (e) {
      state = const AsyncData(null);
      return e.response?.data['msg']?.toString() ?? 'Connection error';
    } catch (_) {
      state = const AsyncData(null);
      return 'Registration failed';
    }
  }

  Future<void> _clearSession({bool updateState = true}) async {
    _api.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    if (updateState) {
      try {
        state = const AsyncData(null);
      } catch (_) {
        // Provider may be disposed while handling async unauthorized events.
      }
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/hub/auth/logout');
    } catch (_) {}

    await _clearSession();
  }
}
