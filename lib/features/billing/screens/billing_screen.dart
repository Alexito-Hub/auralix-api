import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_extension.dart';
import '../../../core/network/api_client.dart';
import '../../../core/ui/breakpoints.dart';
import '../../../shared/widgets/terminal_page_layout.dart';
import '../../../shared/widgets/terminal_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/billing_provider.dart';

part '../widgets/billing_screen_widgets.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  String? _selected;
  bool _purchasing = false;
  String? _paymentUrl;
  String? _purchaseError;
  bool _showCustom = false;
  final _customCtrl = TextEditingController();

  int _planCredits(Map<String, dynamic> plan) {
    final value = plan['credits'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? -1;
  }

  double _planPrice(Map<String, dynamic> plan) {
    final value = plan['price'];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  String _planUseCase(int credits) {
    if (credits < 0) return 'Ideal para equipos con uso intensivo diario.';
    if (credits <= 100) return 'Ideal para pruebas y proyectos personales.';
    if (credits <= 500) return 'Ideal para side-projects y equipos pequeÃ±os.';
    return 'Ideal para producciÃ³n y cargas frecuentes.';
  }

  String _money(double amount) => amount.toStringAsFixed(2);

  int? get _customCredits {
    final parsed = int.tryParse(_customCtrl.text.trim());
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  bool get _canPurchase => _selected != null || _customCredits != null;

  @override
  void initState() {
    super.initState();
    _customCtrl.addListener(_onCustomChanged);
  }

  @override
  void dispose() {
    _customCtrl.removeListener(_onCustomChanged);
    _customCtrl.dispose();
    super.dispose();
  }

  void _onCustomChanged() {
    if (!mounted || !_showCustom) return;
    setState(() {
      _selected = null;
      _paymentUrl = null;
      _purchaseError = null;
    });
  }

  Future<void> _purchase() async {
    final customCredits = _customCredits;
    final useCustom = customCredits != null;
    final selectedPlanId = useCustom ? null : _selected;

    if (!useCustom && selectedPlanId == null) {
      setState(() => _purchaseError =
          'Selecciona un paquete o ingresa crÃ©ditos personalizados');
      return;
    }

    setState(() {
      _purchasing = true;
      _purchaseError = null;
      _paymentUrl = null;
    });
    try {
      final res = await ApiClient.instance.post('/hub/billing/purchase', data: {
        'planId': selectedPlanId,
        if (useCustom) 'customCredits': customCredits,
      });
      if (res.data['status'] == true) {
        final data = res.data['data'];
        final url = data is Map ? data['paymentUrl']?.toString() : null;
        setState(() {
          _paymentUrl = url;
          _purchasing = false;
          if (url == null || url.trim().isEmpty) {
            _purchaseError = 'Pago iniciado, pero no se recibiÃ³ URL de pago';
          }
        });
      } else {
        setState(() {
          _purchasing = false;
          _purchaseError =
              res.data['msg']?.toString() ?? 'No se pudo generar el pago';
        });
      }
    } catch (_) {
      setState(() {
        _purchasing = false;
        _purchaseError = 'Error de conexiÃ³n al generar el pago';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final user = ref.watch(authProvider).valueOrNull;
    final plans = ref.watch(billingPlansProvider);
    final hPadding = context.pageHorizontalPadding;
    final maxWidth = context.pageMaxWidth;
    final gridColumns = context.isMobile ? 1 : (context.isTablet ? 2 : 3);
    final isCompact = context.isMobile || context.isTablet;

    return Scaffold(
      backgroundColor: ext.bg,
      body: Stack(
        children: [
          // Cyberpunk Background Glow Effect
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ext.success.withValues(alpha: 0.1),
                    ext.bg.withValues(alpha: 0.0)
                  ],
                  stops: const [0.1, 1.0],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fade(duration: 5.seconds, begin: 0.3, end: 1.0),
          ),

          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPadding, 20, hPadding, 48),
                child: TerminalPageReveal(
                  animationKey: 'billing-main',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TerminalPageHeader(
                        title: 'billing // marketplace',
                        subtitle:
                            'Adquiere y gestiona tus crÃ©ditos de Hub.Aura',
                        actions: [
                          if (user != null)
                            StatusBadge(
                                code: 200,
                                message: 'plan: ${user.plan.toUpperCase()}'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Animated Info Banner
                      AnimatedContainer(
                        duration: 300.ms,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: ext.surfaceDecoration.copyWith(
                          border: Border.all(
                              color: ext.primary.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: ext.primary.withValues(alpha: 0.1),
                                blurRadius: 10,
                                spreadRadius: 0)
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    size: 18, color: ext.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'COMPRA DE CRÃ‰DITOS TRANSPARENTE',
                                  style: TextStyle(
                                      color: ext.text,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'JetBrainsMono'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Conoce el coste exacto por crÃ©dito y obtÃ©n estimaciones precisas para que elijas libremente entre paquetes o cantidades a medida. Sin compromisos ocultos.',
                              style: TextStyle(
                                  color: ext.textMuted,
                                  fontSize: 12,
                                  height: 1.45),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),
                      const SizedBox(height: 24),

                      // Current Balance Hover Card
                      HoverBillingCard(
                        child: isCompact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.bolt,
                                          size: 24, color: ext.success),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('BALANCE EN LÃNEA',
                                                style: TextStyle(
                                                    color: ext.textMuted,
                                                    fontSize: 11,
                                                    fontFamily: 'JetBrainsMono',
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(
                                                '${user?.credits ?? 0} solicitudes disponibles',
                                                style: TextStyle(
                                                    color: ext.success,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        'JetBrainsMono')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color:
                                            ext.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: ext.primary
                                                .withValues(alpha: 0.3))),
                                    child: Text(
                                        (user?.plan ?? 'FREE').toUpperCase(),
                                        style: TextStyle(
                                            color: ext.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ext.success.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: ext.success
                                              .withValues(alpha: 0.3)),
                                    ),
                                    child: Icon(Icons.bolt,
                                        size: 28, color: ext.success),
                                  )
                                      .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true))
                                      .shimmer(
                                          duration: 1.5.seconds,
                                          color: ext.success
                                              .withValues(alpha: 0.8)),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('BALANCE EN LÃNEA',
                                          style: TextStyle(
                                              color: ext.textMuted,
                                              fontSize: 11,
                                              fontFamily: 'JetBrainsMono',
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${user?.credits ?? 0} SOLICITUDES DISPONIBLES',
                                          style: TextStyle(
                                              color: ext.text,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'JetBrainsMono')),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                        color:
                                            ext.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: ext.primary
                                                .withValues(alpha: 0.3))),
                                    child: Text(
                                        'TIPO DE PLAN: ${(user?.plan ?? 'FREE').toUpperCase()}',
                                        style: TextStyle(
                                            color: ext.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'JetBrainsMono')),
                                  ),
                                ],
                              ),
                      ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05),
                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Icon(Icons.layers_outlined,
                              size: 16, color: ext.textMuted),
                          const SizedBox(width: 8),
                          Text('PAQUETES ESTANDARIZADOS',
                              style: TextStyle(
                                  color: ext.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'JetBrainsMono',
                                  letterSpacing: 0.5)),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 16),

                      plans.when(
                        loading: () => SizedBox(
                            height: 120,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: ext.primary))),
                        error: (_, __) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text('No pudimos recuperar los planes',
                                style: TextStyle(color: ext.error))),
                        data: (list) {
                          String? bestValueId;
                          double? bestUnit;
                          for (final plan in list) {
                            final credits = _planCredits(plan);
                            final price = _planPrice(plan);
                            if (credits <= 0 || price <= 0) continue;
                            final unit = price / credits;
                            if (bestUnit == null || unit < bestUnit) {
                              bestUnit = unit;
                              bestValueId = '${plan['id']}';
                            }
                          }

                          return GridView.count(
                            crossAxisCount: gridColumns,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: context.isMobile
                                ? 1.25
                                : (context.isTablet ? 1.1 : 1.25),
                            children: list.asMap().entries.map((e) {
                              final plan = e.value;
                              final credits = _planCredits(plan);
                              return _PlanCard(
                                plan: plan,
                                selected: _selected == plan['id'],
                                bestValue: bestValueId == '${plan['id']}',
                                helperText: _planUseCase(credits),
                                unitPrice: credits > 0
                                    ? _money(_planPrice(plan) / credits)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selected = plan['id'];
                                    _showCustom = false;
                                    _paymentUrl = null;
                                    _purchaseError = null;
                                  });
                                },
                              )
                                  .animate(delay: (250 + (e.key * 75)).ms)
                                  .fadeIn()
                                  .scale(begin: const Offset(0.95, 0.95));
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Icon(Icons.tune, size: 16, color: ext.textMuted),
                          const SizedBox(width: 8),
                          Text('VOLUMEN A MEDIDA',
                              style: TextStyle(
                                  color: ext.text,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'JetBrainsMono',
                                  letterSpacing: 0.5)),
                        ],
                      ).animate().fadeIn(delay: 600.ms),
                      const SizedBox(height: 16),

                      // Custom amount section
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCustom = true;
                            _selected = null;
                            _paymentUrl = null;
                            _purchaseError = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: ext.surfaceDecoration.copyWith(
                            border: Border.all(
                                color: _showCustom ? ext.primary : ext.border,
                                width: _showCustom ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(8),
                            color: _showCustom
                                ? ext.primary.withValues(alpha: 0.05)
                                : ext.surface,
                            boxShadow: _showCustom
                                ? [
                                    BoxShadow(
                                        color:
                                            ext.primary.withValues(alpha: 0.15),
                                        blurRadius: 12)
                                  ]
                                : [],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                      _showCustom
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      size: 18,
                                      color: _showCustom
                                          ? ext.primary
                                          : ext.textMuted),
                                  const SizedBox(width: 10),
                                  Text('CANTIDAD PERSONALIZADA',
                                      style: TextStyle(
                                          color: _showCustom
                                              ? ext.primary
                                              : ext.text,
                                          fontSize: 13,
                                          fontFamily: 'JetBrainsMono',
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              if (_showCustom) ...[
                                const SizedBox(height: 20),
                                TerminalInput(
                                  controller: _customCtrl,
                                  hint: 'Ej: 750',
                                  prefix: 'credits:',
                                  keyboardType: TextInputType.number,
                                  onSubmitted: (_) => _purchase(),
                                ),
                                const SizedBox(height: 12),
                                Builder(builder: (ctx) {
                                  final n = _customCredits ?? 0;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: ext.bg,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: ext.border)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.calculate_outlined,
                                            size: 14, color: ext.textMuted),
                                        const SizedBox(width: 8),
                                        Text(
                                            'EstimaciÃ³n en crudo: â‰ˆ \$${(n * 0.015).toStringAsFixed(2)} USD',
                                            style: TextStyle(
                                                color: ext.textMuted,
                                                fontSize: 12,
                                                fontFamily: 'JetBrainsMono')),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.05),

                      const SizedBox(height: 32),

                      // Payment Actions
                      AnimatedSwitcher(
                        duration: 300.ms,
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeIn,
                        child: _paymentUrl != null
                            ? HoverBillingCard(
                                key: const ValueKey('billing-payment-ready'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.shield_outlined,
                                            color: ext.success, size: 20),
                                        const SizedBox(width: 10),
                                        Text('PASARELA ACTIVA // CRYPTOMUS',
                                            style: TextStyle(
                                                color: ext.success,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'JetBrainsMono')),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text('URL GENERADA Y CIFRADA:',
                                        style: TextStyle(
                                            color: ext.textMuted,
                                            fontSize: 11,
                                            fontFamily: 'JetBrainsMono')),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                          color: ext.bg,
                                          border: Border.all(color: ext.border),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: SelectableText(_paymentUrl!,
                                          style: TextStyle(
                                              color: ext.accentAlt,
                                              fontSize: 12,
                                              fontFamily: 'JetBrainsMono')),
                                    )
                                        .animate(
                                            onPlay: (c) =>
                                                c.repeat(reverse: true))
                                        .shimmer(
                                            duration: 2.seconds,
                                            color: ext.accentAlt
                                                .withValues(alpha: 0.2)),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: ElevatedButton.icon(
                                        icon: const Icon(Icons.open_in_new,
                                            size: 16),
                                        label: const Text(
                                            'REDIRECCIONAR A PAGO',
                                            style: TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5)),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: ext.success,
                                            foregroundColor: Colors.white),
                                        onPressed: () async {
                                          final uri =
                                              Uri.tryParse(_paymentUrl!);
                                          if (uri != null &&
                                              await canLaunchUrl(uri)) {
                                            await launchUrl(uri,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                key: const ValueKey('billing-generate-payment'),
                                width: double.infinity,
                                child: Visibility(
                                  visible: _canPurchase,
                                  child: Opacity(
                                    opacity: _canPurchase ? 1.0 : 0.4,
                                    child: SizedBox(
                                      height: 56,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            (!_canPurchase || _purchasing)
                                                ? null
                                                : _purchase,
                                        icon: _purchasing
                                            ? SizedBox(
                                                height: 18,
                                                width: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: ext.onPrimary))
                                            : const Icon(Icons.currency_bitcoin,
                                                size: 18),
                                        label: Text(
                                            _purchasing
                                                ? 'GENERANDO ORDEN...'
                                                : 'PROCESAR PAGO CRIPTOGRÃFICO',
                                            style: const TextStyle(
                                                fontFamily: 'JetBrainsMono',
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0)),
                                      )
                                          .animate(
                                              target:
                                                  _canPurchase && !_purchasing
                                                      ? 1
                                                      : 0)
                                          .shimmer(
                                              duration: 1.5.seconds,
                                              color: Colors.white
                                                  .withValues(alpha: 0.3)),
                                    ),
                                  ),
                                ),
                              ),
                      ),

                      AnimatedSwitcher(
                        duration: 300.ms,
                        child: _purchaseError == null
                            ? const SizedBox.shrink(
                                key: ValueKey('billing-error-none'))
                            : Padding(
                                key: const ValueKey('billing-error-visible'),
                                padding: const EdgeInsets.only(top: 16),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: ext.error.withValues(alpha: 0.1),
                                    border: Border.all(
                                        color:
                                            ext.error.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.error_outline,
                                          color: ext.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(_purchaseError!,
                                              style: TextStyle(
                                                  color: ext.error,
                                                  fontSize: 12,
                                                  fontFamily:
                                                      'JetBrainsMono'))),
                                    ],
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Transacciones aseguradas vÃ­a Cryptomus. Comisiones ultrabajas. Sin almacenamiento de TDC.',
                          style: TextStyle(
                              color: ext.textSubtle,
                              fontSize: 11,
                              fontFamily: 'JetBrainsMono'),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: 24),
                      Center(
                        child: const Text('EOF',
                                style: TextStyle(
                                    fontFamily: 'JetBrainsMono',
                                    fontSize: 12,
                                    color: Colors.grey))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .fade(duration: 800.ms, begin: 0.3, end: 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
