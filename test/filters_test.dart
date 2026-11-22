import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/models/car_filters.dart';
import 'package:milex/repositories/car_repository.dart';
import 'package:milex/screens/all_cars_screen.dart';
import 'package:milex/screens/filters_screen.dart';
import 'package:milex/screens/car_details_screen.dart';
import 'package:milex/screens/booking_summary_screen.dart';
import 'package:milex/widgets/home_widgets.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  test(
    'All filters combine with search, boundaries and sample pickup radius',
    () {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      expect(repository.search(filters: const CarFilters()).length, 30);
      const exact = CarFilters(
        minPrice: 55,
        maxPrice: 55,
        category: 'Economy',
        brand: 'Nissan',
        transmission: 'Automatic',
        fuelType: 'Petrol',
        seats: 5,
        minRating: 4.0,
        pickupLocation: 'Brooklyn',
        radiusMiles: 2.5,
        instantBook: true,
      );
      expect(
        repository.search(query: ' NISSAN sentra ', filters: exact).single.id,
        'sentra',
      );
      expect(repository.search(query: 'BMW', filters: exact), isEmpty);
      expect(
        repository.search(filters: const CarFilters(minPrice: 1, maxPrice: 2)),
        isEmpty,
      );
      expect(
        repository
            .search(filters: const CarFilters(fuelType: 'Electric'))
            .length,
        5,
      );
      expect(repository.search(filters: const CarFilters(seats: 7)).length, 5);
      expect(repository.search(filters: const CarFilters(seats: 2)).length, 3);
      expect(repository.search(filters: const CarFilters(seats: 4)).length, 2);
      expect(
        repository
            .search(filters: const CarFilters(transmission: 'Manual'))
            .length,
        3,
      );
      expect(
        repository.search(filters: const CarFilters(fuelType: 'Diesel')).length,
        3,
      );
      expect(
        repository.search(filters: const CarFilters(minRating: 4.8)).length,
        10,
      );
      expect(
        repository.search(filters: const CarFilters(brand: 'BMW')).length,
        3,
      );
      expect(
        repository.search(
          filters: const CarFilters(pickupLocation: 'Brooklyn', radiusMiles: 1),
        ),
        isNotEmpty,
      );
      final before = repository.byId('sentra');
      repository.toggleFavorite('sentra');
      expect(repository.search(filters: exact).single.isFavorite, isTrue);
      expect(repository.byId('sentra').transmission, before.transmission);
      expect(repository.byId('sentra').fuelType, before.fuelType);
      expect(
        repository.byId('sentra').instantBookEligible,
        before.instantBookEligible,
      );
      expect(
        repository.search(filters: const CarFilters(minPrice: 2000)),
        isEmpty,
      );
    },
  );

  testWidgets(
    'Results apply, preserve and reset filters; cancel discards drafts',
    (tester) async {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        MaterialApp(home: AllCarsScreen(repository: repository)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tapVisible(
        tester,
        find.widgetWithText(CarCategoryTile, 'Electric'),
      );
      await tester.tap(find.byKey(const ValueKey('show-filter-results')));
      await tester.pumpAndSettle();
      expect(find.text('5 demo vehicles'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Tesla');
      await tester.pumpAndSettle();
      expect(find.text('2 demo vehicles'), findsOneWidget);
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CarCategoryTile>(
              find.widgetWithText(CarCategoryTile, 'Electric'),
            )
            .selected,
        isTrue,
      );
      await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Manual'));
      expect(find.text('Show Results (0)'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('2 demo vehicles'), findsOneWidget);
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('reset-filters')));
      expect(find.text('Show Results (2)'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('show-filter-results')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(find.text('30 demo vehicles'), findsOneWidget);
    },
  );

  testWidgets(
    'Empty results, brand reveal, price adjustment and fixed results button',
    (tester) async {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: AllCarsScreen(
            repository: repository,
            initialFilters: const CarFilters(
              category: 'Electric',
              transmission: 'Manual',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0 demo vehicles'), findsOneWidget);
      expect(find.text('No demo cars found'), findsOneWidget);
      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      final range = tester.widget<RangeSlider>(find.byType(RangeSlider));
      range.onChanged!(RangeValues(repository.minPrice, 100));
      await tester.pump();
      expect(find.text('USD 100 / day'), findsOneWidget);
      await tapVisible(tester, find.text('See All'));
      expect(find.widgetWithText(ChoiceChip, 'Toyota'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reset-filters')));
      await tester.pump();
      expect(find.text('Show Results (30)'), findsOneWidget);
    },
  );

  for (final size in [const Size(320, 568), const Size(412, 892)]) {
    testWidgets(
      'Filters and details fit $size with large text; booking is a demo subtotal',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = CarRepository();
        addTearDown(repository.dispose);
        Widget app(Widget screen) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.3)),
            child: child!,
          ),
          home: screen,
        );
        await tester.pumpWidget(app(FiltersScreen(repository: repository)));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byType(SwitchListTile),
          350,
          scrollable: find.byType(Scrollable).first,
        );
        await tapVisible(tester, find.byType(Switch));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .getBottomLeft(find.byKey(const ValueKey('show-filter-results')))
              .dy,
          lessThanOrEqualTo(size.height),
        );
        await tester.pumpWidget(
          app(CarDetailsScreen(carId: 'sentra', repository: repository)),
        );
        await tester.pumpAndSettle();
        await tapVisible(tester, find.byKey(const ValueKey('rental-duration')));
        await tester.tap(find.text('7 days').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Book Now'));
        await tester.pumpAndSettle();
        expect(find.byType(BookingSummaryScreen), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('booking-subtotal')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Sample subtotal: USD 385.00'), findsOneWidget);
        await tapVisible(tester, find.text('Back to car details'));
        expect(find.byType(CarDetailsScreen), findsOneWidget);
        expect(find.text('7 days'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
