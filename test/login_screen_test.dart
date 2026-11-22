import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/main.dart';
import 'package:milex/screens/home_screen.dart';
import 'package:milex/screens/login_screen.dart';
import 'package:milex/screens/sign_up_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final size in [
    const Size(412, 892),
    const Size(393, 852),
    const Size(402, 874),
  ]) {
    testWidgets('Login fits viewport $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);
      await tester.ensureVisible(find.text('Sign Up.'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Login validates and never reports a fake successful login', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Demo Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid mobile number'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '01012345678');
    await tester.enterText(find.byType(TextFormField).last, 'Password1');
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(find.byTooltip('Hide password'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Demo Login'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Remember Me persists across screen instances', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance()).getBool('remember_me'),
      isTrue,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('Sign Up and Login return without stacking routes', (
    tester,
  ) async {
    await tester.pumpWidget(const MileXApp());
    await tester.ensureVisible(find.text('Log In.'));
    await tester.tap(find.text('Log In.'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tester.ensureVisible(find.text('Sign Up.'));
    await tester.tap(find.text('Sign Up.'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(SignUpScreen))).canPop(),
      isFalse,
    );
  });

  testWidgets(
    'Small screens, larger text, keyboard and country selection fit',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.3),
              viewInsets: const EdgeInsets.only(bottom: 240),
            ),
            child: child!,
          ),
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('🇸🇦 +966').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Forgot Password?'));
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('Enter verification code'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
