import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hub_aura/core/network/api_client.dart';
import 'package:hub_aura/shared/models/user_model.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, HubUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<HubUser?> {
  final _api = ApiClient.instance;

  @override
  Future<HubUser?> build() async {
    try {
      final res = await _api.get('/api/hub/auth/me');
      if (res.statusCode == 200 && res.data['status'] == true) {
        final user = HubUser.fromJson(res.data['data']);
        _api.setToken(res.data['token'] ?? '');
        return user;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> login({required String email, required String password, required String captchaToken}) async {
    state = const AsyncLoading();
    try {
      final res = await _api.post('/api/hub/auth/login', data: {
        'email': email,
        'password': password,
        'captchaToken': captchaToken,
      });
      if (res.statusCode == 200 && res.data['status'] == true) {
        final user = HubUser.fromJson(res.data['data']);
        if (res.data['token'] != null) _api.setToken(res.data['token']);
        state = AsyncData(user);
        return null;
      }
      state = const AsyncData(null);
      return res.data['msg'] ?? 'Error al iniciar sesión';
    } on DioException catch (e) {
      state = const AsyncData(null);
      return e.response?.data['msg'] ?? 'Error de conexión';
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String captchaToken,
  }) async {
    state = const AsyncLoading();
    try {
      final res = await _api.post('/api/hub/auth/register', data: {
        'email': email,
        'password': password,
        'captchaToken': captchaToken,
      });
      if ((res.statusCode == 200 || res.statusCode == 201) && res.data['status'] == true) {
        state = const AsyncData(null);
        return null; // success — email verification pending
      }
      state = const AsyncData(null);
      return res.data['msg'] ?? 'Error al registrarse';
    } on DioException catch (e) {
      state = const AsyncData(null);
      return e.response?.data['msg'] ?? 'Error de conexión';
    }
  }

  Future<void> logout() async {
    await _api.post('/api/hub/auth/logout');
    _api.clearToken();
    state = const AsyncData(null);
  }
}
