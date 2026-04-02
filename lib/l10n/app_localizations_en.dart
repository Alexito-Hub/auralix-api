// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get navHistory => 'History';

  @override
  String get navBilling => 'Billing';

  @override
  String get navSettings => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get layoutResponsiveTitle => 'Responsive design';

  @override
  String get layoutResponsiveSubtitle =>
      'Optimized for mobile, tablet and desktop.';

  @override
  String get commonRequired => 'Required';

  @override
  String get authLoginModuleTitle => 'Authentication Module';

  @override
  String get authLoginSubtitle => 'Enter your credentials to access the hub.';

  @override
  String get authCaptchaRequired => 'Please complete the captcha verification.';

  @override
  String get authNoAccount => 'No account?';

  @override
  String get authLogin => 'Login';

  @override
  String get authRegister => 'Register';

  @override
  String get authTerms => 'Terms';

  @override
  String get authPrivacy => 'Privacy';

  @override
  String get authAuthenticate => 'Authenticate';

  @override
  String get authLoginCommand => '~/login.sh --execute';

  @override
  String get authEmailHint => 'user@domain.com';

  @override
  String get authEmailPrefix => 'email:';

  @override
  String get authPasswordHint => '********';

  @override
  String get authPasswordPrefix => 'pass:';

  @override
  String get authRegisterModuleTitle => 'Account Provisioning';

  @override
  String get authRegisterCompleteTitle => 'Registration Complete';

  @override
  String get authRegisterAccountCreated => 'ACCOUNT CREATED';

  @override
  String authRegisterVerifyEmailMessage(Object email) {
    return 'Verify your email at:\n$email';
  }

  @override
  String get authProceedToLogin => 'PROCEED TO LOGIN';

  @override
  String get authRegisterSubtitle =>
      'New accounts receive 20 free requests and 10 sandbox limits.';

  @override
  String get authInvalidEmail => 'Invalid email';

  @override
  String get authRegisterPasswordHint => 'min 8 characters';

  @override
  String get authMin8Chars => 'Min 8 chars';

  @override
  String get authRegisterConfirmPasswordHint => 'repeat password';

  @override
  String get authRegisterConfirmPrefix => 'verify:';

  @override
  String get authPasswordMismatch => 'Mismatch';

  @override
  String get authProvisionAccount => 'PROVISION ACCOUNT';

  @override
  String get authExistingUser => 'EXISTING USER?';

  @override
  String get authRegisterCommand => '\$ ./provision_user.sh';

  @override
  String get authVerifyTitle => 'Identity Verification';

  @override
  String get authVerifyChecking => 'VERIFYING SIGNATURE...';

  @override
  String get authVerifySuccessCode => 'VERIFICATION SUCCESS_200';

  @override
  String get authVerifyErrorCode => 'VERIFICATION_ERR';

  @override
  String get authVerifySuccessMessage =>
      'Identity confirmed. Your account is now active.';

  @override
  String get authVerifyInvalidOrExpired =>
      'The provided link is invalid or has expired.';

  @override
  String get authReturnToLogin => 'RETURN TO LOGIN';

  @override
  String get authVerifyTokenMissing => 'Token missing or invalid.';

  @override
  String get authVerifyInvalidSignature => 'Invalid token signature.';

  @override
  String get authVerifyConnectionFailed => 'Connection to authority failed.';

  @override
  String get authVersionLabel => 'AURALIX HUB v1.0.0-rc';

  @override
  String get authSecureAccessStatus => 'SECURE_ACCESS';

  @override
  String get authCaptchaEnabledStatus => 'CAPTCHA_ENABLED';

  @override
  String authSplashVersionLine(Object authority) {
    return 'Hub v1.0.0 - $authority';
  }

  @override
  String get authSplashCoreReady => 'Core services initialized';

  @override
  String get authSplashSocketReady => 'WebSocket ready and listening';

  @override
  String get authSplashWaitingAuth => 'Waiting for authentication...';

  @override
  String get authSplashStartCommand => '\$ auth_subsystem --start';

  @override
  String get captchaLoadFailed => 'Could not load captcha';

  @override
  String get captchaValidationFailed => 'Captcha validation failed';

  @override
  String get captchaIncorrectAnswer => 'Incorrect answer';

  @override
  String get captchaTryAgain => 'Error while verifying. Try again.';

  @override
  String get captchaVerified => 'Captcha verified [OK]';

  @override
  String get captchaSecurityVerification => 'Security verification';

  @override
  String get captchaUnavailable => 'Captcha unavailable';

  @override
  String get captchaAnswerHint => 'Answer';

  @override
  String get captchaVerify => 'Verify';

  @override
  String get captchaNew => 'New captcha';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonConnectionError => 'Connection error';

  @override
  String get routerNotFoundTitle => 'Route not found';

  @override
  String get routerUnknownError => 'Unknown router error';

  @override
  String get routerGoHome => 'Go to home';

  @override
  String get routerOpenDashboard => 'Open dashboard';

  @override
  String get settingsLocaleAutoLabel => 'Use system language when available.';

  @override
  String get appShellOpenNavigation => 'Open navigation';

  @override
  String get appShellNoSession => 'No active session';

  @override
  String get appShellPlanLabel => 'Plan';

  @override
  String get appShellLogout => 'Sign out';

  @override
  String get snippetsAnyLanguage => 'ANY_LANG';

  @override
  String get snippetsSubtitle => 'P2P secure code fragmentation sharing';

  @override
  String get snippetsLoadingFragments => 'FETCHING_NETWORK_FRAGMENTS...';

  @override
  String get snippetsFetchError => 'ERR_FETCH_FAILED';

  @override
  String get snippetsEmptyAll => 'NO_FRAGMENTS_FOUND';

  @override
  String get snippetsEmptyFiltered => 'NO_MATCHING_QUERIES';

  @override
  String snippetsYieldSummary(Object current, Object total) {
    return 'YIELD: $current/$total FRAGMENTS';
  }

  @override
  String get snippetsCreateAbort => 'ABORT';

  @override
  String get snippetsCreateNew => 'NEW_FRAG';

  @override
  String get snippetsSearchHint => 'QUERY DB...';

  @override
  String get snippetsSecureOnly => 'SECURE_ONLY';

  @override
  String get snippetsResetFilters => 'RESET';

  @override
  String get snippetsUntitled => 'UNTITLED_FRAG';

  @override
  String get snippetsEncrypted => 'ENCRYPTED';

  @override
  String get snippetsCopyUrl => 'COPY_URL';

  @override
  String get snippetsCopyUrlSuccess => 'URL SECURED IN CLIPBOARD';

  @override
  String get snippetsValidationTitleCodeRequired => 'TITLE_AND_CODE_REQUIRED';

  @override
  String get snippetsNetworkTimeout => 'NETWORK_TIMEOUT';

  @override
  String get snippetsCreateTitle => 'UPLOAD_NEW_FRAGMENT';

  @override
  String get snippetsTitleHint => 'e.g. Server bypass payload';

  @override
  String get snippetsTitlePrefix => 'title:';

  @override
  String snippetsLanguageOption(Object language) {
    return 'lang: $language';
  }

  @override
  String get snippetsCodeHint => '// Inject payload here...';

  @override
  String get snippetsRequireDecryptionKey => 'REQUIRE_DECRYPTION_KEY';

  @override
  String get snippetsEncryptionKeyHint => 'encryption key';

  @override
  String get snippetsEncryptionKeyPrefix => 'key:';

  @override
  String get snippetsExecute => 'EXECUTE';

  @override
  String get docsLoadErrorTitle => 'Failed to load technical documentation';

  @override
  String get docsNoApisTitle => 'No project APIs found in catalog';

  @override
  String get docsNoApisSubtitle =>
      'Catalog responded, but no Hub endpoints were found. Check project/category metadata or /hub/* routes.';

  @override
  String get docsServiceNotFoundTitle => 'Service not found in docs';

  @override
  String get docsServiceNotFoundSubtitle =>
      'Route does not match a Hub project endpoint. Return to /docs index.';

  @override
  String get docsIndexSubtitle => 'Main index of Hub project APIs';

  @override
  String docsServicesCount(Object count) {
    return '$count services';
  }

  @override
  String get docsSearchHint => 'Search endpoint, method or tag';

  @override
  String get docsAllCategories => 'All categories';

  @override
  String get docsNoResultsTitle => 'No results for this filter';

  @override
  String get docsNoResultsSubtitle =>
      'Try another category or clear search to view all endpoints.';

  @override
  String docsDetailsSubtitle(Object name) {
    return 'Technical documentation for $name';
  }

  @override
  String get docsIndexButton => 'Index';

  @override
  String get docsActiveServiceLabel => 'active service';

  @override
  String get docsOpenButton => 'Open';

  @override
  String get docsAuthChip => 'auth';

  @override
  String get docsSourceLabel => 'source';

  @override
  String get docsCredentialsTitle => 'Credentials for this endpoint';

  @override
  String get docsRequiredHeadersSection => 'Required headers';

  @override
  String get docsContentTypeDescription => 'Content type sent to the API';

  @override
  String get docsAuthorizationDescription => 'Account authentication';

  @override
  String get docsParamsByLocationSection => 'Parameters by location';

  @override
  String get docsNoExplicitParams =>
      'This service does not define explicit parameters in metadata.';

  @override
  String get docsCodeExamplesSection => 'Code examples';

  @override
  String get docsResponseSuccessSection => 'Successful response - 200 OK';

  @override
  String get docsStatusCodesSection => 'Status codes';

  @override
  String get docsTrySandboxWithSession =>
      'Try in Sandbox (requires active session)';

  @override
  String get docsTrySandbox => 'Try in Sandbox';

  @override
  String get docsRelatedServicesSection => 'Related services';

  @override
  String get docsRequiredBadge => 'required';

  @override
  String get docsNoSnippetsMessage =>
      'This service does not publish real snippets yet. Sign in and run tests in Sandbox to get real responses.';

  @override
  String get docsCopyTooltip => 'Copy';

  @override
  String get docsCopyResponseTooltip => 'Copy response';

  @override
  String get sandboxBootBanner => 'Auralix Hub Sandbox v1.0';

  @override
  String get sandboxBootReady => 'System initialized. Environment ready.';

  @override
  String sandboxPresetLoaded(Object service, Object method, Object path) {
    return 'Preset loaded for $service -> [$method $path]';
  }

  @override
  String sandboxHistoryRestored(Object method, Object path) {
    return 'History snapshot restored: $method $path';
  }

  @override
  String sandboxPartialRestored(Object method, Object path) {
    return 'Partial layout restored: $method $path';
  }

  @override
  String sandboxMissingRequired(Object name) {
    return 'Missing required constraint: $name';
  }

  @override
  String sandboxRuntimeError(Object error) {
    return 'Runtime Error: $error';
  }

  @override
  String get sandboxSubtitle =>
      'Iterative control environment and in-memory testing';

  @override
  String sandboxLocalCredits(Object count) {
    return '$count LOCAL CREDITS';
  }

  @override
  String get sandboxActiveCredentialsTitle => 'Injected active credentials';

  @override
  String get sandboxCatalogSelectionLabel => 'CATALOG SELECTION:';

  @override
  String get sandboxCustomHeadersToggle => 'Custom headers';

  @override
  String get sandboxInjectedHeadersLabel => 'INJECTED HEADERS';

  @override
  String get sandboxAddHeader => 'ADD NEW';

  @override
  String get sandboxHeaderKeyHint => 'Key';

  @override
  String get sandboxHeaderValueHint => 'Value';

  @override
  String get sandboxNoDeclaredParams => '> NO PARAMETERS DECLARED IN SIGNATURE';

  @override
  String get sandboxPayloadVariables => 'VARIABLES AND BODY [PAYLOAD]';

  @override
  String get sandboxExecuting => 'EXECUTING';

  @override
  String get sandboxExecute => 'EXECUTE';

  @override
  String get sandboxRequiredBadge => 'REQ';

  @override
  String sandboxInsertPayloadHint(Object name) {
    return 'Insert payload for $name';
  }

  @override
  String get sandboxHistoryTitle => 'EXECUTION HISTORY [LOCAL_STORAGE]';

  @override
  String sandboxCachedCount(Object count) {
    return '$count CACHED';
  }

  @override
  String get sandboxStatusError => 'ERR';

  @override
  String get historySubtitle => 'Technical log of requests and responses';

  @override
  String historyRecordsInView(Object count) {
    return '$count records in this view';
  }

  @override
  String get historyFilterAll => 'all';

  @override
  String get historyFilterSuccess => 'success';

  @override
  String get historyFilterError => 'error';

  @override
  String get historyFilterSandbox => 'sandbox';

  @override
  String get historyNoRequestsInCategory => 'No requests in this category';

  @override
  String historyCredit(Object value) {
    return 'Credit: $value';
  }

  @override
  String get historyEnvironmentSandbox => 'sandbox';

  @override
  String get historyEnvironmentProduction => 'production';

  @override
  String get historyColumnMethod => 'METHOD';

  @override
  String get historyColumnStatus => 'STATUS';

  @override
  String get historyColumnEndpoint => 'ENDPOINT';

  @override
  String get historyColumnTime => 'TIME';

  @override
  String get historyColumnCredit => 'CREDIT';

  @override
  String get requestLogsLiveTitle => 'real-time logs';

  @override
  String get requestLogsLiveBadge => 'LIVE';

  @override
  String get requestLogsRefresh => 'Refresh';

  @override
  String get requestLogsEmpty => 'No requests yet';

  @override
  String get settingsPageSubtitle => 'Interactive system configuration';

  @override
  String get settingsOperatorProfileTitle => 'Operator Profile';

  @override
  String get settingsEmailVerified => 'STATUS: VERIFIED';

  @override
  String get settingsEmailNotVerified => 'STATUS: NOT VERIFIED';

  @override
  String get settingsPublicAlias => 'PUBLIC IDENTIFIER';

  @override
  String get settingsAliasHint => 'Enter your identifier (alias)';

  @override
  String get settingsAliasPrefix => 'alias:';

  @override
  String get settingsUpdateProfile => 'UPDATE PROFILE';

  @override
  String get settingsThemeMatrixTitle => 'Visual Matrix [Themes]';

  @override
  String get settingsThemeActive => '[ACTIVE]';

  @override
  String get settingsThemeInactive => 'INACTIVE';

  @override
  String get settingsDesignTokensTitle => 'Design Tokens';

  @override
  String get settingsApiCredentialsTitle => 'API Credentials';

  @override
  String get settingsSessionTokenPanelTitle => 'Intercepted session token';

  @override
  String get settingsCriticalDirectivesTitle => 'Critical Directives';

  @override
  String get settingsTerminateSessionTitle => 'TERMINATE SESSION';

  @override
  String get settingsTerminateSessionDescription =>
      'Close all active accesses on this node and destroy the in-memory token.';

  @override
  String get settingsPurgeButton => 'PURGE';

  @override
  String get settingsProfileSaved =>
      'Profile successfully updated on the network.';

  @override
  String get settingsProfileSaveError => 'Data integrity failure.';

  @override
  String get settingsProfileTimeout =>
      'ERR_CONNECTION: Timeout while updating profile.';
}
