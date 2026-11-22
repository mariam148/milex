import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:milex/models/onboarding_data.dart';
import 'package:milex/screens/sign_up_screen.dart';
import 'package:milex/screens/profile_photo_screen.dart';
import 'package:milex/screens/drivers_license_screen.dart';
import 'package:milex/screens/current_address_screen.dart';
import 'package:milex/screens/home_screen.dart';
import 'package:milex/services/profile_photo_picker.dart';
import 'package:milex/widgets/onboarding_photo_input.dart';

class FakePhotoPicker extends ProfilePhotoPicker {
  Uint8List? result;
  PlatformException? error;
  ImageSource? source;
  @override
  Future<Uint8List?> pick(ImageSource source) async {
    this.source = source;
    if (error != null) throw error!;
    return result;
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<Uint8List> imageBytes(WidgetTester tester) async {
  return (await tester.runAsync(() async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.purple, BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(4, 4);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    return bytes!.buffer.asUint8List();
  }))!;
}

Future<void> choosePhoto(
  WidgetTester tester,
  Finder target,
  String source,
) async {
  await tapVisible(tester, target);
  await tester.tap(find.text(source));
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Signup validates and starts an explicit demo with name and phone',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));
      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Sign Up'));
      expect(find.text('Please enter your full name'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'MileX Driver');
      await tester.enterText(fields.at(1), '01012345678');
      await tester.enterText(fields.at(2), 'Milex1234');
      await tapVisible(
        tester,
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tapVisible(tester, find.text('Egypt').last);
      await tapVisible(tester, find.widgetWithText(ElevatedButton, 'Sign Up'));

      final screen = tester.widget<ProfilePhotoScreen>(
        find.byType(ProfilePhotoScreen),
      );
      expect(screen.data!.fullName, 'MileX Driver');
      expect(screen.data!.phoneNumber, '+2001012345678');
      expect(screen.data!.country, 'Egypt');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('MileX Driver'), findsOneWidget);
    },
  );

  testWidgets(
    'Photo picker handles cancellation, permission denial, corrupt data and replacement',
    (tester) async {
      final picker = FakePhotoPicker();
      final data = OnboardingData();
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePhotoScreen(data: data, photoPicker: picker),
        ),
      );
      await tapVisible(tester, find.text('Save and Continue'));
      expect(
        find.text('Please add a profile photo to continue.'),
        findsOneWidget,
      );
      await choosePhoto(
        tester,
        find.text('Add a Photo'),
        'Upload from Library',
      );
      expect(data.profilePhoto, isNull);
      picker.error = PlatformException(code: 'camera_access_denied');
      await choosePhoto(
        tester,
        find.byTooltip('Add a profile photo'),
        'Take a Photo',
      );
      expect(
        find.textContaining('Photo access is unavailable'),
        findsOneWidget,
      );
      picker.error = null;
      picker.result = Uint8List.fromList([1, 2, 3]);
      await choosePhoto(
        tester,
        find.text('Add a Photo'),
        'Upload from Library',
      );
      expect(data.profilePhoto, isNull);
      expect(find.textContaining('Could not read that image'), findsOneWidget);
      picker.result = await imageBytes(tester);
      await choosePhoto(
        tester,
        find.text('Add a Photo'),
        'Upload from Library',
      );
      expect(data.profilePhoto, picker.result);
      expect(find.bySemanticsLabel('Selected profile photo'), findsOneWidget);
      await choosePhoto(tester, find.text('Add a Photo'), 'Take a Photo');
      expect(picker.source, ImageSource.camera);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'All steps validate and preserve draft when navigating back and forward',
    (tester) async {
      final picker = FakePhotoPicker();
      picker.result = await imageBytes(tester);
      final data = OnboardingData(country: 'Egypt');
      await tester.pumpWidget(
        MaterialApp(
          home: ProfilePhotoScreen(data: data, photoPicker: picker),
        ),
      );
      await choosePhoto(
        tester,
        find.text('Add a Photo'),
        'Upload from Library',
      );
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.byType(DriversLicenseScreen), findsOneWidget);
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.text('Please enter your license number'), findsOneWidget);
      expect(find.text('Choose a future expiration date'), findsOneWidget);
      expect(
        find.text('Please add both front and back license photos.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextFormField).first, 'EG12345');
      await tapVisible(tester, find.byType(DropdownButtonFormField<String>));
      await tapVisible(tester, find.text('🇪🇬 Egypt').last);
      await tapVisible(tester, find.byType(TextFormField).last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(
        data.expirationDate!.isAfter(DateUtils.dateOnly(DateTime.now())),
        isTrue,
      );
      await choosePhoto(
        tester,
        find.byType(OnboardingPhotoInput).first,
        'Take a Photo',
      );
      await choosePhoto(
        tester,
        find.byType(OnboardingPhotoInput).last,
        'Upload from Library',
      );
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.byType(CurrentAddressScreen), findsOneWidget);
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.text('Please enter city'), findsOneWidget);
      final values = ['Cairo', 'Maadi', 'Sarayat', '23', '4B', 'bad'];
      for (var i = 0; i < values.length; i++) {
        await tester.ensureVisible(find.byType(TextFormField).at(i));
        await tester.enterText(find.byType(TextFormField).at(i), values[i]);
      }
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.text('Enter a valid postal code'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).last, '11742');
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('EG12345'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Selected profile photo'), findsOneWidget);
      await tapVisible(tester, find.text('Save and Continue'));
      await tapVisible(tester, find.text('Save and Continue'));
      await tester.ensureVisible(find.byType(TextFormField).first);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).first)
            .initialValue,
        'Cairo',
      );
      await tapVisible(tester, find.text('Save and Continue'));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const ValueKey('home-wordmark')), findsOneWidget);
      final home = tester.widget<HomeScreen>(find.byType(HomeScreen));
      expect(identical(home.onboardingData, data), isTrue);
      expect(
        Navigator.of(tester.element(find.byType(HomeScreen))).canPop(),
        isFalse,
      );
      expect(find.byType(ProfilePhotoScreen), findsNothing);
      expect(find.byType(DriversLicenseScreen), findsNothing);
      expect(find.byType(CurrentAddressScreen), findsNothing);
      expect(data.licenseFront, isNotNull);
      expect(data.licenseBack, isNotNull);
      expect(data.postalCode, '11742');
    },
  );

  for (final size in [
    const Size(320, 568),
    const Size(412, 892),
    const Size(393, 852),
    const Size(402, 874),
  ]) {
    testWidgets('Onboarding screens fit $size with larger text and keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final data = OnboardingData(country: 'Egypt');
      for (final screen in [
        ProfilePhotoScreen(data: data),
        DriversLicenseScreen(data: data),
        CurrentAddressScreen(data: data),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
                viewInsets: const EdgeInsets.only(bottom: 180),
              ),
              child: child!,
            ),
            home: screen,
          ),
        );
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text('Save and Continue'));
        expect(tester.takeException(), isNull);
      }
    });
  }
}
