// Run explicitly: flutter test tool/capture_home_preview_test.dart
// Produces a Flutter-rendered preview, not an Android emulator screenshot.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/models/onboarding_data.dart';
import 'package:milex/screens/home_screen.dart';

void main() {
  setUpAll(() async {
    final fonts = Directory(
      '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts',
    );
    for (final font in [
      ('Roboto', 'roboto-regular.ttf'),
      ('MaterialIcons', 'materialicons-regular.otf'),
    ]) {
      final loader = FontLoader(font.$1)
        ..addFont(
          File('${fonts.path}/${font.$2}')
              .readAsBytes()
              .then(ByteData.sublistView),
        );
      await loader.load();
    }
  });
  testWidgets('Capture Home at Pixel 7 Pro dimensions', (tester) async {
    tester.view.physicalSize = const Size(1440, 3120);
    tester.view.devicePixelRatio = 3.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const key = ValueKey('capture');
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6036FF),
            brightness: Brightness.dark,
          ),
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(padding: const EdgeInsets.only(top: 32, bottom: 24)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: key,
          child: HomeScreen(onboardingData: OnboardingData()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomeScreen));
    await tester.runAsync(
      () => Future.wait([
        for (final asset in [
          'milex_logo.png',
          'demo_sports.png',
          'demo_sports_blue.png',
          'demo_sedan.png',
          'demo_suv.png',
        ])
          precacheImage(AssetImage('assets/images/$asset'), context),
      ]),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final image = await boundary.toImage(pixelRatio: 3.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await Directory('artifacts/home').create(recursive: true);
      await File('artifacts/home/pixel-7-pro-widget.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      image.dispose();
    });
    expect(tester.takeException(), isNull);
  });
}
