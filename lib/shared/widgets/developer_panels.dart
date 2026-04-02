import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/theme_extension.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'terminal_widgets.dart';

class ApiCredentialsPanel extends ConsumerWidget {
  final String title;
  final String method;
  final String endpoint;
  final bool requiresAuth;

  const ApiCredentialsPanel({
    super.key,
    required this.title,
    required this.method,
    required this.endpoint,
    this.requiresAuth = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ext = AuralixThemeExtension.of(context);
    final tokenState = ref.watch(authTokenProvider);
    final user = ref.watch(authProvider).valueOrNull;

    final token = tokenState.valueOrNull;
    final hasToken = token != null && token.trim().isNotEmpty;

    final realRequest = _buildRealRequest(
      method: method,
      endpoint: endpoint,
      token: hasToken ? token : '<token>',
    );

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_outlined, size: 16, color: ext.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: ext.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              StatusBadge(
                code: hasToken ? 200 : 401,
                message: hasToken ? 'token activo' : 'sin token',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Todas las solicitudes autenticadas usan un unico Bearer token de sesion.',
            style: TextStyle(color: ext.textMuted, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 12),
          _TokenField(token: token),
          const SizedBox(height: 12),
          if (requiresAuth) ...[
            _CommandBlock(
              label: 'Solicitud autenticada',
              command: realRequest,
            ),
          ] else
            Text(
              'Este endpoint no requiere autenticacion, pero puedes ejecutar sandbox con sesion para trazabilidad y creditos.',
              style: TextStyle(color: ext.textMuted, fontSize: 11.5),
            ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (user != null)
                StatusBadge(
                  code: 200,
                  message: 'creditos: ${user.credits}',
                ),
              if (requiresAuth)
                const StatusBadge(code: 401, message: 'requiere Authorization'),
            ],
          ),
        ],
      ),
    );
  }

  String _buildRealRequest({
    required String method,
    required String endpoint,
    required String token,
  }) {
    return 'curl -X ${method.toUpperCase()} "${ApiClient.buildAbsoluteUrl(endpoint)}" '
        '-H "Authorization: Bearer $token" '
        '-H "Content-Type: application/json"';
  }
}

class _TokenField extends StatelessWidget {
  final String? token;

  const _TokenField({required this.token});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final hasToken = token != null && token!.trim().isNotEmpty;
    final visible =
        hasToken ? _maskToken(token!) : 'Inicia sesion para obtener token';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ext.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ext.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              visible,
              style: TextStyle(
                color: hasToken ? ext.primary : ext.textMuted,
                fontSize: 11.5,
                fontFamily: 'JetBrainsMono',
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: hasToken ? 'Copiar token completo' : 'Sin token activo',
            onPressed: hasToken
                ? () => Clipboard.setData(ClipboardData(text: token!))
                : null,
            icon: const Icon(Icons.copy, size: 15),
          ),
        ],
      ),
    );
  }

  String _maskToken(String raw) {
    final value = raw.trim();
    if (value.length <= 16) return value;
    final start = value.substring(0, 8);
    final end = value.substring(value.length - 8);
    return '$start...$end';
  }
}

class _CommandBlock extends StatelessWidget {
  final String label;
  final String command;

  const _CommandBlock({
    required this.label,
    required this.command,
  });

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: ext.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ext.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ext.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SelectableText(
                  command,
                  style: TextStyle(
                    color: ext.text,
                    fontSize: 11.5,
                    fontFamily: 'JetBrainsMono',
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Copiar comando',
                onPressed: () =>
                    Clipboard.setData(ClipboardData(text: command)),
                icon: const Icon(Icons.copy, size: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DesignTokensPanel extends StatelessWidget {
  const DesignTokensPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    Widget swatch(String name, Color color) {
      return Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ext.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ext.border),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: ext.textMuted,
                  fontSize: 10.5,
                  fontFamily: 'JetBrainsMono',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.token_outlined, size: 16, color: ext.primary),
              const SizedBox(width: 8),
              Text(
                'Design Tokens (ThemeExtension)',
                style: TextStyle(
                  color: ext.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              swatch('primary', ext.primary),
              swatch('secondary', ext.secondary),
              swatch('accent', ext.accent),
              swatch('warning', ext.warning),
              swatch('error', ext.error),
              swatch('surface', ext.surface),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'metrics: space(${ext.spaceXs}, ${ext.spaceSm}, ${ext.spaceMd}, ${ext.spaceLg}, ${ext.spaceXl}) '
            '| radius(${ext.radiusSm}, ${ext.radiusMd}, ${ext.radiusLg}) '
            '| glowBlur(${ext.metrics.glowBlur})',
            style: TextStyle(
              color: ext.textMuted,
              fontSize: 11.5,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}
