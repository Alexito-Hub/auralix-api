import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id')
  ];

  /// El título de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Auralix Hub'**
  String get appTitle;

  /// Etiqueta de navegación para dashboard
  ///
  /// In es, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navDocs.
  ///
  /// In es, this message translates to:
  /// **'Docs'**
  String get navDocs;

  /// No description provided for @navSandbox.
  ///
  /// In es, this message translates to:
  /// **'Sandbox'**
  String get navSandbox;

  /// No description provided for @navSnippets.
  ///
  /// In es, this message translates to:
  /// **'Snippets'**
  String get navSnippets;

  /// No description provided for @navHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistory;

  /// No description provided for @navBilling.
  ///
  /// In es, this message translates to:
  /// **'Billing'**
  String get navBilling;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettings;

  /// Título para selector de idioma
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get languageSystem;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesian.
  ///
  /// In es, this message translates to:
  /// **'Indonesio'**
  String get languageIndonesian;

  /// No description provided for @layoutResponsiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Diseño adaptativo'**
  String get layoutResponsiveTitle;

  /// No description provided for @layoutResponsiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Optimizado para móvil, tablet y escritorio.'**
  String get layoutResponsiveSubtitle;

  /// No description provided for @commonRequired.
  ///
  /// In es, this message translates to:
  /// **'Obligatorio'**
  String get commonRequired;

  /// No description provided for @authLoginModuleTitle.
  ///
  /// In es, this message translates to:
  /// **'Módulo de autenticación'**
  String get authLoginModuleTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus credenciales para acceder al hub.'**
  String get authLoginSubtitle;

  /// No description provided for @authCaptchaRequired.
  ///
  /// In es, this message translates to:
  /// **'Completa la verificación captcha.'**
  String get authCaptchaRequired;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta?'**
  String get authNoAccount;

  /// No description provided for @authLogin.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get authRegister;

  /// No description provided for @authTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get authTerms;

  /// No description provided for @authPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get authPrivacy;

  /// No description provided for @authAuthenticate.
  ///
  /// In es, this message translates to:
  /// **'Autenticar'**
  String get authAuthenticate;

  /// No description provided for @authLoginCommand.
  ///
  /// In es, this message translates to:
  /// **'~/login.sh --execute'**
  String get authLoginCommand;

  /// No description provided for @authEmailHint.
  ///
  /// In es, this message translates to:
  /// **'usuario@dominio.com'**
  String get authEmailHint;

  /// No description provided for @authEmailPrefix.
  ///
  /// In es, this message translates to:
  /// **'email:'**
  String get authEmailPrefix;

  /// No description provided for @authPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'********'**
  String get authPasswordHint;

  /// No description provided for @authPasswordPrefix.
  ///
  /// In es, this message translates to:
  /// **'pass:'**
  String get authPasswordPrefix;

  /// No description provided for @authRegisterModuleTitle.
  ///
  /// In es, this message translates to:
  /// **'Provisionamiento de cuenta'**
  String get authRegisterModuleTitle;

  /// No description provided for @authRegisterCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro completado'**
  String get authRegisterCompleteTitle;

  /// No description provided for @authRegisterAccountCreated.
  ///
  /// In es, this message translates to:
  /// **'CUENTA CREADA'**
  String get authRegisterAccountCreated;

  /// Mensaje tras el registro indicando verificar el correo
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo en:\n{email}'**
  String authRegisterVerifyEmailMessage(Object email);

  /// No description provided for @authProceedToLogin.
  ///
  /// In es, this message translates to:
  /// **'IR A INICIAR SESIÓN'**
  String get authProceedToLogin;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las nuevas cuentas reciben 20 solicitudes gratis y 10 límites de sandbox.'**
  String get authRegisterSubtitle;

  /// No description provided for @authInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo inválido'**
  String get authInvalidEmail;

  /// No description provided for @authRegisterPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'mínimo 8 caracteres'**
  String get authRegisterPasswordHint;

  /// No description provided for @authMin8Chars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get authMin8Chars;

  /// No description provided for @authRegisterConfirmPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'repite la contraseña'**
  String get authRegisterConfirmPasswordHint;

  /// No description provided for @authRegisterConfirmPrefix.
  ///
  /// In es, this message translates to:
  /// **'verificar:'**
  String get authRegisterConfirmPrefix;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'No coincide'**
  String get authPasswordMismatch;

  /// No description provided for @authProvisionAccount.
  ///
  /// In es, this message translates to:
  /// **'PROVISIONAR CUENTA'**
  String get authProvisionAccount;

  /// No description provided for @authExistingUser.
  ///
  /// In es, this message translates to:
  /// **'¿YA TIENES USUARIO?'**
  String get authExistingUser;

  /// No description provided for @authRegisterCommand.
  ///
  /// In es, this message translates to:
  /// **'\$ ./provision_user.sh'**
  String get authRegisterCommand;

  /// No description provided for @authVerifyTitle.
  ///
  /// In es, this message translates to:
  /// **'Verificación de identidad'**
  String get authVerifyTitle;

  /// No description provided for @authVerifyChecking.
  ///
  /// In es, this message translates to:
  /// **'VERIFICANDO FIRMA...'**
  String get authVerifyChecking;

  /// No description provided for @authVerifySuccessCode.
  ///
  /// In es, this message translates to:
  /// **'VERIFICACIÓN EXITOSA_200'**
  String get authVerifySuccessCode;

  /// No description provided for @authVerifyErrorCode.
  ///
  /// In es, this message translates to:
  /// **'ERROR_DE_VERIFICACIÓN'**
  String get authVerifyErrorCode;

  /// No description provided for @authVerifySuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Identidad confirmada. Tu cuenta ya está activa.'**
  String get authVerifySuccessMessage;

  /// No description provided for @authVerifyInvalidOrExpired.
  ///
  /// In es, this message translates to:
  /// **'El enlace es inválido o expiró.'**
  String get authVerifyInvalidOrExpired;

  /// No description provided for @authReturnToLogin.
  ///
  /// In es, this message translates to:
  /// **'VOLVER A INICIAR SESIÓN'**
  String get authReturnToLogin;

  /// No description provided for @authVerifyTokenMissing.
  ///
  /// In es, this message translates to:
  /// **'Token faltante o inválido.'**
  String get authVerifyTokenMissing;

  /// No description provided for @authVerifyInvalidSignature.
  ///
  /// In es, this message translates to:
  /// **'Firma de token inválida.'**
  String get authVerifyInvalidSignature;

  /// No description provided for @authVerifyConnectionFailed.
  ///
  /// In es, this message translates to:
  /// **'Falló la conexión con la autoridad.'**
  String get authVerifyConnectionFailed;

  /// No description provided for @authVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'AURALIX HUB v1.0.0-rc'**
  String get authVersionLabel;

  /// No description provided for @authSecureAccessStatus.
  ///
  /// In es, this message translates to:
  /// **'ACCESO_SEGURO'**
  String get authSecureAccessStatus;

  /// No description provided for @authCaptchaEnabledStatus.
  ///
  /// In es, this message translates to:
  /// **'CAPTCHA_ACTIVO'**
  String get authCaptchaEnabledStatus;

  /// Línea de versión en el splash de terminal de auth
  ///
  /// In es, this message translates to:
  /// **'Hub v1.0.0 - {authority}'**
  String authSplashVersionLine(Object authority);

  /// No description provided for @authSplashCoreReady.
  ///
  /// In es, this message translates to:
  /// **'Servicios principales inicializados'**
  String get authSplashCoreReady;

  /// No description provided for @authSplashSocketReady.
  ///
  /// In es, this message translates to:
  /// **'WebSocket listo y escuchando'**
  String get authSplashSocketReady;

  /// No description provided for @authSplashWaitingAuth.
  ///
  /// In es, this message translates to:
  /// **'Esperando autenticación...'**
  String get authSplashWaitingAuth;

  /// No description provided for @authSplashStartCommand.
  ///
  /// In es, this message translates to:
  /// **'\$ auth_subsystem --start'**
  String get authSplashStartCommand;

  /// No description provided for @captchaLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el captcha'**
  String get captchaLoadFailed;

  /// No description provided for @captchaValidationFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo validar el captcha'**
  String get captchaValidationFailed;

  /// No description provided for @captchaIncorrectAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta incorrecta'**
  String get captchaIncorrectAnswer;

  /// No description provided for @captchaTryAgain.
  ///
  /// In es, this message translates to:
  /// **'Error al verificar. Intenta de nuevo.'**
  String get captchaTryAgain;

  /// No description provided for @captchaVerified.
  ///
  /// In es, this message translates to:
  /// **'Captcha verificado [OK]'**
  String get captchaVerified;

  /// No description provided for @captchaSecurityVerification.
  ///
  /// In es, this message translates to:
  /// **'Verificación de seguridad'**
  String get captchaSecurityVerification;

  /// No description provided for @captchaUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Captcha no disponible'**
  String get captchaUnavailable;

  /// No description provided for @captchaAnswerHint.
  ///
  /// In es, this message translates to:
  /// **'Respuesta'**
  String get captchaAnswerHint;

  /// No description provided for @captchaVerify.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get captchaVerify;

  /// No description provided for @captchaNew.
  ///
  /// In es, this message translates to:
  /// **'Nuevo captcha'**
  String get captchaNew;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonConnectionError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión'**
  String get commonConnectionError;

  /// No description provided for @routerNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Ruta no encontrada'**
  String get routerNotFoundTitle;

  /// No description provided for @routerUnknownError.
  ///
  /// In es, this message translates to:
  /// **'Error desconocido del router'**
  String get routerUnknownError;

  /// No description provided for @routerGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get routerGoHome;

  /// No description provided for @routerOpenDashboard.
  ///
  /// In es, this message translates to:
  /// **'Abrir dashboard'**
  String get routerOpenDashboard;

  /// No description provided for @settingsLocaleAutoLabel.
  ///
  /// In es, this message translates to:
  /// **'Usar idioma del sistema cuando esté disponible.'**
  String get settingsLocaleAutoLabel;

  /// No description provided for @appShellOpenNavigation.
  ///
  /// In es, this message translates to:
  /// **'Abrir navegación'**
  String get appShellOpenNavigation;

  /// No description provided for @appShellNoSession.
  ///
  /// In es, this message translates to:
  /// **'Sin sesión activa'**
  String get appShellNoSession;

  /// No description provided for @appShellPlanLabel.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get appShellPlanLabel;

  /// No description provided for @appShellLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get appShellLogout;

  /// No description provided for @snippetsAnyLanguage.
  ///
  /// In es, this message translates to:
  /// **'CUALQUIER_LENGUAJE'**
  String get snippetsAnyLanguage;

  /// No description provided for @snippetsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir fragmentos de código seguros P2P'**
  String get snippetsSubtitle;

  /// No description provided for @snippetsLoadingFragments.
  ///
  /// In es, this message translates to:
  /// **'RECUPERANDO_FRAGMENTOS_DE_RED...'**
  String get snippetsLoadingFragments;

  /// No description provided for @snippetsFetchError.
  ///
  /// In es, this message translates to:
  /// **'ERROR_CARGANDO_FRAGMENTOS'**
  String get snippetsFetchError;

  /// No description provided for @snippetsEmptyAll.
  ///
  /// In es, this message translates to:
  /// **'NO_SE_ENCONTRARON_FRAGMENTOS'**
  String get snippetsEmptyAll;

  /// No description provided for @snippetsEmptyFiltered.
  ///
  /// In es, this message translates to:
  /// **'NO_HAY_COINCIDENCIAS'**
  String get snippetsEmptyFiltered;

  /// No description provided for @snippetsYieldSummary.
  ///
  /// In es, this message translates to:
  /// **'RESULTADO: {current}/{total} FRAGMENTOS'**
  String snippetsYieldSummary(Object current, Object total);

  /// No description provided for @snippetsCreateAbort.
  ///
  /// In es, this message translates to:
  /// **'CANCELAR'**
  String get snippetsCreateAbort;

  /// No description provided for @snippetsCreateNew.
  ///
  /// In es, this message translates to:
  /// **'NUEVO_FRAG'**
  String get snippetsCreateNew;

  /// No description provided for @snippetsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'BUSCAR EN BD...'**
  String get snippetsSearchHint;

  /// No description provided for @snippetsSecureOnly.
  ///
  /// In es, this message translates to:
  /// **'SOLO_SEGUROS'**
  String get snippetsSecureOnly;

  /// No description provided for @snippetsResetFilters.
  ///
  /// In es, this message translates to:
  /// **'RESETEAR'**
  String get snippetsResetFilters;

  /// No description provided for @snippetsUntitled.
  ///
  /// In es, this message translates to:
  /// **'FRAG_SIN_TITULO'**
  String get snippetsUntitled;

  /// No description provided for @snippetsEncrypted.
  ///
  /// In es, this message translates to:
  /// **'ENCRIPTADO'**
  String get snippetsEncrypted;

  /// No description provided for @snippetsCopyUrl.
  ///
  /// In es, this message translates to:
  /// **'COPIAR_URL'**
  String get snippetsCopyUrl;

  /// No description provided for @snippetsCopyUrlSuccess.
  ///
  /// In es, this message translates to:
  /// **'URL GUARDADA EN PORTAPAPELES'**
  String get snippetsCopyUrlSuccess;

  /// No description provided for @snippetsValidationTitleCodeRequired.
  ///
  /// In es, this message translates to:
  /// **'SE_REQUIERE_TITULO_Y_CODIGO'**
  String get snippetsValidationTitleCodeRequired;

  /// No description provided for @snippetsNetworkTimeout.
  ///
  /// In es, this message translates to:
  /// **'TIMEOUT_DE_RED'**
  String get snippetsNetworkTimeout;

  /// No description provided for @snippetsCreateTitle.
  ///
  /// In es, this message translates to:
  /// **'SUBIR_NUEVO_FRAGMENTO'**
  String get snippetsCreateTitle;

  /// No description provided for @snippetsTitleHint.
  ///
  /// In es, this message translates to:
  /// **'ej. payload de bypass del servidor'**
  String get snippetsTitleHint;

  /// No description provided for @snippetsTitlePrefix.
  ///
  /// In es, this message translates to:
  /// **'titulo:'**
  String get snippetsTitlePrefix;

  /// No description provided for @snippetsLanguageOption.
  ///
  /// In es, this message translates to:
  /// **'lang: {language}'**
  String snippetsLanguageOption(Object language);

  /// No description provided for @snippetsCodeHint.
  ///
  /// In es, this message translates to:
  /// **'// Inyecta payload aqui...'**
  String get snippetsCodeHint;

  /// No description provided for @snippetsRequireDecryptionKey.
  ///
  /// In es, this message translates to:
  /// **'REQUERIR_LLAVE_DE_DESCIFRADO'**
  String get snippetsRequireDecryptionKey;

  /// No description provided for @snippetsEncryptionKeyHint.
  ///
  /// In es, this message translates to:
  /// **'llave de cifrado'**
  String get snippetsEncryptionKeyHint;

  /// No description provided for @snippetsEncryptionKeyPrefix.
  ///
  /// In es, this message translates to:
  /// **'clave:'**
  String get snippetsEncryptionKeyPrefix;

  /// No description provided for @snippetsExecute.
  ///
  /// In es, this message translates to:
  /// **'EJECUTAR'**
  String get snippetsExecute;

  /// No description provided for @docsLoadErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la documentación técnica'**
  String get docsLoadErrorTitle;

  /// No description provided for @docsNoApisTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay APIs del proyecto en el catálogo'**
  String get docsNoApisTitle;

  /// No description provided for @docsNoApisSubtitle.
  ///
  /// In es, this message translates to:
  /// **'El catálogo respondió, pero no se encontraron endpoints Hub. Revisa metadata project/category o rutas /hub/*.'**
  String get docsNoApisSubtitle;

  /// No description provided for @docsServiceNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Servicio no encontrado en docs'**
  String get docsServiceNotFoundTitle;

  /// No description provided for @docsServiceNotFoundSubtitle.
  ///
  /// In es, this message translates to:
  /// **'La ruta no coincide con un endpoint del proyecto Hub. Vuelve al índice de /docs.'**
  String get docsServiceNotFoundSubtitle;

  /// No description provided for @docsIndexSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Índice principal de APIs del proyecto Hub'**
  String get docsIndexSubtitle;

  /// No description provided for @docsServicesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} servicios'**
  String docsServicesCount(Object count);

  /// No description provided for @docsSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar endpoint, método o tag'**
  String get docsSearchHint;

  /// No description provided for @docsAllCategories.
  ///
  /// In es, this message translates to:
  /// **'Todas las categorías'**
  String get docsAllCategories;

  /// No description provided for @docsNoResultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados para este filtro'**
  String get docsNoResultsTitle;

  /// No description provided for @docsNoResultsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Prueba otra categoría o limpia la búsqueda para ver todos los endpoints.'**
  String get docsNoResultsSubtitle;

  /// No description provided for @docsDetailsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Documentación técnica de {name}'**
  String docsDetailsSubtitle(Object name);

  /// No description provided for @docsIndexButton.
  ///
  /// In es, this message translates to:
  /// **'Índice'**
  String get docsIndexButton;

  /// No description provided for @docsActiveServiceLabel.
  ///
  /// In es, this message translates to:
  /// **'servicio activo'**
  String get docsActiveServiceLabel;

  /// No description provided for @docsOpenButton.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get docsOpenButton;

  /// No description provided for @docsAuthChip.
  ///
  /// In es, this message translates to:
  /// **'auth'**
  String get docsAuthChip;

  /// No description provided for @docsSourceLabel.
  ///
  /// In es, this message translates to:
  /// **'fuente'**
  String get docsSourceLabel;

  /// No description provided for @docsCredentialsTitle.
  ///
  /// In es, this message translates to:
  /// **'Credenciales para este endpoint'**
  String get docsCredentialsTitle;

  /// No description provided for @docsRequiredHeadersSection.
  ///
  /// In es, this message translates to:
  /// **'Headers requeridos'**
  String get docsRequiredHeadersSection;

  /// No description provided for @docsContentTypeDescription.
  ///
  /// In es, this message translates to:
  /// **'Tipo de contenido enviado a la API'**
  String get docsContentTypeDescription;

  /// No description provided for @docsAuthorizationDescription.
  ///
  /// In es, this message translates to:
  /// **'Autenticación de la cuenta'**
  String get docsAuthorizationDescription;

  /// No description provided for @docsParamsByLocationSection.
  ///
  /// In es, this message translates to:
  /// **'Parámetros por ubicación'**
  String get docsParamsByLocationSection;

  /// No description provided for @docsNoExplicitParams.
  ///
  /// In es, this message translates to:
  /// **'Este servicio no define parámetros explícitos en metadata.'**
  String get docsNoExplicitParams;

  /// No description provided for @docsCodeExamplesSection.
  ///
  /// In es, this message translates to:
  /// **'Ejemplos de código'**
  String get docsCodeExamplesSection;

  /// No description provided for @docsResponseSuccessSection.
  ///
  /// In es, this message translates to:
  /// **'Respuesta exitosa - 200 OK'**
  String get docsResponseSuccessSection;

  /// No description provided for @docsStatusCodesSection.
  ///
  /// In es, this message translates to:
  /// **'Códigos de estado'**
  String get docsStatusCodesSection;

  /// No description provided for @docsTrySandboxWithSession.
  ///
  /// In es, this message translates to:
  /// **'Probar en Sandbox (requiere sesión activa)'**
  String get docsTrySandboxWithSession;

  /// No description provided for @docsTrySandbox.
  ///
  /// In es, this message translates to:
  /// **'Probar en Sandbox'**
  String get docsTrySandbox;

  /// No description provided for @docsRelatedServicesSection.
  ///
  /// In es, this message translates to:
  /// **'Servicios relacionados'**
  String get docsRelatedServicesSection;

  /// No description provided for @docsRequiredBadge.
  ///
  /// In es, this message translates to:
  /// **'obligatorio'**
  String get docsRequiredBadge;

  /// No description provided for @docsNoSnippetsMessage.
  ///
  /// In es, this message translates to:
  /// **'Este servicio aún no publica snippets reales. Inicia sesión y ejecuta pruebas en Sandbox para obtener respuestas reales.'**
  String get docsNoSnippetsMessage;

  /// No description provided for @docsCopyTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get docsCopyTooltip;

  /// No description provided for @docsCopyResponseTooltip.
  ///
  /// In es, this message translates to:
  /// **'Copiar respuesta'**
  String get docsCopyResponseTooltip;

  /// No description provided for @sandboxBootBanner.
  ///
  /// In es, this message translates to:
  /// **'Auralix Hub Sandbox v1.0'**
  String get sandboxBootBanner;

  /// No description provided for @sandboxBootReady.
  ///
  /// In es, this message translates to:
  /// **'Sistema inicializado. Entorno listo.'**
  String get sandboxBootReady;

  /// No description provided for @sandboxPresetLoaded.
  ///
  /// In es, this message translates to:
  /// **'Preset cargado para {service} -> [{method} {path}]'**
  String sandboxPresetLoaded(Object service, Object method, Object path);

  /// No description provided for @sandboxHistoryRestored.
  ///
  /// In es, this message translates to:
  /// **'Snapshot restaurado: {method} {path}'**
  String sandboxHistoryRestored(Object method, Object path);

  /// No description provided for @sandboxPartialRestored.
  ///
  /// In es, this message translates to:
  /// **'Layout parcial restaurado: {method} {path}'**
  String sandboxPartialRestored(Object method, Object path);

  /// No description provided for @sandboxMissingRequired.
  ///
  /// In es, this message translates to:
  /// **'Falta parametro obligatorio: {name}'**
  String sandboxMissingRequired(Object name);

  /// No description provided for @sandboxRuntimeError.
  ///
  /// In es, this message translates to:
  /// **'Error de ejecucion: {error}'**
  String sandboxRuntimeError(Object error);

  /// No description provided for @sandboxSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entorno de control iterativo y pruebas en memoria'**
  String get sandboxSubtitle;

  /// No description provided for @sandboxLocalCredits.
  ///
  /// In es, this message translates to:
  /// **'{count} CREDITOS LOCALES'**
  String sandboxLocalCredits(Object count);

  /// No description provided for @sandboxActiveCredentialsTitle.
  ///
  /// In es, this message translates to:
  /// **'Credenciales activas inyectadas'**
  String get sandboxActiveCredentialsTitle;

  /// No description provided for @sandboxCatalogSelectionLabel.
  ///
  /// In es, this message translates to:
  /// **'SELECCION DE CATALOGO:'**
  String get sandboxCatalogSelectionLabel;

  /// No description provided for @sandboxCustomHeadersToggle.
  ///
  /// In es, this message translates to:
  /// **'Cabeceras personalizadas'**
  String get sandboxCustomHeadersToggle;

  /// No description provided for @sandboxInjectedHeadersLabel.
  ///
  /// In es, this message translates to:
  /// **'HEADERS INYECTADOS'**
  String get sandboxInjectedHeadersLabel;

  /// No description provided for @sandboxAddHeader.
  ///
  /// In es, this message translates to:
  /// **'AGREGAR NUEVO'**
  String get sandboxAddHeader;

  /// No description provided for @sandboxHeaderKeyHint.
  ///
  /// In es, this message translates to:
  /// **'Clave'**
  String get sandboxHeaderKeyHint;

  /// No description provided for @sandboxHeaderValueHint.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get sandboxHeaderValueHint;

  /// No description provided for @sandboxNoDeclaredParams.
  ///
  /// In es, this message translates to:
  /// **'> SIN PARAMETROS DECLARADOS EN LA FIRMA'**
  String get sandboxNoDeclaredParams;

  /// No description provided for @sandboxPayloadVariables.
  ///
  /// In es, this message translates to:
  /// **'VARIABLES Y CUERPO [PAYLOAD]'**
  String get sandboxPayloadVariables;

  /// No description provided for @sandboxExecuting.
  ///
  /// In es, this message translates to:
  /// **'EJECUTANDO'**
  String get sandboxExecuting;

  /// No description provided for @sandboxExecute.
  ///
  /// In es, this message translates to:
  /// **'EJECUTAR'**
  String get sandboxExecute;

  /// No description provided for @sandboxRequiredBadge.
  ///
  /// In es, this message translates to:
  /// **'REQ'**
  String get sandboxRequiredBadge;

  /// No description provided for @sandboxInsertPayloadHint.
  ///
  /// In es, this message translates to:
  /// **'Inserta payload para {name}'**
  String sandboxInsertPayloadHint(Object name);

  /// No description provided for @sandboxHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'HISTORIAL DE EJECUCIONES [LOCAL_STORAGE]'**
  String get sandboxHistoryTitle;

  /// No description provided for @sandboxCachedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} EN CACHE'**
  String sandboxCachedCount(Object count);

  /// No description provided for @sandboxStatusError.
  ///
  /// In es, this message translates to:
  /// **'ERR'**
  String get sandboxStatusError;

  /// No description provided for @historySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registro técnico de solicitudes y respuestas'**
  String get historySubtitle;

  /// No description provided for @historyRecordsInView.
  ///
  /// In es, this message translates to:
  /// **'{count} registros en esta vista'**
  String historyRecordsInView(Object count);

  /// No description provided for @historyFilterAll.
  ///
  /// In es, this message translates to:
  /// **'todo'**
  String get historyFilterAll;

  /// No description provided for @historyFilterSuccess.
  ///
  /// In es, this message translates to:
  /// **'éxito'**
  String get historyFilterSuccess;

  /// No description provided for @historyFilterError.
  ///
  /// In es, this message translates to:
  /// **'error'**
  String get historyFilterError;

  /// No description provided for @historyFilterSandbox.
  ///
  /// In es, this message translates to:
  /// **'sandbox'**
  String get historyFilterSandbox;

  /// No description provided for @historyNoRequestsInCategory.
  ///
  /// In es, this message translates to:
  /// **'No hay solicitudes en esta categoría'**
  String get historyNoRequestsInCategory;

  /// No description provided for @historyCredit.
  ///
  /// In es, this message translates to:
  /// **'Crédito: {value}'**
  String historyCredit(Object value);

  /// No description provided for @historyEnvironmentSandbox.
  ///
  /// In es, this message translates to:
  /// **'sandbox'**
  String get historyEnvironmentSandbox;

  /// No description provided for @historyEnvironmentProduction.
  ///
  /// In es, this message translates to:
  /// **'producción'**
  String get historyEnvironmentProduction;

  /// No description provided for @historyColumnMethod.
  ///
  /// In es, this message translates to:
  /// **'MÉTODO'**
  String get historyColumnMethod;

  /// No description provided for @historyColumnStatus.
  ///
  /// In es, this message translates to:
  /// **'ESTADO'**
  String get historyColumnStatus;

  /// No description provided for @historyColumnEndpoint.
  ///
  /// In es, this message translates to:
  /// **'ENDPOINT'**
  String get historyColumnEndpoint;

  /// No description provided for @historyColumnTime.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO'**
  String get historyColumnTime;

  /// No description provided for @historyColumnCredit.
  ///
  /// In es, this message translates to:
  /// **'CRÉDITO'**
  String get historyColumnCredit;

  /// No description provided for @requestLogsLiveTitle.
  ///
  /// In es, this message translates to:
  /// **'logs en tiempo real'**
  String get requestLogsLiveTitle;

  /// No description provided for @requestLogsLiveBadge.
  ///
  /// In es, this message translates to:
  /// **'LIVE'**
  String get requestLogsLiveBadge;

  /// No description provided for @requestLogsRefresh.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get requestLogsRefresh;

  /// No description provided for @requestLogsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Ninguna solicitud aún'**
  String get requestLogsEmpty;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sistema central: Analíticas y consumo en línea // Bienvenido, {name}'**
  String dashboardSubtitle(Object name);

  /// No description provided for @dashboardMetricsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar las métricas.'**
  String get dashboardMetricsLoadError;

  /// No description provided for @dashboardConsumptionStatusTitle.
  ///
  /// In es, this message translates to:
  /// **'ESTADO DEL CONSUMO'**
  String get dashboardConsumptionStatusTitle;

  /// No description provided for @dashboardConsumptionCompactDescription.
  ///
  /// In es, this message translates to:
  /// **'Cuando necesites ampliar límites de solicitudes por segundo, compra un plan superior o recarga créditos desde Billing.'**
  String get dashboardConsumptionCompactDescription;

  /// No description provided for @dashboardPurchasePlanCredits.
  ///
  /// In es, this message translates to:
  /// **'COMPRAR PLAN / CRÉDITOS'**
  String get dashboardPurchasePlanCredits;

  /// No description provided for @dashboardConsumptionSystemHealthTitle.
  ///
  /// In es, this message translates to:
  /// **'ESTADO DEL CONSUMO - SALUD DEL SISTEMA'**
  String get dashboardConsumptionSystemHealthTitle;

  /// No description provided for @dashboardConsumptionDesktopDescription.
  ///
  /// In es, this message translates to:
  /// **'El dashboard muestra la salud y actividad general. Billing aparece cuando decides comprar y ampliar cuotas.'**
  String get dashboardConsumptionDesktopDescription;

  /// No description provided for @dashboardPurchasePlan.
  ///
  /// In es, this message translates to:
  /// **'COMPRAR PLAN'**
  String get dashboardPurchasePlan;

  /// No description provided for @dashboardRecentActivityTitle.
  ///
  /// In es, this message translates to:
  /// **'ACTIVIDAD RECIENTE'**
  String get dashboardRecentActivityTitle;

  /// No description provided for @dashboardViewFullHistory.
  ///
  /// In es, this message translates to:
  /// **'VER HISTORIAL COMPLETO'**
  String get dashboardViewFullHistory;

  /// No description provided for @dashboardHistoryLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar la actividad. Reintenta.'**
  String get dashboardHistoryLoadError;

  /// No description provided for @dashboardHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin actividad reciente.'**
  String get dashboardHistoryEmpty;

  /// No description provided for @dashboardMetricUsedRequests.
  ///
  /// In es, this message translates to:
  /// **'SOLICITUDES USADAS'**
  String get dashboardMetricUsedRequests;

  /// No description provided for @dashboardMetricAvailable.
  ///
  /// In es, this message translates to:
  /// **'DISPONIBLES'**
  String get dashboardMetricAvailable;

  /// No description provided for @dashboardMetricSandboxCredits.
  ///
  /// In es, this message translates to:
  /// **'CRÉDITOS SANDBOX'**
  String get dashboardMetricSandboxCredits;

  /// No description provided for @dashboardMetricTotalRequests.
  ///
  /// In es, this message translates to:
  /// **'TOTAL SOLICITUDES'**
  String get dashboardMetricTotalRequests;

  /// No description provided for @dashboardCreditsReserve.
  ///
  /// In es, this message translates to:
  /// **'RESERVA DE CRÉDITOS:'**
  String get dashboardCreditsReserve;

  /// No description provided for @dashboardFreeTier.
  ///
  /// In es, this message translates to:
  /// **'GRATIS'**
  String get dashboardFreeTier;

  /// No description provided for @billingTitle.
  ///
  /// In es, this message translates to:
  /// **'billing // marketplace'**
  String get billingTitle;

  /// No description provided for @billingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Adquiere y gestiona tus créditos de Hub.Aura'**
  String get billingSubtitle;

  /// No description provided for @billingTransparentPurchaseTitle.
  ///
  /// In es, this message translates to:
  /// **'COMPRA DE CRÉDITOS TRANSPARENTE'**
  String get billingTransparentPurchaseTitle;

  /// No description provided for @billingTransparentPurchaseDescription.
  ///
  /// In es, this message translates to:
  /// **'Conoce el coste exacto por crédito y obtén estimaciones precisas para que elijas libremente entre paquetes o cantidades a medida. Sin compromisos ocultos.'**
  String get billingTransparentPurchaseDescription;

  /// No description provided for @billingOnlineBalance.
  ///
  /// In es, this message translates to:
  /// **'BALANCE EN LÍNEA'**
  String get billingOnlineBalance;

  /// No description provided for @billingAvailableRequests.
  ///
  /// In es, this message translates to:
  /// **'{count} solicitudes disponibles'**
  String billingAvailableRequests(Object count);

  /// No description provided for @billingPlanTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'TIPO DE PLAN: {plan}'**
  String billingPlanTypeLabel(Object plan);

  /// No description provided for @billingStandardPackages.
  ///
  /// In es, this message translates to:
  /// **'PAQUETES ESTANDARIZADOS'**
  String get billingStandardPackages;

  /// No description provided for @billingPlansLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos recuperar los planes'**
  String get billingPlansLoadError;

  /// No description provided for @billingCustomVolume.
  ///
  /// In es, this message translates to:
  /// **'VOLUMEN A MEDIDA'**
  String get billingCustomVolume;

  /// No description provided for @billingCustomAmount.
  ///
  /// In es, this message translates to:
  /// **'CANTIDAD PERSONALIZADA'**
  String get billingCustomAmount;

  /// No description provided for @billingCustomHintExample.
  ///
  /// In es, this message translates to:
  /// **'Ej: 750'**
  String get billingCustomHintExample;

  /// No description provided for @billingRawEstimate.
  ///
  /// In es, this message translates to:
  /// **'Estimación en bruto: aprox. \${amount} USD'**
  String billingRawEstimate(Object amount);

  /// No description provided for @billingSelectPackageError.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un paquete o ingresa créditos personalizados'**
  String get billingSelectPackageError;

  /// No description provided for @billingNoPaymentUrlError.
  ///
  /// In es, this message translates to:
  /// **'Pago iniciado, pero no se recibió URL de pago'**
  String get billingNoPaymentUrlError;

  /// No description provided for @billingGeneratePaymentError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo generar el pago'**
  String get billingGeneratePaymentError;

  /// No description provided for @billingConnectionPaymentError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión al generar el pago'**
  String get billingConnectionPaymentError;

  /// No description provided for @billingActiveGatewayTitle.
  ///
  /// In es, this message translates to:
  /// **'PASARELA ACTIVA // CRYPTOMUS'**
  String get billingActiveGatewayTitle;

  /// No description provided for @billingGeneratedEncryptedUrl.
  ///
  /// In es, this message translates to:
  /// **'URL GENERADA Y CIFRADA:'**
  String get billingGeneratedEncryptedUrl;

  /// No description provided for @billingRedirectToPayment.
  ///
  /// In es, this message translates to:
  /// **'REDIRECCIONAR A PAGO'**
  String get billingRedirectToPayment;

  /// No description provided for @billingGeneratingOrder.
  ///
  /// In es, this message translates to:
  /// **'GENERANDO ORDEN...'**
  String get billingGeneratingOrder;

  /// No description provided for @billingProcessCryptoPayment.
  ///
  /// In es, this message translates to:
  /// **'PROCESAR PAGO CRIPTOGRÁFICO'**
  String get billingProcessCryptoPayment;

  /// No description provided for @billingSecureTransactionsFooter.
  ///
  /// In es, this message translates to:
  /// **'Transacciones aseguradas vía Cryptomus. Comisiones ultrabajas. Sin almacenamiento de tarjetas.'**
  String get billingSecureTransactionsFooter;

  /// No description provided for @billingBestValue.
  ///
  /// In es, this message translates to:
  /// **'MEJOR VALOR'**
  String get billingBestValue;

  /// No description provided for @billingUnitPrice.
  ///
  /// In es, this message translates to:
  /// **'aprox. \${value} / unidad'**
  String billingUnitPrice(Object value);

  /// No description provided for @billingUnlimited.
  ///
  /// In es, this message translates to:
  /// **'ILIMITADO'**
  String get billingUnlimited;

  /// No description provided for @billingCredits.
  ///
  /// In es, this message translates to:
  /// **'{count} CRÉDITOS'**
  String billingCredits(Object count);

  /// No description provided for @billingPlanUseCaseIntensive.
  ///
  /// In es, this message translates to:
  /// **'Ideal para equipos con uso intensivo diario.'**
  String get billingPlanUseCaseIntensive;

  /// No description provided for @billingPlanUseCasePersonal.
  ///
  /// In es, this message translates to:
  /// **'Ideal para pruebas y proyectos personales.'**
  String get billingPlanUseCasePersonal;

  /// No description provided for @billingPlanUseCaseSmallTeams.
  ///
  /// In es, this message translates to:
  /// **'Ideal para side-projects y equipos pequeños.'**
  String get billingPlanUseCaseSmallTeams;

  /// No description provided for @billingPlanUseCaseProduction.
  ///
  /// In es, this message translates to:
  /// **'Ideal para producción y cargas frecuentes.'**
  String get billingPlanUseCaseProduction;

  /// No description provided for @billingPlanRequestsName.
  ///
  /// In es, this message translates to:
  /// **'{count} solicitudes'**
  String billingPlanRequestsName(Object count);

  /// No description provided for @billingPlanWeeklyUnlimited.
  ///
  /// In es, this message translates to:
  /// **'Semanal ilimitado'**
  String get billingPlanWeeklyUnlimited;

  /// No description provided for @billingPopularBadge.
  ///
  /// In es, this message translates to:
  /// **'Popular'**
  String get billingPopularBadge;

  /// No description provided for @settingsPageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración interactiva del sistema'**
  String get settingsPageSubtitle;

  /// No description provided for @settingsOperatorProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil de operador'**
  String get settingsOperatorProfileTitle;

  /// No description provided for @settingsEmailVerified.
  ///
  /// In es, this message translates to:
  /// **'ESTADO: VERIFICADO'**
  String get settingsEmailVerified;

  /// No description provided for @settingsEmailNotVerified.
  ///
  /// In es, this message translates to:
  /// **'ESTADO: NO VERIFICADO'**
  String get settingsEmailNotVerified;

  /// No description provided for @settingsPublicAlias.
  ///
  /// In es, this message translates to:
  /// **'IDENTIFICADOR PÚBLICO'**
  String get settingsPublicAlias;

  /// No description provided for @settingsAliasHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu identificador (alias)'**
  String get settingsAliasHint;

  /// No description provided for @settingsAliasPrefix.
  ///
  /// In es, this message translates to:
  /// **'alias:'**
  String get settingsAliasPrefix;

  /// No description provided for @settingsUpdateProfile.
  ///
  /// In es, this message translates to:
  /// **'ACTUALIZAR DATOS'**
  String get settingsUpdateProfile;

  /// No description provided for @settingsThemeMatrixTitle.
  ///
  /// In es, this message translates to:
  /// **'Matriz visual [temas]'**
  String get settingsThemeMatrixTitle;

  /// No description provided for @settingsThemeActive.
  ///
  /// In es, this message translates to:
  /// **'[ACTIVO]'**
  String get settingsThemeActive;

  /// No description provided for @settingsThemeInactive.
  ///
  /// In es, this message translates to:
  /// **'INACTIVO'**
  String get settingsThemeInactive;

  /// No description provided for @settingsDesignTokensTitle.
  ///
  /// In es, this message translates to:
  /// **'Tokens de diseño'**
  String get settingsDesignTokensTitle;

  /// No description provided for @settingsApiCredentialsTitle.
  ///
  /// In es, this message translates to:
  /// **'Credenciales API'**
  String get settingsApiCredentialsTitle;

  /// No description provided for @settingsSessionTokenPanelTitle.
  ///
  /// In es, this message translates to:
  /// **'Token de sesión interceptado'**
  String get settingsSessionTokenPanelTitle;

  /// No description provided for @settingsCriticalDirectivesTitle.
  ///
  /// In es, this message translates to:
  /// **'Directivas críticas'**
  String get settingsCriticalDirectivesTitle;

  /// No description provided for @settingsTerminateSessionTitle.
  ///
  /// In es, this message translates to:
  /// **'TERMINAR SESIÓN'**
  String get settingsTerminateSessionTitle;

  /// No description provided for @settingsTerminateSessionDescription.
  ///
  /// In es, this message translates to:
  /// **'Cierra todos los accesos en el nodo actual y destruye el token en memoria.'**
  String get settingsTerminateSessionDescription;

  /// No description provided for @settingsPurgeButton.
  ///
  /// In es, this message translates to:
  /// **'PURGAR'**
  String get settingsPurgeButton;

  /// No description provided for @settingsProfileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado correctamente en la red.'**
  String get settingsProfileSaved;

  /// No description provided for @settingsProfileSaveError.
  ///
  /// In es, this message translates to:
  /// **'Fallo de integridad de datos.'**
  String get settingsProfileSaveError;

  /// No description provided for @settingsProfileTimeout.
  ///
  /// In es, this message translates to:
  /// **'ERR_CONNECTION: Timeout operando perfil.'**
  String get settingsProfileTimeout;

  /// No description provided for @settingsUploadPhoto.
  ///
  /// In es, this message translates to:
  /// **'SUBIR FOTO'**
  String get settingsUploadPhoto;

  /// No description provided for @settingsAvatarUploaded.
  ///
  /// In es, this message translates to:
  /// **'Avatar subido correctamente.'**
  String get settingsAvatarUploaded;

  /// No description provided for @settingsAvatarUploadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo subir el avatar.'**
  String get settingsAvatarUploadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
