import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/main.dart';
import 'package:milex/screens/sign_up_screen.dart';
import 'package:milex/screens/splash_screen.dart';

void main() {
  testWidgets('App preserves its existing Sign Up startup', (tester) async {
    await tester.pumpWidget(const MileXApp());
    expect(find.byType(SignUpScreen), findsOneWidget);
  });
  testWidgets('Splash finishes and replaces its route with onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Drive more. Worry less.'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 3400));
    expect(find.byType(OnboardingScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Find your perfect ride'), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(OnboardingScreen))).canPop(),
      isFalse,
    );
  });
}
