import 'package:flutter/material.dart';
import 'dart:async';

import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
    // navigate after short delay
    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/welcome');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.dark();
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: ScaleTransition(
            scale: _anim,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), shape: BoxShape.circle),
                child: const Icon(Icons.account_balance_wallet, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text('dex wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
    );
  }
}
