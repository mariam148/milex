import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milex/models/booking_model.dart';
import 'package:milex/models/onboarding_data.dart';
import 'package:milex/models/demo_diagnostic_model.dart';
import 'package:milex/repositories/car_repository.dart';
import 'package:milex/repositories/booking_repository.dart';
import 'package:milex/services/demo_session.dart';
import 'package:milex/screens/home_screen.dart';
import 'package:milex/screens/car_details_screen.dart';
import 'package:milex/screens/booking_summary_screen.dart';
import 'package:milex/screens/secure_payment_screen.dart';
import 'package:milex/screens/booking_confirmed_screen.dart';
import 'package:milex/screens/my_bookings_screen.dart';
import 'package:milex/screens/booking_details_screen.dart';
import 'package:milex/screens/car_health_screen.dart';
import 'package:milex/screens/diagnostic_details_screen.dart';
import 'package:milex/screens/roadside_help_screen.dart';
import 'package:milex/screens/nearby_mechanics_screen.dart';
import 'package:milex/screens/my_profile_screen.dart';
import 'package:milex/screens/profile_settings_screen.dart';
import 'package:milex/screens/login_screen.dart';
import 'package:milex/screens/favorites_screen.dart';
import 'package:milex/screens/support_screen.dart';
import 'package:milex/models/demo_assistance_request.dart';

class NoDemoNetwork extends HttpOverrides {
  int attempts = 0;
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    attempts++;
    throw StateError('Local demo must not use a network client.');
  }
}

