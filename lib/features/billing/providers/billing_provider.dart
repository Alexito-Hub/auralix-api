import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

final billingPlansProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final res = await ApiClient.instance.get('/hub/billing/plans');
    final body = res.data;
    if (body is Map && body['status'] == true) {
      final data = body['data'];
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      if (data is Map && data['plans'] is List) {
        return List<Map<String, dynamic>>.from(data['plans']);
      }
    }
  } catch (_) {}
  return billingDefaultPlans;
});

const billingDefaultPlans = [
  {
    'id': 'p50',
    'name': '50 solicitudes',
    'credits': 50,
    'price': 1.50,
    'currency': 'USD'
  },
  {
    'id': 'p100',
    'name': '100 solicitudes',
    'credits': 100,
    'price': 2.50,
    'currency': 'USD'
  },
  {
    'id': 'p250',
    'name': '250 solicitudes',
    'credits': 250,
    'price': 5.00,
    'currency': 'USD'
  },
  {
    'id': 'p500',
    'name': '500 solicitudes',
    'credits': 500,
    'price': 9.00,
    'currency': 'USD'
  },
  {
    'id': 'p1000',
    'name': '1000 solicitudes',
    'credits': 1000,
    'price': 15.00,
    'currency': 'USD'
  },
  {
    'id': 'weekly',
    'name': 'Semanal ilimitado',
    'credits': -1,
    'price': 20.00,
    'currency': 'USD',
    'badge': 'Popular'
  },
];
