import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_notifier.dart';
import 'core/routing/app_router.dart';
import 'data/services/auth_service.dart';

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
  late final AuthService _authService;
  late final LocaleNotifier _localeNotifier;

  @override
  void initState() {
    super.initState();
    _config = const AppConfig();
    _authService = AuthService();
    _localeNotifier = LocaleNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: _config),
        ChangeNotifierProvider<AuthService>.value(value: _authService),
        ChangeNotifierProvider<LocaleNotifier>.value(value: _localeNotifier),
      ],
      child: Consumer<LocaleNotifier>(
        builder: (context, localeNotifier, child) {
          final router = AppRouter.createRouter(_authService);

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
            routerConfig: router,
          );
        },
      ),
    );
  }
}
