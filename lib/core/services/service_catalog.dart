import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

const List<int> kDefaultHttpStatusCodes = [
  200,
  201,
  301,
  304,
  400,
  401,
  403,
  404,
  429,
  500,
  502,
  503,
];

const String _envServicesPath = String.fromEnvironment(
  'API_SERVICES_PATH',
  defaultValue: '/services',
);

final serviceCatalogProvider = FutureProvider<ServiceCatalog>((ref) async {
  final repo = ServiceCatalogRepository(ApiClient.instance);
  return repo.fetchCatalog();
});

class ServiceCatalog {
  final List<ApiServiceMetadata> services;
  final String sourcePath;
  final DateTime? generatedAt;

  const ServiceCatalog({
    required this.services,
    this.sourcePath = '',
    this.generatedAt,
  });

  bool get isEmpty => services.isEmpty;

  List<String> get categories {
    final set = <String>{};
    for (final service in services) {
      for (final category in service.categories) {
        if (category.trim().isNotEmpty) set.add(category.trim());
      }
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  List<String> get projects {
    final set = <String>{};
    for (final service in services) {
      if (service.project.trim().isNotEmpty) set.add(service.project.trim());
    }
    final sorted = set.toList()..sort();
    return sorted;
  }

  ApiServiceMetadata? byId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final query = id.trim().toLowerCase();
    for (final service in services) {
      if (service.id.toLowerCase() == query ||
          service.slug.toLowerCase() == query ||
          service.endpoint.toLowerCase() == query) {
        return service;
      }
    }
    return null;
  }

  List<ApiServiceMetadata> relatedFor(ApiServiceMetadata service) {
    final out = <ApiServiceMetadata>[];
    for (final id in service.relatedServiceIds) {
      final related = byId(id);
      if (related != null && related.id != service.id) {
        out.add(related);
      }
    }
    if (out.isNotEmpty) return out;

    // Fallback relation: same category (excluding self).
    return services
        .where((item) =>
            item.id != service.id &&
            item.categories.any(service.categories.contains))
        .take(4)
        .toList();
  }
}

class ApiServiceMetadata {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String project;
  final List<String> categories;
  final List<String> tags;
  final String method;
  final String endpoint;
  final bool requiresAuth;
  final List<ApiServiceParameter> parameters;
  final Map<String, String> codeExamples;
  final String requestExample;
  final String responseExample;
  final List<int> statusCodes;
  final bool sandboxEnabled;
  final List<String> relatedServiceIds;

  const ApiServiceMetadata({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.project,
    required this.categories,
    required this.tags,
    required this.method,
    required this.endpoint,
    required this.requiresAuth,
    required this.parameters,
    required this.codeExamples,
    required this.requestExample,
    required this.responseExample,
    required this.statusCodes,
    required this.sandboxEnabled,
    required this.relatedServiceIds,
  });

  factory ApiServiceMetadata.fromMap(Map<String, dynamic> map) {
    final endpoint = _normalizeEndpoint(
      _toString(_pickFirst(map, const ['endpoint', 'path', 'route', 'url'])),
    );
    final method = _toString(_pickFirst(map, const ['httpMethod', 'method']),
            fallback: 'GET')
        .toUpperCase();

    final rawName = _toString(
      _pickFirst(map, const ['displayName', 'title', 'name']),
      fallback: endpoint.isEmpty ? 'Unnamed Service' : endpoint,
    );

    final id = _slugify(
      _toString(
        _pickFirst(map, const ['id', '_id', 'serviceId', 'slug']),
        fallback: endpoint.isNotEmpty ? endpoint : rawName,
      ),
    );

    final categories = _toStringList(
      _pickFirst(map, const ['categories', 'category']),
    );
    final project = _toString(
      _pickFirst(map, const ['project', 'module', 'domain']),
      fallback: categories.isNotEmpty ? categories.first : 'hub',
    );

    final tags = _toStringList(_pickFirst(map, const ['tags', 'labels']));

    final parameters = _parseParameters(map);

    final requestExample = _normalizeJson(
      _pickFirst(map, const [
        'requestExample',
        'exampleRequest',
        'request',
        'raw.example',
        'example',
      ]),
    );

    final responseExample = _normalizeJson(
      _pickFirst(map, const [
        'responseExample',
        'exampleResponse',
        'response',
        'sampleResponse',
      ]),
    );

    final codeExamples = _parseCodeExamples(
      map: map,
      endpoint: endpoint,
      method: method,
      requestExample: requestExample,
    );

    final statusCodes = _parseStatusCodes(map);

    final description = _toString(
      _pickFirst(map, const ['description', 'summary', 'details']),
      fallback:
          'Servicio $rawName disponible en $endpoint para consumo de APIs.',
    );

    return ApiServiceMetadata(
      id: id,
      slug: _slugify(rawName),
      name: rawName,
      description: description,
      project: project,
      categories: categories,
      tags: tags,
      method: method,
      endpoint: endpoint,
      requiresAuth:
          _toBool(_pickFirst(map, const ['requiresAuth', 'auth.required'])) ??
              false,
      parameters: parameters,
      codeExamples: codeExamples,
      requestExample: requestExample,
      responseExample: responseExample,
      statusCodes: statusCodes,
      sandboxEnabled:
          _toBool(_pickFirst(map, const ['sandbox.enabled', 'isSandbox'])) ??
              true,
      relatedServiceIds:
          _toStringList(_pickFirst(map, const ['related', 'relatedServices'])),
    );
  }

