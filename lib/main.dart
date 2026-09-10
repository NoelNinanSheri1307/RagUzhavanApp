import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_notifier.dart';
import 'core/routing/app_router.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/rag_repository.dart';
import 'data/repositories/api_rag_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RagUzhavanApp());
}

class RagUzhavanApp extends StatefulWidget {
  const RagUzhavanApp({super.key});

  @override
  State<RagUzhavanApp> createState() => _RagUzhavanAppState();
}

class _RagUzhavanAppState extends State<RagUzhavanApp> {
  late final AppConfig _config;
  late final ApiService _apiService;
  late final ApiAuthRepository _authRepository;
  late final ApiRagRepository _ragRepository;
  late final AuthService _authService;
  late final LocaleNotifier _localeNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _config = const AppConfig();
    _apiService = ApiService(baseUrl: _config.apiBaseUrl);
    _authRepository = ApiAuthRepository(apiService: _apiService);
    _ragRepository = ApiRagRepository(_apiService);
    _authService = AuthService(authRepository: _authRepository);
    _localeNotifier = LocaleNotifier();
    _router = AppRouter.createRouter(_authService);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: _config),
        Provider<ApiService>.value(value: _apiService),
        Provider<RagRepository>.value(value: _ragRepository),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<LocaleNotifier>.value(value: _localeNotifier),
      ],
      child: Consumer<LocaleNotifier>(
        builder: (context, localeNotifier, child) {
          return MaterialApp.router(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            locale: localeNotifier.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
