import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: PageView(controller: _controller, onPageChanged: (i) => setState(() => _page = i), children: [
              _pageItem(loc.translate('onboarding_security_title'), loc.translate('onboarding_security_body')),
              _pageItem(loc.translate('onboarding_control_title'), loc.translate('onboarding_control_body')),
              _pageItem(loc.translate('onboarding_integrations_title'), loc.translate('onboarding_integrations_body')),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(children: [
              Expanded(child: GradientButton(onPressed: _next, child: Text(_page < 2 ? loc.translate('next') : loc.translate('get_started'), style: const TextStyle(color: Colors.white)))),
            ]),
          )
        ]),
      ),
    );
  }

  Widget _pageItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(subtitle),
        const SizedBox(height: 24),
        Expanded(child: Center(child: Icon(Icons.shield, size: 120, color: Colors.white24))),
      ]),
    );
  }
}
