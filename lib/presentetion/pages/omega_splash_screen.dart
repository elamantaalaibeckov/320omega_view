import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/omega_bottomnavigation_bar.dart';
import 'package:omega_view_smart_plan_320/presentetion/pages/omega_onboarding_page.dart';

class OmegaSplashScreen extends StatefulWidget {
  const OmegaSplashScreen({super.key});

  @override
  State<OmegaSplashScreen> createState() => _OmegaSplashScreenState();
}

class _OmegaSplashScreenState extends State<OmegaSplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), _goNext);
  }

  Future<void> _goNext() async {
    final box = Hive.box('settings'); // уже открыт в main
    final seen = box.get('onboarding_done', defaultValue: false) as bool;
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => seen
            ? const OmegaBottomnavigationBar()
            : const OmegaOnboardingPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00267A), Color(0xFF001D5A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset('assets/images/splash_icon.png'),
      ),
    );
  }
}