Future<void> visibleTap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      240,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'Demo fees, rounding, invalid dates, snapshots and idempotent bookings',
    () {
      final cars = CarRepository();
      final bookings = BookingRepository();
      addTearDown(cars.dispose);
      addTearDown(bookings.dispose);
      final start = DateTime(2026, 11, 5, 10);
      final draft = BookingDraft(
        car: cars.byId('sentra'),
        pickup: start,
        returnAt: start.add(const Duration(days: 3)),
        pickupLocation: 'Brooklyn',
        dropoffLocation: 'New York',
      );
      expect(draft.days, 3);
      expect(draft.subtotalCents, 16500);
      expect(draft.serviceFeeCents, 825);
      expect(draft.taxCents, 1320);
      expect(draft.totalCents, 18645);
      final key = Object();
      final first = bookings.confirm(draft, key);
      expect(identical(first, bookings.confirm(draft, key)), isTrue);
      expect(bookings.bookings.length, 1);
      draft.returnAt = start.add(const Duration(days: 5));
      expect(first.details.days, 3);
      final copy = first.details;
      copy.pickupLocation = 'changed';
      expect(first.details.pickupLocation, 'Brooklyn');
      expect(
        first.statusAt(start.subtract(const Duration(seconds: 1))),
        DemoBookingStatus.upcoming,
      );
      expect(first.statusAt(start), DemoBookingStatus.active);
      expect(
        first.statusAt(start.add(const Duration(days: 3))),
        DemoBookingStatus.past,
      );
      draft.returnAt = start.add(const Duration(days: 1, seconds: 1));
      expect(draft.days, 2);
      draft.returnAt = start;
      expect(draft.valid, isFalse);
      expect(() => bookings.confirm(draft, Object()), throwsArgumentError);
      expect(bookings.bookings.length, 1);
    },
  );

  test(
    'Diagnostics are selected-car examples and electric oil is not applicable',
    () {
      final cars = CarRepository();
      addTearDown(cars.dispose);
      final electric = DemoDiagnosticModel.forCar(cars.byId('i4'));
      expect(electric.carId, 'i4');
      expect(electric.items.first.warning, isFalse);
      expect(electric.items.first.status, contains('Not applicable'));
      final sports = DemoDiagnosticModel.forCar(cars.byId('vantage'));
      expect(sports.items.last.warning, isTrue);
    },
  );

  testWidgets(
    'Complete booking, payment, bookings tab, diagnostics, roadside and provider preview without network',
    (tester) async {
      final network = NoDemoNetwork();
      final previous = HttpOverrides.current;
      HttpOverrides.global = network;
      addTearDown(() => HttpOverrides.global = previous);
      final cars = CarRepository();
      addTearDown(cars.dispose);
      final session = DemoSession.forCars(cars);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            onboardingData: OnboardingData(fullName: 'Local Driver'),
            repository: cars,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await visibleTap(tester, find.byTooltip('View Aston Martin Vantage'));
      expect(find.byType(CarDetailsScreen), findsOneWidget);
      await visibleTap(tester, find.text('Book Now'));
      expect(find.byType(BookingSummaryScreen), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(SecurePaymentScreen), findsOneWidget);
      final dummyFields = tester.widgetList<TextField>(find.byType(TextField));
      expect(
        dummyFields.every((field) => field.readOnly && field.enabled == false),
        isTrue,
      );
      await visibleTap(
        tester,
        find.byKey(const ValueKey('demo-payment-consent')),
      );
      await tester.tap(find.text('Pay Securely (Demo)'));
      await tester.pumpAndSettle();
      expect(find.byType(BookingConfirmedScreen), findsOneWidget);
      expect(session.bookings.bookings.length, 1);
      final reference = session.bookings.bookings.single.reference;
      await tester.tap(find.text('View My Booking'));
      await tester.pumpAndSettle();
      expect(find.byType(MyBookingsScreen), findsOneWidget);
      await visibleTap(tester, find.text(reference));
      await visibleTap(tester, find.text('View Details'));
      expect(find.byType(BookingDetailsScreen), findsOneWidget);
      await visibleTap(tester, find.text('Car Health'));
      expect(find.byType(CarHealthScreen), findsOneWidget);
      await visibleTap(tester, find.text('Battery'));
      expect(find.byType(DiagnosticDetailsScreen), findsOneWidget);
      await visibleTap(tester, find.text('Request Roadside Assistance'));
      expect(find.byType(RoadsideHelpScreen), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField),
        'Simulated battery warning',
      );
      await tester.tap(find.text('Request Assistance (Demo)'));
      await tester.pumpAndSettle();
      expect(find.byType(NearbyMechanicsScreen), findsOneWidget);
      await visibleTap(tester, find.text('Use My Location'));
      expect(find.textContaining('GPS is not used'), findsOneWidget);
      expect(network.attempts, 0);
      expect(tester.takeException(), isNull);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(RoadsideHelpScreen), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'Simulated battery warning',
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Profile edits are shared; favorites and all personal demo state clear on logout',
    (tester) async {
      final cars = CarRepository();
      addTearDown(cars.dispose);
      final session = DemoSession.forCars(cars);
      final data = OnboardingData(
        fullName: 'Local Driver',
        phoneNumber: '+201012345678',
        country: 'Egypt',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(onboardingData: data, repository: cars),
        ),
      );
      await tester.pumpAndSettle();
      cars.toggleFavorite('sentra');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesScreen), findsOneWidget);
      await visibleTap(tester, find.byTooltip('View Nissan Sentra 2025'));
      expect(find.byType(CarDetailsScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tab-4')));
      await tester.pumpAndSettle();
      expect(find.byType(MyProfileScreen), findsOneWidget);
      await visibleTap(tester, find.text('Edit Profile'));
      expect(find.byType(ProfileSettingsScreen), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'Updated Driver',
      );
      await tester.tap(find.text('Save local profile'));
      await tester.pumpAndSettle();
      expect(session.profile.fullName, 'Updated Driver');
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      expect(find.text('Updated Driver'), findsOneWidget);
      await visibleTap(tester, find.text('Logout'));
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(session.profile.fullName, isEmpty);
      expect(cars.favorites, isEmpty);
      expect(session.bookings.bookings, isEmpty);
      expect(session.assistance, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(412, 892)]) {
    testWidgets('All remaining demo screens fit $size at large text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final cars = CarRepository();
      addTearDown(cars.dispose);
      final session = DemoSession.forCars(cars);
      final car = cars.byId('sentra');
      final now = DateTime.now();
      final draft = BookingDraft(
        car: car,
        pickup: now,
        returnAt: now.add(const Duration(days: 3)),
        pickupLocation: car.location,
        dropoffLocation: car.location,
      );
      final booking = session.bookings.confirm(draft, Object());
      final screens = <Widget>[
        BookingSummaryScreen(car: car, session: session),
        SecurePaymentScreen(draft: draft, session: session),
        BookingConfirmedScreen(booking: booking, session: session),
        MyBookingsScreen(session: session),
        BookingDetailsScreen(booking: booking, session: session),
        CarHealthScreen(car: car, session: session),
        DiagnosticDetailsScreen(car: car, session: session),
        RoadsideHelpScreen(session: session, car: car),
        NearbyMechanicsScreen(
          request: DemoAssistanceRequest(
            carId: car.id,
            service: 'Mobile Mechanic',
            problem: 'Sample warning',
            location: car.location,
          ),
        ),
        SupportScreen(session: session),
        MyProfileScreen(session: session),
        ProfileSettingsScreen(session: session),
        ProfileSettingsScreen(session: session, editProfile: true),
        FavoritesScreen(repository: cars),
      ];
      for (final screen in screens) {
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
            home: screen,
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: screen.runtimeType.toString(),
        );
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
