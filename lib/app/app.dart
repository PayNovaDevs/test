import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../l10n/app_localizations.dart';
import 'providers.dart';

class DexWalletApp extends ConsumerWidget {
  DexWalletApp({Key? key}) : super(key: key);

  final _router = GoRouter(routes: [
    GoRoute(name: 'splash', path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(name: 'onboarding', path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(name: 'welcome', path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(name: 'home', path: '/home', builder: (context, state) => const HomeScreen()),
  ]);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'dex wallet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: const [AppLocalizationsDelegate(), GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
      supportedLocales: const [Locale('en'), Locale('es')],
    );
  }
}