  String get primaryCategory =>
      categories.isNotEmpty ? categories.first : project;

  String get sandboxBodySeed {
    if (requestExample.trim().isNotEmpty) return requestExample;
    final body = <String, dynamic>{};
    for (final param in parameters.where((p) => p.location != 'header')) {
      body[param.name] = param.example.isNotEmpty
          ? param.example
          : _defaultExampleForType(param.type);
    }
    if (body.isEmpty) return '{}';
    return const JsonEncoder.withIndent('  ').convert(body);
  }

  List<int> get visibleStatusCodes {
    final set = <int>{...kDefaultHttpStatusCodes, ...statusCodes};
    final sorted = set.toList()..sort();
    return sorted;
  }
}

class ApiServiceParameter {
  final String name;
  final String type;
  final String description;
  final bool required;
  final String location;
  final String example;

  const ApiServiceParameter({
    required this.name,
    required this.type,
    required this.description,
    required this.required,
    required this.location,
    required this.example,
  });
}

class ServiceCatalogRepository {
  final ApiClient _api;

  const ServiceCatalogRepository(this._api);

  Future<ServiceCatalog> fetchCatalog() async {
    final candidatePaths = <String>{
      if (_envServicesPath.trim().isNotEmpty) _envServicesPath.trim(),
      '/services',
      '/hub/services',
    }.toList();

    for (final path in candidatePaths) {
      try {
        final res = await _api.get<dynamic>(path);
        if (res.statusCode != 200) continue;
        final parsed = _extractServices(res.data);
        if (parsed.isNotEmpty) {
          final generatedAt = _extractGeneratedAt(res.data);
          if (kDebugMode) {
            debugPrint(
              '> serviceCatalog resolved ${parsed.length} services from $path',
            );
          }
          return ServiceCatalog(
            services: _dedupe(parsed),
            sourcePath: path,
            generatedAt: generatedAt,
          );
        }
      } catch (err) {
        if (kDebugMode) {
          debugPrint('> serviceCatalog endpoint failed at $path: $err');
        }
      }
    }

    if (kDebugMode) {
      debugPrint('> serviceCatalog no central endpoint resolved');
    }
    return const ServiceCatalog(services: []);
  }

