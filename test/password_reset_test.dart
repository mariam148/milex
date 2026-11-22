import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/screens/login_screen.dart';
import 'package:milex/screens/forgot_password_screen.dart';
import 'package:milex/screens/create_new_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Login passes masked phone; demo returns to same Login', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '01012345678');
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('+20*********78'), findsOneWidget);
    expect(find.textContaining('01012345678'), findsNothing);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Continue'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Resend'))
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Demo: preview new password'));
    await tester.tap(find.text('Demo: preview new password'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter exactly four digits to preview the next screen.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const ValueKey('otp-0')), '9876');
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      expect(
        tester
            .widget<TextField>(find.byKey(ValueKey('otp-$i')))
            .controller!
            .text,
        '9876'[i],
      );
    }
    await tester.ensureVisible(find.text('Demo: preview new password'));
    await tester.tap(find.text('Demo: preview new password'));
    await tester.pumpAndSettle();
    expect(find.byType(CreateNewPasswordScreen), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'StrongPass9');
    await tester.enterText(find.byType(TextFormField).last, 'StrongPass9');
    await tester.ensureVisible(find.text('Demo: validate and return to Login'));
    await tester.tap(find.text('Demo: validate and return to Login'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ForgotPasswordScreen), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('OTP restricts digits, advances and backspaces', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('otp-0')), 'a1');
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('otp-0')))
          .controller!
          .text,
      '1',
    );
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('otp-1')))
          .focusNode!
          .hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('otp-0')))
          .focusNode!
          .hasFocus,
      isTrue,
    );
    await tester.enterText(find.byKey(const ValueKey('otp-1')), '2');
    await tester.enterText(find.byKey(const ValueKey('otp-1')), '');
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('otp-0')))
          .focusNode!
          .hasFocus,
      isTrue,
    );
  });

  testWidgets('Password rules, mismatch and independent visibility', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateNewPasswordScreen()));
    await tester.pumpAndSettle();
    final demo = find.text('Demo: validate and return to Login');
    for (final entry in {
      'short': 'Use at least 8 characters',
      'lowercase9': 'Include an uppercase letter',
      'UPPERCASE9': 'Include a lowercase letter',
      'NoNumbersHere': 'Include a number',
    }.entries) {
      await tester.enterText(find.byType(TextFormField).first, entry.key);
      await tester.ensureVisible(demo);
      await tester.tap(demo);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
    await tester.enterText(find.byType(TextFormField).first, 'StrongPass9');
    await tester.enterText(find.byType(TextFormField).last, 'OtherPass9');
    await tester.ensureVisible(demo);
    await tester.tap(demo);
    await tester.pumpAndSettle();
    expect(find.text('Passwords must match'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Show new password'));
    await tester.tap(find.byTooltip('Show new password'));
    await tester.pump();
    expect(find.byTooltip('Hide new password'), findsOneWidget);
    expect(find.byTooltip('Show confirm password'), findsOneWidget);
    await tester.tap(find.byTooltip('Show confirm password'));
    await tester.pump();
    expect(find.byTooltip('Hide confirm password'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
  });

  for (final size in [const Size(320, 568), const Size(448, 998)]) {
    testWidgets('Recovery fits $size with keyboard and large text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final screen in [
        const ForgotPasswordScreen(),
        const CreateNewPasswordScreen(),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.3),
                viewInsets: const EdgeInsets.only(bottom: 240),
              ),
              child: child!,
            ),
            home: screen,
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.textContaining('DEVELOPMENT-ONLY PREVIEW'),
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
