import 'package:flutter/material.dart';
import '../../../core/theme/theme_extension.dart';

enum LegalPage { terms, privacy, usage }

class LegalScreen extends StatelessWidget {
  final LegalPage page;
  const LegalScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    final ext = AuralixThemeExtension.of(context);
    final content = _content(page);

    return Scaffold(
      backgroundColor: ext.bg,
      appBar: AppBar(
        backgroundColor: ext.surface,
        title: Text(content.title, style: TextStyle(color: ext.text, fontSize: 16, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: ext.text),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: ext.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Última actualización: Marzo 2025',
                style: TextStyle(color: ext.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 24),
              ...content.sections.map((s) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.heading,
                      style: TextStyle(color: ext.text, fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(s.body,
                      style: TextStyle(color: ext.textMuted, fontSize: 13, height: 1.7)),
                  const SizedBox(height: 24),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }

  _LegalContent _content(LegalPage p) => switch (p) {
    LegalPage.terms => _terms,
    LegalPage.privacy => _privacy,
    LegalPage.usage => _usage,
  };
}

class _LegalContent {
  final String title;
  final List<_LegalSection> sections;
  const _LegalContent({required this.title, required this.sections});
}

class _LegalSection {
  final String heading, body;
  const _LegalSection(this.heading, this.body);
}

const _terms = _LegalContent(title: 'Términos y Condiciones', sections: [
  _LegalSection('1. Aceptación', 'Al acceder y utilizar Auralix Hub, aceptas cumplir con estos Términos y Condiciones. Si no estás de acuerdo con alguno de ellos, no debes utilizar la plataforma.'),
  _LegalSection('2. Uso del servicio', 'Auralix Hub proporciona acceso programático a APIs. El usuario se compromete a utilizar el servicio exclusivamente para fines lícitos, respetando todas las leyes aplicables en su jurisdicción.'),
  _LegalSection('3. Créditos y pagos', 'Los créditos adquiridos no son reembolsables salvo error demostrable de nuestra parte. Las solicitudes que resulten en error del servidor (5xx) no descontarán créditos del usuario.'),
  _LegalSection('4. Cuentas', 'Eres responsable de mantener la confidencialidad de tus credenciales. Reporte inmediatamente cualquier uso no autorizado de tu cuenta.'),
  _LegalSection('5. Limitación de responsabilidad', 'Auralix Hub no será responsable por daños indirectos, incidentales o consecuentes derivados del uso o la imposibilidad de usar el servicio.'),
  _LegalSection('6. Cambios', 'Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios serán notificados con al menos 7 días de anticipación.'),
]);

const _privacy = _LegalContent(title: 'Política de Privacidad', sections: [
  _LegalSection('Datos que recopilamos', 'Recopilamos: dirección de correo electrónico, dirección IP, datos de uso (solicitudes realizadas, timestamps), preferencias de configuración.'),
  _LegalSection('Uso de los datos', 'Los datos se utilizan para: autenticar usuarios, calcular y controlar el consumo de créditos, detectar fraude y abuso, mejorar el servicio.'),
  _LegalSection('Almacenamiento', 'Los datos se almacenan en servidores seguros con cifrado en tránsito (TLS 1.3) y en reposo. No compartimos tus datos con terceros salvo requerimiento legal.'),
  _LegalSection('Tus derechos', 'Puedes solicitar acceso, corrección o eliminación de tus datos en cualquier momento enviando un correo a privacy@auralixpe.xyz.'),
  _LegalSection('Cookies', 'Utilizamos cookies de sesión HttpOnly para mantener tu autenticación. No utilizamos cookies de rastreo de terceros.'),
]);

const _usage = _LegalContent(title: 'Política de Uso Aceptable', sections: [
  _LegalSection('Uso permitido', 'El servicio está diseñado para desarrolladores que necesiten acceso programático a APIs de datos. El uso debe ser proporcional y respetuoso de los límites establecidos.'),
  _LegalSection('Uso prohibido', 'Está estrictamente prohibido: uso automatizado masivo, scraping sin permiso, intentos de eludir límites de tasa, uso para actividades ilegales, reventa de créditos o accesos.'),
  _LegalSection('Límites de tasa', 'Cada cuenta tiene límites de solicitudes por ventana de tiempo. El abuso de estos límites puede resultar en suspensión temporal o permanente de la cuenta.'),
  _LegalSection('Aplicación', 'Nos reservamos el derecho de suspender cuentas que violen esta política sin previo aviso y sin reembolso de créditos no utilizados en casos graves.'),
]);
