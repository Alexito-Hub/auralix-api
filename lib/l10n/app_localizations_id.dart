// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Auralix Hub';

  @override
  String get navDashboard => 'Dasbor';

  @override
  String get navDocs => 'Dokumentasi';

  @override
  String get navSandbox => 'Sandbox';

  @override
  String get navSnippets => 'Cuplikan';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navBilling => 'Tagihan';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get languageLabel => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageSpanish => 'Spanyol';

  @override
  String get languageEnglish => 'Inggris';

  @override
  String get languageIndonesian => 'Indonesia';

  @override
  String get layoutResponsiveTitle => 'Desain responsif';

  @override
  String get layoutResponsiveSubtitle =>
      'Dioptimalkan untuk ponsel, tablet, dan desktop.';

  @override
  String get commonRequired => 'Wajib';

  @override
  String get authLoginModuleTitle => 'Modul Autentikasi';

  @override
  String get authLoginSubtitle =>
      'Masukkan kredensial Anda untuk mengakses hub.';

  @override
  String get authCaptchaRequired => 'Selesaikan verifikasi captcha.';

  @override
  String get authNoAccount => 'Belum punya akun?';

  @override
  String get authLogin => 'Masuk';

  @override
  String get authRegister => 'Daftar';

  @override
  String get authTerms => 'Ketentuan';

  @override
  String get authPrivacy => 'Privasi';

  @override
  String get authAuthenticate => 'Autentikasi';

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
  String get authRegisterModuleTitle => 'Penyediaan Akun';

  @override
  String get authRegisterCompleteTitle => 'Pendaftaran Selesai';

  @override
  String get authRegisterAccountCreated => 'AKUN DIBUAT';

  @override
  String authRegisterVerifyEmailMessage(Object email) {
    return 'Verifikasi email Anda di:\n$email';
  }

  @override
  String get authProceedToLogin => 'LANJUT KE MASUK';

  @override
  String get authRegisterSubtitle =>
      'Akun baru menerima 20 permintaan gratis dan 10 batas sandbox.';

  @override
  String get authInvalidEmail => 'Email tidak valid';

  @override
  String get authRegisterPasswordHint => 'min 8 karakter';

  @override
  String get authMin8Chars => 'Min 8 karakter';

  @override
  String get authRegisterConfirmPasswordHint => 'ulangi kata sandi';

  @override
  String get authRegisterConfirmPrefix => 'verifikasi:';

  @override
  String get authPasswordMismatch => 'Tidak cocok';

  @override
  String get authProvisionAccount => 'SEDIAKAN AKUN';

  @override
  String get authExistingUser => 'SUDAH PUNYA AKUN?';

  @override
  String get authRegisterCommand => '\$ ./provision_user.sh';

  @override
  String get authVerifyTitle => 'Verifikasi Identitas';

  @override
  String get authVerifyChecking => 'MEMVERIFIKASI TANDA TANGAN...';

  @override
  String get authVerifySuccessCode => 'VERIFIKASI_BERHASIL_200';

  @override
  String get authVerifyErrorCode => 'GALAT_VERIFIKASI';

  @override
  String get authVerifySuccessMessage =>
      'Identitas terkonfirmasi. Akun Anda kini aktif.';

  @override
  String get authVerifyInvalidOrExpired =>
      'Tautan yang diberikan tidak valid atau kedaluwarsa.';

  @override
  String get authReturnToLogin => 'KEMBALI KE MASUK';

  @override
  String get authVerifyTokenMissing => 'Token tidak ada atau tidak valid.';

  @override
  String get authVerifyInvalidSignature => 'Tanda tangan token tidak valid.';

  @override
  String get authVerifyConnectionFailed => 'Koneksi ke otoritas gagal.';

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
  String get authSplashCoreReady => 'Layanan inti diinisialisasi';

  @override
  String get authSplashSocketReady => 'WebSocket siap dan mendengarkan';

  @override
  String get authSplashWaitingAuth => 'Menunggu autentikasi...';

  @override
  String get authSplashStartCommand => '\$ auth_subsystem --start';

  @override
  String get captchaLoadFailed => 'Tidak dapat memuat captcha';

  @override
  String get captchaValidationFailed => 'Validasi captcha gagal';

  @override
  String get captchaIncorrectAnswer => 'Jawaban salah';

  @override
  String get captchaTryAgain => 'Terjadi kesalahan saat verifikasi. Coba lagi.';

  @override
  String get captchaVerified => 'Captcha terverifikasi [OK]';

  @override
  String get captchaSecurityVerification => 'Verifikasi keamanan';

  @override
  String get captchaUnavailable => 'Captcha tidak tersedia';

  @override
  String get captchaAnswerHint => 'Jawaban';

  @override
  String get captchaVerify => 'Verifikasi';

  @override
  String get captchaNew => 'Captcha baru';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonConnectionError => 'Kesalahan koneksi';

  @override
  String get routerNotFoundTitle => 'Rute tidak ditemukan';

  @override
  String get routerUnknownError => 'Kesalahan router tidak diketahui';

  @override
  String get routerGoHome => 'Ke beranda';

  @override
  String get routerOpenDashboard => 'Buka dasbor';

  @override
  String get settingsLocaleAutoLabel => 'Gunakan bahasa sistem jika tersedia.';

  @override
  String get appShellOpenNavigation => 'Buka navigasi';

  @override
  String get appShellNoSession => 'Tidak ada sesi aktif';

  @override
  String get appShellPlanLabel => 'Paket';

  @override
  String get appShellLogout => 'Keluar';

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
  String get requestLogsLiveTitle => 'log waktu nyata';

  @override
  String get requestLogsLiveBadge => 'LIVE';

  @override
  String get requestLogsRefresh => 'Muat ulang';

  @override
  String get requestLogsEmpty => 'Belum ada permintaan';

  @override
  String dashboardSubtitle(Object name) {
    return 'Sistem inti: Analitik dan konsumsi langsung // Selamat datang, $name';
  }

  @override
  String get dashboardMetricsLoadError => 'Tidak dapat memuat metrik.';

  @override
  String get dashboardConsumptionStatusTitle => 'STATUS KONSUMSI';

  @override
  String get dashboardConsumptionCompactDescription =>
      'Saat Anda perlu memperluas batas permintaan per detik, beli paket yang lebih tinggi atau tambah kredit dari Billing.';

  @override
  String get dashboardPurchasePlanCredits => 'BELI PAKET / KREDIT';

  @override
  String get dashboardConsumptionSystemHealthTitle =>
      'STATUS KONSUMSI - KESEHATAN SISTEM';

  @override
  String get dashboardConsumptionDesktopDescription =>
      'Dasbor menampilkan kesehatan dan aktivitas keseluruhan. Billing muncul saat Anda memutuskan membeli dan memperluas kuota.';

  @override
  String get dashboardPurchasePlan => 'BELI PAKET';

  @override
  String get dashboardRecentActivityTitle => 'AKTIVITAS TERKINI';

  @override
  String get dashboardViewFullHistory => 'LIHAT RIWAYAT LENGKAP';

  @override
  String get dashboardHistoryLoadError => 'Gagal memuat aktivitas. Coba lagi.';

  @override
  String get dashboardHistoryEmpty => 'Belum ada aktivitas terbaru.';

  @override
  String get dashboardMetricUsedRequests => 'PERMINTAAN TERPAKAI';

  @override
  String get dashboardMetricAvailable => 'TERSEDIA';

  @override
  String get dashboardMetricSandboxCredits => 'KREDIT SANDBOX';

  @override
  String get dashboardMetricTotalRequests => 'TOTAL PERMINTAAN';

  @override
  String get dashboardCreditsReserve => 'CADANGAN KREDIT:';

  @override
  String get dashboardFreeTier => 'TIER GRATIS';

  @override
  String get billingTitle => 'billing // marketplace';

  @override
  String get billingSubtitle => 'Dapatkan dan kelola kredit Hub.Aura Anda';

  @override
  String get billingTransparentPurchaseTitle => 'PEMBELIAN KREDIT TRANSPARAN';

  @override
  String get billingTransparentPurchaseDescription =>
      'Ketahui biaya tepat per kredit dan dapatkan estimasi akurat agar Anda bebas memilih paket atau jumlah kustom. Tanpa komitmen tersembunyi.';

  @override
  String get billingOnlineBalance => 'SALDO ONLINE';

  @override
  String billingAvailableRequests(Object count) {
    return '$count permintaan tersedia';
  }

  @override
  String billingPlanTypeLabel(Object plan) {
    return 'JENIS PAKET: $plan';
  }

  @override
  String get billingStandardPackages => 'PAKET STANDAR';

  @override
  String get billingPlansLoadError => 'Tidak dapat memuat paket';

  @override
  String get billingCustomVolume => 'VOLUME KUSTOM';

  @override
  String get billingCustomAmount => 'JUMLAH KUSTOM';

  @override
  String get billingCustomHintExample => 'Contoh: 750';

  @override
  String billingRawEstimate(Object amount) {
    return 'Estimasi kasar: sekitar \$$amount USD';
  }

  @override
  String get billingSelectPackageError =>
      'Pilih paket atau masukkan kredit kustom';

  @override
  String get billingNoPaymentUrlError =>
      'Pembayaran dimulai, tetapi URL pembayaran tidak diterima';

  @override
  String get billingGeneratePaymentError => 'Tidak dapat membuat pembayaran';

  @override
  String get billingConnectionPaymentError =>
      'Kesalahan koneksi saat membuat pembayaran';

  @override
  String get billingActiveGatewayTitle => 'GATEWAY AKTIF // CRYPTOMUS';

  @override
  String get billingGeneratedEncryptedUrl =>
      'URL YANG DIHASILKAN DAN DIENKRIPSI:';

  @override
  String get billingRedirectToPayment => 'ALIHKAN KE PEMBAYARAN';

  @override
  String get billingGeneratingOrder => 'MEMBUAT PESANAN...';

  @override
  String get billingProcessCryptoPayment => 'PROSES PEMBAYARAN KRIPTO';

  @override
  String get billingSecureTransactionsFooter =>
      'Transaksi diamankan melalui Cryptomus. Biaya sangat rendah. Tanpa penyimpanan kartu.';

  @override
  String get billingBestValue => 'NILAI TERBAIK';

  @override
  String billingUnitPrice(Object value) {
    return 'sekitar \$$value / unit';
  }

  @override
  String get billingUnlimited => 'TIDAK TERBATAS';

  @override
  String billingCredits(Object count) {
    return '$count KREDIT';
  }

  @override
  String get billingPlanUseCaseIntensive =>
      'Ideal untuk tim dengan penggunaan harian intensif.';

  @override
  String get billingPlanUseCasePersonal =>
      'Ideal untuk pengujian dan proyek pribadi.';

  @override
  String get billingPlanUseCaseSmallTeams =>
      'Ideal untuk proyek sampingan dan tim kecil.';

  @override
  String get billingPlanUseCaseProduction =>
      'Ideal untuk produksi dan beban kerja yang sering.';

  @override
  String billingPlanRequestsName(Object count) {
    return '$count permintaan';
  }

  @override
  String get billingPlanWeeklyUnlimited => 'Mingguan tanpa batas';

  @override
  String get billingPopularBadge => 'Popular';

  @override
  String get settingsPageSubtitle => 'Konfigurasi sistem interaktif';

  @override
  String get settingsOperatorProfileTitle => 'Profil Operator';

  @override
  String get settingsEmailVerified => 'STATUS: TERVERIFIKASI';

  @override
  String get settingsEmailNotVerified => 'STATUS: BELUM TERVERIFIKASI';

  @override
  String get settingsPublicAlias => 'IDENTITAS PUBLIK';

  @override
  String get settingsAliasHint => 'Masukkan identitas Anda (alias)';

  @override
  String get settingsAliasPrefix => 'alias:';

  @override
  String get settingsUpdateProfile => 'PERBARUI PROFIL';

  @override
  String get settingsThemeMatrixTitle => 'Matriks Visual [Tema]';

  @override
  String get settingsThemeActive => '[AKTIF]';

  @override
  String get settingsThemeInactive => 'TIDAK AKTIF';

  @override
  String get settingsDesignTokensTitle => 'Token Desain';

  @override
  String get settingsApiCredentialsTitle => 'Kredensial API';

  @override
  String get settingsSessionTokenPanelTitle => 'Token sesi yang ditangkap';

  @override
  String get settingsCriticalDirectivesTitle => 'Direktif Kritis';

  @override
  String get settingsTerminateSessionTitle => 'AKHIRI SESI';

  @override
  String get settingsTerminateSessionDescription =>
      'Tutup semua akses aktif pada node ini dan hapus token di memori.';

  @override
  String get settingsPurgeButton => 'BERSIHKAN';

  @override
  String get settingsProfileSaved => 'Profil berhasil diperbarui di jaringan.';

  @override
  String get settingsProfileSaveError => 'Kegagalan integritas data.';

  @override
  String get settingsProfileTimeout =>
      'ERR_CONNECTION: Waktu habis saat memperbarui profil.';

  @override
  String get settingsUploadPhoto => 'UNGGAH FOTO';

  @override
  String get settingsAvatarUploaded => 'Avatar berhasil diunggah.';

  @override
  String get settingsAvatarUploadError => 'Tidak dapat mengunggah avatar.';
}
