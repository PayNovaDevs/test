import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dex_wallet/features/home/home_screen.dart';

class DexWalletApp extends StatelessWidget {
  DexWalletApp({Key? key}) : super(key: key);

  final _router = GoRouter(routes: [
    GoRoute(name: 'home', path: '/', builder: (context, state) => HomeScreen()),
    // additional routes will be added here
  ]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'dex wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF00E676),
      ),
      routerConfig: _router,
    );
  }
}
