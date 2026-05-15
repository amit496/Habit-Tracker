import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/habit_provider.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';
import 'splash_screen.dart';

/// Chooses home screen without Navigator — fixes splash stuck after minimize/resume.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> with WidgetsBindingObserver {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleLeaveSplash();
  }

  void _scheduleLeaveSplash() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1400), _leaveSplash);
    });
  }

  void _leaveSplash() {
    if (!mounted || !_showSplash) return;
    setState(() => _showSplash = false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Timer may not fire while app is backgrounded — leave splash on resume.
    if (state == AppLifecycleState.resumed && _showSplash) {
      _leaveSplash();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }

    final done = context.watch<HabitProvider>().hasCompletedOnboarding;
    return done ? const MainShell() : const OnboardingScreen();
  }
}
