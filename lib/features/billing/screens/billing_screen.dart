import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';

final _plansProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await ApiClient.instance.get('/api/hub/billing/plans');
  if (res.data['status'] == true) return List<Map<String, dynamic>>.from(res.data['data']);
  return _defaultPlans;
});

const _defaultPlans = [
  {'id': 'p50', 'name': '50 solicitudes', 'credits': 50, 'price': '1.50', 'currency': 'USD'},
  {'id': 'p100', 'name': '100 solicitudes', 'credits': 100, 'price': '2.50', 'currency': 'USD'},
  {'id': 'p250', 'name': '250 solicitudes', 'credits': 250, 'price': '5.00', 'currency': 'USD'},
  {'id': 'p500', 'name': '500 solicitudes', 'credits': 500, 'price': '9.00', 'currency': 'USD'},
  {'id': 'p1000', 'name': '1000 solicitudes', 'credits': 1000, 'price': '15.00', 'currency': 'USD'},
  {'id': 'weekly', 'name': 'Semanal ilimitado', 'credits': -1, 'price': '20.00', 'currency': 'USD', 'badge': 'Popular'},
];

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String? _selected;
  bool _purchasing = false;
  String? _paymentUrl;
  bool _showCustom = false;
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  Future<void> _purchase() async {
    if (_selected == null && _customCtrl.text.isEmpty) return;
    setState(() => _purchasing = true);
    final customCredits = int.tryParse(_customCtrl.text);
    try {
      final res = await ApiClient.instance.post('/api/hub/billing/purchase', data: {
        'planId': _selected,
        if (customCredits != null) 'customCredits': customCredits,
      });
      if (res.data['status'] == true) {
        final url = res.data['data']['paymentUrl'] as String?;
        setState(() { _paymentUrl = url; _purchasing = false; });
      } else {
        setState(() => _purchasing = false);
      }
    } catch (_) {
      setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final plans = ref.watch(_plansProvider);

    return Scaffold(
      backgroundColor: ext.bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('\$ ', style: TextStyle(color: ext.primary, fontSize: 13)),
              Text('billing', style: TextStyle(color: ext.text, fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text('Gestiona tus créditos y suscripciones', style: TextStyle(color: ext.textMuted, fontSize: 12)),
            const SizedBox(height: 20),

            // Current balance
            GlowCard(
              child: Row(
                children: [
                  Icon(Icons.bolt, size: 28, color: ext.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Balance actual', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                      Text('${user?.credits ?? 0} solicitudes disponibles',
                          style: TextStyle(color: ext.text, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: ext.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text((user?.plan ?? 'FREE').toUpperCase(), style: TextStyle(color: ext.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('Selecciona un paquete', style: TextStyle(color: ext.text, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            plans.when(
              loading: () => Center(child: CircularProgressIndicator(color: ext.primary)),
              error: (_, __) => const SizedBox(),
              data: (list) => GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
                children: list.asMap().entries.map((e) => _PlanCard(
                  plan: e.value,
                  selected: _selected == e.value['id'],
                  onTap: () => setState(() => _selected = e.value['id']),
                ).animate(delay: (e.key * 60).ms).fadeIn().slideY(begin: 0.1)).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Custom amount
            GestureDetector(
              onTap: () => setState(() => _showCustom = !_showCustom),
              child: Row(children: [
                Icon(_showCustom ? Icons.expand_less : Icons.add_circle_outline, size: 16, color: ext.primary),
                const SizedBox(width: 8),
                Text('Cantidad personalizada', style: TextStyle(color: ext.primary, fontSize: 13)),
              ]),
            ),
            if (_showCustom) ...[
              const SizedBox(height: 10),
              TerminalInput(
                controller: _customCtrl,
                hint: 'Ej: 750',
                prefix: 'credits:',
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _purchase(),
              ),
              const SizedBox(height: 4),
              Builder(builder: (ctx) {
                final n = int.tryParse(_customCtrl.text) ?? 0;
                return Text('Precio estimado: \$${(n * 0.015).toStringAsFixed(2)} USD',
                    style: TextStyle(color: ext.textMuted, fontSize: 11));
              }),
            ],

            const SizedBox(height: 20),

            // Payment section
            if (_paymentUrl != null) ...[
              GlowCard(
                useAltGlow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.currency_bitcoin, color: ext.terminalYellow),
                      const SizedBox(width: 8),
                      Text('Pago con criptomonedas', style: TextStyle(color: ext.text, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 10),
                    Text('URL de pago generada:', style: TextStyle(color: ext.textMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    SelectableText(_paymentUrl!, style: TextStyle(color: ext.accentAlt, fontSize: 12, fontFamily: 'JetBrainsMono')),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_new, size: 14),
                      label: const Text('Ir al pago'),
                      onPressed: () async {
                        final uri = Uri.tryParse(_paymentUrl!);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: (_selected == null || _purchasing) ? null : _purchase,
                  icon: _purchasing
                      ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ext.onPrimary))
                      : const Icon(Icons.currency_bitcoin, size: 16),
                  label: const Text('Pagar con criptomoneda'),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Text(
              'Pagos procesados de forma segura via Cryptomus. Comisiones bajas, sin datos de tarjeta.',
              style: TextStyle(color: ext.textMuted, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({required this.plan, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final badge = plan['badge'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? ext.primary.withValues(alpha: 0.1) : ext.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? ext.primary : ext.border, width: selected ? 1.5 : 1),
          boxShadow: selected ? [BoxShadow(color: ext.glow, blurRadius: 12)] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(color: ext.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
              child: Text(badge, style: TextStyle(color: ext.warning, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            Text(plan['name'], style: TextStyle(color: ext.text, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('\$${plan['price']} ${plan['currency']}',
                style: TextStyle(color: ext.primary, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'JetBrainsMono')),
            if (plan['credits'] != -1)
              Text('${plan['credits']} créditos', style: TextStyle(color: ext.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
