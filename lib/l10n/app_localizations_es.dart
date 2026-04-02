// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Auralix Hub';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navDocs => 'Docs';

  @override
  String get navSandbox => 'Sandbox';

  @override
  String get navSnippets => 'Snippets';

  @override
  String get navHistory => 'Historial';

  @override
  String get navBilling => 'Billing';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get layoutResponsiveTitle => 'Diseño adaptativo';

  @override
  String get layoutResponsiveSubtitle =>
      'Optimizado para móvil, tablet y escritorio.';

  @override
  String get commonRequired => 'Obligatorio';

  @override
  String get authLoginModuleTitle => 'Módulo de autenticación';

  @override
  String get authLoginSubtitle =>
      'Ingresa tus credenciales para acceder al hub.';

  @override
  String get authCaptchaRequired => 'Completa la verificación captcha.';

  @override
  String get authNoAccount => '¿No tienes cuenta?';

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authTerms => 'Términos';

  @override
  String get authPrivacy => 'Privacidad';

  @override
  String get authAuthenticate => 'Autenticar';

  @override
  String get authLoginCommand => '~/login.sh --execute';

  @override
  String get authEmailHint => 'usuario@dominio.com';

  @override
  String get authEmailPrefix => 'email:';

  @override
  String get authPasswordHint => '********';

  @override
  String get authPasswordPrefix => 'pass:';

  @override
  String get authRegisterModuleTitle => 'Provisionamiento de cuenta';

  @override
  String get authRegisterCompleteTitle => 'Registro completado';

  @override
  String get authRegisterAccountCreated => 'CUENTA CREADA';

  @override
  String authRegisterVerifyEmailMessage(Object email) {
    return 'Verifica tu correo en:\n$email';
  }

  @override
  String get authProceedToLogin => 'IR A INICIAR SESIÓN';

  @override
  String get authRegisterSubtitle =>
      'Las nuevas cuentas reciben 20 solicitudes gratis y 10 límites de sandbox.';

  @override
  String get authInvalidEmail => 'Correo inválido';

  @override
  String get authRegisterPasswordHint => 'mínimo 8 caracteres';

  @override
  String get authMin8Chars => 'Mínimo 8 caracteres';

  @override
  String get authRegisterConfirmPasswordHint => 'repite la contraseña';

  @override
  String get authRegisterConfirmPrefix => 'verificar:';

  @override
  String get authPasswordMismatch => 'No coincide';

  @override
  String get authProvisionAccount => 'PROVISIONAR CUENTA';

  @override
  String get authExistingUser => '¿YA TIENES USUARIO?';

  @override
  String get authRegisterCommand => '\$ ./provision_user.sh';

  @override
  String get authVerifyTitle => 'Verificación de identidad';

  @override
  String get authVerifyChecking => 'VERIFICANDO FIRMA...';

  @override
  String get authVerifySuccessCode => 'VERIFICACIÓN EXITOSA_200';

  @override
  String get authVerifyErrorCode => 'ERROR_DE_VERIFICACIÓN';

  @override
  String get authVerifySuccessMessage =>
      'Identidad confirmada. Tu cuenta ya está activa.';

  @override
  String get authVerifyInvalidOrExpired => 'El enlace es inválido o expiró.';

  @override
  String get authReturnToLogin => 'VOLVER A INICIAR SESIÓN';

  @override
  String get authVerifyTokenMissing => 'Token faltante o inválido.';

  @override
  String get authVerifyInvalidSignature => 'Firma de token inválida.';

  @override
  String get authVerifyConnectionFailed =>
      'Falló la conexión con la autoridad.';

  @override
  String get authVersionLabel => 'AURALIX HUB v1.0.0-rc';

  @override
  String get authSecureAccessStatus => 'ACCESO_SEGURO';

  @override
  String get authCaptchaEnabledStatus => 'CAPTCHA_ACTIVO';

  @override
  String authSplashVersionLine(Object authority) {
    return 'Hub v1.0.0 - $authority';
  }

  @override
  String get authSplashCoreReady => 'Servicios principales inicializados';

  @override
  String get authSplashSocketReady => 'WebSocket listo y escuchando';

  @override
  String get authSplashWaitingAuth => 'Esperando autenticación...';

  @override
  String get authSplashStartCommand => '\$ auth_subsystem --start';

  @override
  String get captchaLoadFailed => 'No se pudo cargar el captcha';

  @override
  String get captchaValidationFailed => 'No se pudo validar el captcha';

  @override
  String get captchaIncorrectAnswer => 'Respuesta incorrecta';

  @override
  String get captchaTryAgain => 'Error al verificar. Intenta de nuevo.';

  @override
  String get captchaVerified => 'Captcha verificado [OK]';

  @override
  String get captchaSecurityVerification => 'Verificación de seguridad';

  @override
  String get captchaUnavailable => 'Captcha no disponible';

  @override
  String get captchaAnswerHint => 'Respuesta';

  @override
  String get captchaVerify => 'Verificar';

  @override
  String get captchaNew => 'Nuevo captcha';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonConnectionError => 'Error de conexión';

  @override
  String get routerNotFoundTitle => 'Ruta no encontrada';

  @override
  String get routerUnknownError => 'Error desconocido del router';

  @override
  String get routerGoHome => 'Ir al inicio';

  @override
  String get routerOpenDashboard => 'Abrir dashboard';

  @override
  String get settingsLocaleAutoLabel =>
      'Usar idioma del sistema cuando esté disponible.';

  @override
  String get appShellOpenNavigation => 'Abrir navegación';

  @override
  String get appShellNoSession => 'Sin sesión activa';

  @override
  String get appShellPlanLabel => 'Plan';

  @override
  String get appShellLogout => 'Cerrar sesión';

  @override
  String get snippetsAnyLanguage => 'CUALQUIER_LENGUAJE';

  @override
  String get snippetsSubtitle => 'Compartir fragmentos de código seguros P2P';

  @override
  String get snippetsLoadingFragments => 'RECUPERANDO_FRAGMENTOS_DE_RED...';

  @override
  String get snippetsFetchError => 'ERROR_CARGANDO_FRAGMENTOS';

  @override
  String get snippetsEmptyAll => 'NO_SE_ENCONTRARON_FRAGMENTOS';

  @override
  String get snippetsEmptyFiltered => 'NO_HAY_COINCIDENCIAS';

  @override
  String snippetsYieldSummary(Object current, Object total) {
    return 'RESULTADO: $current/$total FRAGMENTOS';
  }

  @override
  String get snippetsCreateAbort => 'CANCELAR';

  @override
  String get snippetsCreateNew => 'NUEVO_FRAG';

  @override
  String get snippetsSearchHint => 'BUSCAR EN BD...';

  @override
  String get snippetsSecureOnly => 'SOLO_SEGUROS';

  @override
  String get snippetsResetFilters => 'RESETEAR';

  @override
  String get snippetsUntitled => 'FRAG_SIN_TITULO';

  @override
  String get snippetsEncrypted => 'ENCRIPTADO';

  @override
  String get snippetsCopyUrl => 'COPIAR_URL';

  @override
  String get snippetsCopyUrlSuccess => 'URL GUARDADA EN PORTAPAPELES';

  @override
  String get snippetsValidationTitleCodeRequired =>
      'SE_REQUIERE_TITULO_Y_CODIGO';

  @override
  String get snippetsNetworkTimeout => 'TIMEOUT_DE_RED';

  @override
  String get snippetsCreateTitle => 'SUBIR_NUEVO_FRAGMENTO';

  @override
  String get snippetsTitleHint => 'ej. payload de bypass del servidor';

  @override
  String get snippetsTitlePrefix => 'titulo:';

  @override
  String snippetsLanguageOption(Object language) {
    return 'lang: $language';
  }

  @override
  String get snippetsCodeHint => '// Inyecta payload aqui...';

  @override
  String get snippetsRequireDecryptionKey => 'REQUERIR_LLAVE_DE_DESCIFRADO';

  @override
  String get snippetsEncryptionKeyHint => 'llave de cifrado';

  @override
  String get snippetsEncryptionKeyPrefix => 'clave:';

  @override
  String get snippetsExecute => 'EJECUTAR';

  @override
  String get docsLoadErrorTitle => 'No se pudo cargar la documentación técnica';

  @override
  String get docsNoApisTitle => 'No hay APIs del proyecto en el catálogo';

  @override
  String get docsNoApisSubtitle =>
      'El catálogo respondió, pero no se encontraron endpoints Hub. Revisa metadata project/category o rutas /hub/*.';

  @override
  String get docsServiceNotFoundTitle => 'Servicio no encontrado en docs';

  @override
  String get docsServiceNotFoundSubtitle =>
      'La ruta no coincide con un endpoint del proyecto Hub. Vuelve al índice de /docs.';

  @override
  String get docsIndexSubtitle => 'Índice principal de APIs del proyecto Hub';

  @override
  String docsServicesCount(Object count) {
    return '$count servicios';
  }

  @override
  String get docsSearchHint => 'Buscar endpoint, método o tag';

  @override
  String get docsAllCategories => 'Todas las categorías';

  @override
  String get docsNoResultsTitle => 'Sin resultados para este filtro';

  @override
  String get docsNoResultsSubtitle =>
      'Prueba otra categoría o limpia la búsqueda para ver todos los endpoints.';

  @override
  String docsDetailsSubtitle(Object name) {
    return 'Documentación técnica de $name';
  }

  @override
  String get docsIndexButton => 'Índice';

  @override
  String get docsActiveServiceLabel => 'servicio activo';

  @override
  String get docsOpenButton => 'Abrir';

  @override
  String get docsAuthChip => 'auth';

  @override
  String get docsSourceLabel => 'fuente';

  @override
  String get docsCredentialsTitle => 'Credenciales para este endpoint';

  @override
  String get docsRequiredHeadersSection => 'Headers requeridos';

  @override
  String get docsContentTypeDescription => 'Tipo de contenido enviado a la API';

  @override
  String get docsAuthorizationDescription => 'Autenticación de la cuenta';

  @override
  String get docsParamsByLocationSection => 'Parámetros por ubicación';

  @override
  String get docsNoExplicitParams =>
      'Este servicio no define parámetros explícitos en metadata.';

  @override
  String get docsCodeExamplesSection => 'Ejemplos de código';

  @override
  String get docsResponseSuccessSection => 'Respuesta exitosa - 200 OK';

  @override
  String get docsStatusCodesSection => 'Códigos de estado';

  @override
  String get docsTrySandboxWithSession =>
      'Probar en Sandbox (requiere sesión activa)';

  @override
  String get docsTrySandbox => 'Probar en Sandbox';

  @override
  String get docsRelatedServicesSection => 'Servicios relacionados';

  @override
  String get docsRequiredBadge => 'obligatorio';

  @override
  String get docsNoSnippetsMessage =>
      'Este servicio aún no publica snippets reales. Inicia sesión y ejecuta pruebas en Sandbox para obtener respuestas reales.';

  @override
  String get docsCopyTooltip => 'Copiar';

  @override
  String get docsCopyResponseTooltip => 'Copiar respuesta';

  @override
  String get sandboxBootBanner => 'Auralix Hub Sandbox v1.0';

  @override
  String get sandboxBootReady => 'Sistema inicializado. Entorno listo.';

  @override
  String sandboxPresetLoaded(Object service, Object method, Object path) {
    return 'Preset cargado para $service -> [$method $path]';
  }

  @override
  String sandboxHistoryRestored(Object method, Object path) {
    return 'Snapshot restaurado: $method $path';
  }

  @override
  String sandboxPartialRestored(Object method, Object path) {
    return 'Layout parcial restaurado: $method $path';
  }

  @override
  String sandboxMissingRequired(Object name) {
    return 'Falta parametro obligatorio: $name';
  }

  @override
  String sandboxRuntimeError(Object error) {
    return 'Error de ejecucion: $error';
  }

  @override
  String get sandboxSubtitle =>
      'Entorno de control iterativo y pruebas en memoria';

  @override
  String sandboxLocalCredits(Object count) {
    return '$count CREDITOS LOCALES';
  }

  @override
  String get sandboxActiveCredentialsTitle => 'Credenciales activas inyectadas';

  @override
  String get sandboxCatalogSelectionLabel => 'SELECCION DE CATALOGO:';

  @override
  String get sandboxCustomHeadersToggle => 'Cabeceras personalizadas';

  @override
  String get sandboxInjectedHeadersLabel => 'HEADERS INYECTADOS';

  @override
  String get sandboxAddHeader => 'AGREGAR NUEVO';

  @override
  String get sandboxHeaderKeyHint => 'Clave';

  @override
  String get sandboxHeaderValueHint => 'Valor';

  @override
  String get sandboxNoDeclaredParams =>
      '> SIN PARAMETROS DECLARADOS EN LA FIRMA';

  @override
  String get sandboxPayloadVariables => 'VARIABLES Y CUERPO [PAYLOAD]';

  @override
  String get sandboxExecuting => 'EJECUTANDO';

  @override
  String get sandboxExecute => 'EJECUTAR';

  @override
  String get sandboxRequiredBadge => 'REQ';

  @override
  String sandboxInsertPayloadHint(Object name) {
    return 'Inserta payload para $name';
  }

  @override
  String get sandboxHistoryTitle => 'HISTORIAL DE EJECUCIONES [LOCAL_STORAGE]';

  @override
  String sandboxCachedCount(Object count) {
    return '$count EN CACHE';
  }

  @override
  String get sandboxStatusError => 'ERR';

  @override
  String get historySubtitle => 'Registro técnico de solicitudes y respuestas';

  @override
  String historyRecordsInView(Object count) {
    return '$count registros en esta vista';
  }

  @override
  String get historyFilterAll => 'todo';

  @override
  String get historyFilterSuccess => 'éxito';

  @override
  String get historyFilterError => 'error';

  @override
  String get historyFilterSandbox => 'sandbox';

  @override
  String get historyNoRequestsInCategory =>
      'No hay solicitudes en esta categoría';

  @override
  String historyCredit(Object value) {
    return 'Crédito: $value';
  }

  @override
  String get historyEnvironmentSandbox => 'sandbox';

  @override
  String get historyEnvironmentProduction => 'producción';

  @override
  String get historyColumnMethod => 'MÉTODO';

  @override
  String get historyColumnStatus => 'ESTADO';

  @override
  String get historyColumnEndpoint => 'ENDPOINT';

  @override
  String get historyColumnTime => 'TIEMPO';

  @override
  String get historyColumnCredit => 'CRÉDITO';

  @override
  String get requestLogsLiveTitle => 'logs en tiempo real';

  @override
  String get requestLogsLiveBadge => 'LIVE';

  @override
  String get requestLogsRefresh => 'Actualizar';

  @override
  String get requestLogsEmpty => 'Ninguna solicitud aún';

  @override
  String get settingsPageSubtitle => 'Configuración interactiva del sistema';

  @override
  String get settingsOperatorProfileTitle => 'Perfil de operador';

  @override
  String get settingsEmailVerified => 'ESTADO: VERIFICADO';

  @override
  String get settingsEmailNotVerified => 'ESTADO: NO VERIFICADO';

  @override
  String get settingsPublicAlias => 'IDENTIFICADOR PÚBLICO';

  @override
  String get settingsAliasHint => 'Ingresa tu identificador (alias)';

  @override
  String get settingsAliasPrefix => 'alias:';

  @override
  String get settingsUpdateProfile => 'ACTUALIZAR DATOS';

  @override
  String get settingsThemeMatrixTitle => 'Matriz visual [temas]';

  @override
  String get settingsThemeActive => '[ACTIVO]';

  @override
  String get settingsThemeInactive => 'INACTIVO';

  @override
  String get settingsDesignTokensTitle => 'Tokens de diseño';

  @override
  String get settingsApiCredentialsTitle => 'Credenciales API';

  @override
  String get settingsSessionTokenPanelTitle => 'Token de sesión interceptado';

  @override
  String get settingsCriticalDirectivesTitle => 'Directivas críticas';

  @override
  String get settingsTerminateSessionTitle => 'TERMINAR SESIÓN';

  @override
  String get settingsTerminateSessionDescription =>
      'Cierra todos los accesos en el nodo actual y destruye el token en memoria.';

  @override
  String get settingsPurgeButton => 'PURGAR';

  @override
  String get settingsProfileSaved =>
      'Perfil actualizado correctamente en la red.';

  @override
  String get settingsProfileSaveError => 'Fallo de integridad de datos.';

  @override
  String get settingsProfileTimeout =>
      'ERR_CONNECTION: Timeout operando perfil.';
}