  DateTime? _extractGeneratedAt(dynamic raw) {
    if (raw is! Map) return null;
    final map = _toMap(raw) ?? const <String, dynamic>{};
    final value = _pickFirst(map, const ['generatedAt', 'data.generatedAt']);
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  List<ApiServiceMetadata> _extractServices(dynamic raw) {
    final list = _extractList(raw);
    return list
        .map(_toMap)
        .whereType<Map<String, dynamic>>()
        .map(ApiServiceMetadata.fromMap)
        .where(_isPublicService)
        .toList();
  }

  List<ApiServiceMetadata> _dedupe(List<ApiServiceMetadata> input) {
    final byId = <String, ApiServiceMetadata>{};
    for (final service in input) {
      byId[service.id] = service;
    }
    final values = byId.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return values;
  }
}

List<dynamic> _extractList(dynamic raw) {
  if (raw is List) return raw;
  if (raw is! Map) return const [];

  final map = _toMap(raw) ?? const <String, dynamic>{};

  final direct = _pickFirst(map, const [
    'services',
    'data',
    'items',
    'routes',
    'data.services',
    'data.items',
    'data.routes',
  ]);
  if (direct is List) return direct;

  // Some APIs return an object keyed by id.
  if (direct is Map) {
    return direct.values.toList();
  }

  return const [];
}

bool _isPublicService(ApiServiceMetadata service) {
  final endpoint = service.endpoint.toLowerCase();
  final name = service.name.toLowerCase();
  final tags = service.tags.join(' ').toLowerCase();

  if (endpoint.contains('/webhook')) return false;
  if (name.contains('webhook')) return false;
  if (tags.contains('webhook')) return false;
  return true;
}

List<ApiServiceParameter> _parseParameters(Map<String, dynamic> map) {
  final raw = _pickFirst(map, const [
    'parameters',
    'params',
    'parameter',
    'bodyParams',
    'input',
  ]);

  if (raw is List) {
    final output = <ApiServiceParameter>[];
    for (final item in raw) {
      if (item is String) {
        output.add(ApiServiceParameter(
          name: item,
          type: 'string',
          description: '',
          required: true,
          location: 'body',
          example: '',
        ));
        continue;
      }
      final mapItem = _toMap(item);
      if (mapItem == null) continue;
      output.add(ApiServiceParameter(
        name: _toString(_pickFirst(mapItem, const ['name', 'key'])),
        type:
            _toString(_pickFirst(mapItem, const ['type']), fallback: 'string'),
        description: _toString(
          _pickFirst(mapItem, const ['description', 'desc', 'label']),
        ),
        required:
            _toBool(_pickFirst(mapItem, const ['required', 'isRequired'])) ??
                false,
        location: _toString(
          _pickFirst(mapItem, const ['location', 'in']),
          fallback: 'body',
        ),
        example:
            _normalizeJson(_pickFirst(mapItem, const ['example', 'value'])),
      ));
    }
    return output.where((item) => item.name.trim().isNotEmpty).toList();
  }

  if (raw is Map) {
    final output = <ApiServiceParameter>[];
    for (final entry in raw.entries) {
      output.add(ApiServiceParameter(
        name: entry.key,
        type: 'string',
        description: '',
        required: true,
        location: 'body',
        example: _normalizeJson(entry.value),
      ));
    }
    return output;
  }

  return const [];
}

Map<String, String> _parseCodeExamples({
  required Map<String, dynamic> map,
  required String endpoint,
  required String method,
  required String requestExample,
}) {
  final examples = <String, String>{};

  final rawExamples =
      _pickFirst(map, const ['examples', 'codeExamples', 'snippets']);

  if (rawExamples is Map) {
    for (final entry in rawExamples.entries) {
      final key = _toString(entry.key).trim().toLowerCase();
      final value = _normalizeJson(entry.value);
      if (key.isNotEmpty && value.trim().isNotEmpty) {
        examples[key] = value;
      }
    }
  }

  if (examples.isNotEmpty) return examples;
  return _buildDefaultExamples(
    endpoint: endpoint,
    method: method,
    requestExample: requestExample,
  );
}

Map<String, String> _buildDefaultExamples({
  required String endpoint,
  required String method,
  required String requestExample,
}) {
  final upper = method.toUpperCase();
  final hasBody = upper != 'GET';
  final url = ApiClient.buildAbsoluteUrl(endpoint);
  final normalizedBody = _compactJsonOrEmpty(requestExample);

  final curl = hasBody
      ? 'curl -X $upper "$url" '
          '-H "Authorization: Bearer <token>" '
          '-H "Content-Type: application/json" '
          '-d \'$normalizedBody\''
      : 'curl -X $upper "$url" '
          '-H "Authorization: Bearer <token>" '
          '-H "Content-Type: application/json"';

  final nodeJs = hasBody
      ? "const response = await fetch('$url', {\n"
          "  method: '$upper',\n"
          "  headers: {\n"
          "    'Authorization': 'Bearer <token>',\n"
          "    'Content-Type': 'application/json',\n"
          "  },\n"
          "  body: JSON.stringify($normalizedBody),\n"
          "});\n"
          "const data = await response.json();\n"
          "console.log(data);"
      : "const response = await fetch('$url', {\n"
          "  method: '$upper',\n"
          "  headers: {\n"
          "    'Authorization': 'Bearer <token>',\n"
          "    'Content-Type': 'application/json',\n"
          "  },\n"
          "});\n"
          "const data = await response.json();\n"
          "console.log(data);";

  final python = hasBody
      ? "import requests\n\n"
          "response = requests.request(\n"
          "    '$upper',\n"
          "    '$url',\n"
          "    headers={\n"
          "        'Authorization': 'Bearer <token>',\n"
          "        'Content-Type': 'application/json',\n"
          "    },\n"
          "    json=$normalizedBody,\n"
          ")\n"
          "print(response.json())"
      : "import requests\n\n"
          "response = requests.request(\n"
          "    '$upper',\n"
          "    '$url',\n"
          "    headers={\n"
          "        'Authorization': 'Bearer <token>',\n"
          "        'Content-Type': 'application/json',\n"
          "    },\n"
          ")\n"
          "print(response.json())";

  return {
    'curl': curl,
    'nodejs': nodeJs,
    'python': python,
    'javascript': nodeJs,
  };
}

String _compactJsonOrEmpty(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '{}';
  try {
    return jsonEncode(jsonDecode(trimmed));
  } catch (_) {
    return '{}';
  }
}

List<int> _parseStatusCodes(Map<String, dynamic> map) {
  final output = <int>{};

  final direct = _pickFirst(map, const ['statusCodes', 'httpStatusCodes']);
  if (direct is List) {
    for (final item in direct) {
      final code = _toInt(item);
      if (code != null) output.add(code);
    }
  }

  final responses = _pickFirst(map, const ['responses', 'responseMap']);
  if (responses is Map) {
    for (final key in responses.keys) {
      final code = _toInt(key);
      if (code != null) output.add(code);
    }
  }

  return output.isEmpty ? kDefaultHttpStatusCodes : output.toList()
    ..sort();
}

String _defaultExampleForType(String type) {
  final t = type.toLowerCase();
  if (t.contains('int') || t.contains('number')) return '1';
  if (t.contains('bool')) return 'true';
  if (t.contains('array') || t.contains('list')) return '[]';
  if (t.contains('object') || t.contains('map')) return '{}';
  return 'sample';
}

Map<String, dynamic>? _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, dynamic item) => MapEntry(key.toString(), item),
    );
  }
  return null;
}

