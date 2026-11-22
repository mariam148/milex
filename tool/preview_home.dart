import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:milex/models/onboarding_data.dart';
import 'package:milex/screens/home_screen.dart';

/// Debug-only visual review entry point; production startup remains unchanged.
void main() {
  if (!kDebugMode) {
    throw StateError('Home preview is available only in debug builds.');
  }
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6036FF),
          brightness: Brightness.dark,
        ),
      ),
      home: HomeScreen(onboardingData: OnboardingData()),
    ),
  );
}
