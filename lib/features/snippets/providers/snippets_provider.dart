import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

final snippetsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiClient.instance.get('/hub/snippets');
  if (res.data['status'] == true) {
    return List<Map<String, dynamic>>.from(res.data['data']);
  }
  return [];
});
