import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../repositories/car_repository.dart';
import '../services/demo_session.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

/// Local UI navigation only. No account, credentials or authenticated session.
class DemoNavigation {
  static OnboardingData? _draft;
  static DemoSession? _session;
  static void rememberDraft(OnboardingData data) {
    _draft = data;
  }

  static void useSession(DemoSession session) {
    _session = session;
    _draft = session.profile;
  }

  static Future<void> openHome(
    BuildContext context, {
    OnboardingData? data,
  }) async {
    final session = _session ??= DemoSession.forCars(CarRepository());
    session.profile = data ?? _draft ?? session.profile;
    rememberDraft(session.profile);
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => HomeScreen(
          onboardingData: session.profile,
          repository: session.cars,
        ),
      ),
      (_) => false,
    );
  }

  static void logout(BuildContext context, DemoSession session) {
    _session = null;
    _draft = null;
    session.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
