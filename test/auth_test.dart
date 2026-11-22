import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/screens/sign_up_screen.dart';
import 'package:milex/screens/login_screen.dart';
import 'package:milex/screens/home_screen.dart';
import 'package:milex/screens/profile_photo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RejectNetwork extends HttpOverrides {
  int clients = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    clients++;
    throw StateError(
      'Demo authentication must never request a network client.',
    );
  }
}

void main() {
  late RejectNetwork network;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    network = RejectNetwork();
    HttpOverrides.global = network;
  });
  tearDown(() => HttpOverrides.global = null);

  testWidgets(
    'Google is unavailable on both forms and Apple is absent without network access',
    (tester) async {
      for (final screen in [const SignUpScreen(), const LoginScreen()]) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();
        expect(find.text('Continue with Apple'), findsNothing);
        await tester.ensureVisible(find.text('Continue with Google'));
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        expect(
          find.text('Google Sign-In is not available in Demo Mode.'),
          findsOneWidget,
        );
        expect(find.byType(HomeScreen), findsNothing);
        expect(network.clients, 0);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'Sign Up validates fields, opens local draft and never saves password',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
      final signup = find.widgetWithText(ElevatedButton, 'Sign Up');
      await tester.ensureVisible(signup);
      await tester.tap(signup);
      await tester.pumpAndSettle();
      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Enter phone number'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please select a country'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'Local Driver');
      await tester.enterText(find.byType(TextFormField).at(1), '01012345678');
      await tester.enterText(find.byType(TextFormField).at(2), 'LocalPass8');
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Egypt').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(signup);
      await tester.tap(signup);
      await tester.pumpAndSettle();
      final draft = tester
          .widget<ProfilePhotoScreen>(find.byType(ProfilePhotoScreen))
          .data!;
      expect(draft.fullName, 'Local Driver');
      expect(draft.userId, isNull);
      expect(network.clients, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), isEmpty);
    },
  );

  testWidgets('Demo Login opens Home without a backend or saved credentials', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Development-only demo login'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, '01012345678');
    await tester.enterText(find.byType(TextFormField).last, 'AnyLocal8');
    await tester.ensureVisible(find.text('Demo Login'));
    await tester.tap(find.text('Demo Login'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(network.clients, 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), isEmpty);
    expect(tester.takeException(), isNull);
  });
}