String _toString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final str = value.toString().trim();
  return str.isEmpty ? fallback : str;
}

List<String> _toStringList(dynamic value) {
  if (value == null) return const [];
  if (value is String) {
    final parts = value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    parts.sort();
    return parts;
  }
  if (value is List) {
    final out = value
        .map((item) => _toString(item))
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    out.sort();
    return out;
  }
  return const [];
}

String _normalizeEndpoint(String raw) {
  if (raw.trim().isEmpty) return '/';
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    final uri = Uri.tryParse(raw);
    if (uri != null) return uri.path.isEmpty ? '/' : uri.path;
  }
  if (raw.startsWith('/')) return raw;
  return '/$raw';
}

String _normalizeJson(dynamic value) {
  if (value == null) return '';
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    try {
      final decoded = jsonDecode(trimmed);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return trimmed;
    }
  }
  try {
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}

dynamic _pickFirst(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = _readPath(map, key);
    if (value != null) return value;
  }
  return null;
}

dynamic _readPath(Map<String, dynamic> map, String path) {
  if (!path.contains('.')) return map[path];
  dynamic current = map;
  for (final part in path.split('.')) {
    if (current is Map && current.containsKey(part)) {
      current = current[part];
      continue;
    }
    return null;
  }
  return current;
}

bool? _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String _slugify(String input) {
  final lower = input.toLowerCase();
  final cleaned = lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return cleaned.isEmpty ? 'service' : cleaned;
}
