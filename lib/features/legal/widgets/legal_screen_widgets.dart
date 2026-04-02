part of '../screens/legal_screen.dart';

class StickyTocBuilder extends StatelessWidget {
  final String title;
  final List<LegalSection> sections;
  final void Function(int) onTap;
  final AuralixThemeExtension theme;

  const StickyTocBuilder({
    super.key,
    required this.title,
    required this.sections,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: theme.surfaceDecoration.copyWith(
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt, size: 16, color: theme.textMuted),
              const SizedBox(width: 8),
              Text(
                'TOC // $title',
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 12,
                  fontFamily: 'JetBrainsMono',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(sections.length, (index) {
            return InkWell(
              onTap: () => onTap(index),
              borderRadius: BorderRadius.circular(6),
              hoverColor: theme.primary.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  sections[index].heading,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 13,
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class HoverLegalSection extends StatefulWidget {
  final LegalSection section;
  const HoverLegalSection({super.key, required this.section});

  @override
  State<HoverLegalSection> createState() => _HoverLegalSectionState();
}

class _HoverLegalSectionState extends State<HoverLegalSection> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: ext.surfaceDecoration.copyWith(
          border: Border.all(
            color: _hovering ? ext.primary.withValues(alpha: 0.5) : ext.border,
            width: 1,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                      color: ext.primary.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: -2)
                ]
              : [],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '> ',
                  style: TextStyle(
                    color: _hovering ? ext.primary : ext.textMuted,
                    fontSize: 18,
                    fontFamily: 'JetBrainsMono',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.section.heading,
                    style: TextStyle(
                      color: _hovering ? ext.primary : ext.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'JetBrainsMono',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.section.body,
              style: TextStyle(
                color: ext.textMuted,
                fontSize: 14,
                height: 1.75,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalContent {
  final String title;
  final List<LegalSection> sections;
  const _LegalContent({required this.title, required this.sections});
}

class LegalSection {
  final String heading, body;
  const LegalSection(this.heading, this.body);
}

const _terms = _LegalContent(title: 'TÃ©rminos y Condiciones', sections: [
  LegalSection('1. AceptaciÃ³n',
      'Al acceder y utilizar Auralix Hub, aceptas cumplir con estos TÃ©rminos y Condiciones. Si no estÃ¡s de acuerdo con alguno de ellos, no debes utilizar la plataforma.'),
  LegalSection('2. Uso del servicio',
      'Auralix Hub proporciona acceso programÃ¡tico a APIs. El usuario se compromete a utilizar el servicio exclusivamente para fines lÃ­citos, respetando todas las leyes aplicables en su jurisdicciÃ³n.'),
  LegalSection('3. CrÃ©ditos y pagos',
      'Los crÃ©ditos adquiridos no son reembolsables salvo error demostrable de nuestra parte. Las solicitudes que resulten en error del servidor (5xx) no descontarÃ¡n crÃ©ditos del usuario.'),
  LegalSection('4. Cuentas',
      'Eres responsable de mantener la confidencialidad de tus credenciales. Reporte inmediatamente cualquier uso no autorizado de tu cuenta.'),
  LegalSection('5. LimitaciÃ³n de responsabilidad',
      'Auralix Hub no serÃ¡ responsable por daÃ±os indirectos, incidentales o consecuentes derivados del uso o la imposibilidad de usar el servicio.'),
  LegalSection('6. Cambios',
      'Nos reservamos el derecho de modificar estos tÃ©rminos en cualquier momento. Los cambios serÃ¡n notificados con al menos 7 dÃ­as de anticipaciÃ³n.'),
]);

const _privacy = _LegalContent(title: 'PolÃ­tica de Privacidad', sections: [
  LegalSection('Datos que recopilamos',
      'Recopilamos: direcciÃ³n de correo electrÃ³nico, direcciÃ³n IP, datos de uso (solicitudes realizadas, timestamps), preferencias de configuraciÃ³n.'),
  LegalSection('Uso de los datos',
      'Los datos se utilizan para: autenticar usuarios, calcular y controlar el consumo de crÃ©ditos, detectar fraude y abuso, mejorar el servicio.'),
  LegalSection('Almacenamiento',
      'Los datos se almacenan en servidores seguros con cifrado en trÃ¡nsito (TLS 1.3) y en reposo. No compartimos tus datos con terceros salvo requerimiento legal.'),
  LegalSection('Tus derechos',
      'Puedes solicitar acceso, correcciÃ³n o eliminaciÃ³n de tus datos en cualquier momento enviando un correo a privacy@auralixpe.xyz.'),
]);

const _usage = _LegalContent(title: 'PolÃ­tica de Uso', sections: [
  LegalSection('Restricciones de API',
      'EstÃ¡ estrictamente prohibido el uso de la API para enviar spam, alojar cÃ³digo malicioso, lanzar ataques DDoS, o cualquier fin que comprometa la integridad de Auralix Hub.'),
  LegalSection('LÃ­mites de Rate (Rate Limiting)',
      'Para proteger la estabilidad del sistema, aplicamos cuotas de llamadas por segundo. Los usuarios que superen estos lÃ­mites recibirÃ¡n cÃ³digos de estado 429.'),
  LegalSection('SuspensiÃ³n de cuenta',
      'Nos reservamos el derecho de suspender o cancelar cuentas que incumplan estas normas sin previo aviso.'),
]);
