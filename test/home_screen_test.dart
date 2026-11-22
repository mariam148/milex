import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:milex/data/demo_inventory.dart';
import 'package:milex/models/onboarding_data.dart';
import 'package:milex/repositories/car_repository.dart';
import 'package:milex/screens/home_screen.dart';
import 'package:milex/screens/all_cars_screen.dart';
import 'package:milex/screens/category_cars_screen.dart';
import 'package:milex/screens/car_details_screen.dart';
import 'package:milex/widgets/home_widgets.dart';

Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .jumpTo(0);
    await tester.pumpAndSettle();
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        180,
        scrollable: find.byType(Scrollable).first,
      );
    }
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> visibleTap(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Home search and scroll state survive category and All Cars routes',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(onboardingData: OnboardingData())),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Nissan');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('2 demo results'), findsOneWidget);
      await visibleTap(tester, find.widgetWithText(CarCategoryTile, 'Economy'));
      expect(find.text('5 demo vehicles'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await visibleTap(tester, find.text('See All'));
      expect(find.text('30 demo vehicles'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await reveal(tester, find.byType(TextField));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Nissan',
      );
      expect(find.text('2 demo results'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'not-a-car');
      await tester.pumpAndSettle();
      await reveal(tester, find.text('No demo cars found'));
      expect(find.text('No demo cars found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Pixel 7 Pro preserves six compact categories, full first card and second title',
    (tester) async {
      tester.view.physicalSize = const Size(412, 892);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(padding: const EdgeInsets.only(top: 24, bottom: 24)),
            child: child!,
          ),
          home: HomeScreen(onboardingData: OnboardingData()),
        ),
      );
      await tester.pumpAndSettle();
      final barTop = tester.getTopLeft(find.byKey(const ValueKey('tab-0'))).dy;
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('car-vantage'))).dy,
        lessThan(barTop),
      );
      expect(
        tester.getTopLeft(find.text('Nissan Sentra 2025')).dy,
        lessThan(barTop),
      );
      expect(find.byType(CarCategoryTile), findsNWidgets(6));
      for (final element in find.byType(CarCategoryTile).evaluate()) {
        final rect = tester.getRect(find.byWidget(element.widget));
        expect(rect.left, greaterThanOrEqualTo(16));
        expect(rect.right, lessThanOrEqualTo(396));
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'All six categories navigate and show their five vehicles with back to Home',
    (tester) async {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            onboardingData: OnboardingData(),
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final category in carCategories) {
        await visibleTap(
          tester,
          find.widgetWithText(CarCategoryTile, category),
        );
        expect(find.byType(CategoryCarsScreen), findsOneWidget);
        expect(
          tester
              .widget<CategoryCarsScreen>(find.byType(CategoryCarsScreen))
              .category,
          category,
        );
        expect(find.text('5 demo vehicles'), findsOneWidget);
        final last = repository.search(category: category).last;
        await tester.scrollUntilVisible(
          find.text(last.name),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.text(last.name), findsOneWidget);
        for (final card in tester.widgetList<DemoCarCard>(
          find.byType(DemoCarCard),
        )) {
          expect(card.car.category, category);
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('See All shows 30 cars and combines search with category chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(onboardingData: OnboardingData())),
    );
    await tester.pumpAndSettle();
    await visibleTap(tester, find.text('See All'));
    expect(find.byType(AllCarsScreen), findsOneWidget);
    expect(find.text('All Cars'), findsOneWidget);
    expect(find.text('30 demo vehicles'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'BMW');
    await tester.pumpAndSettle();
    expect(find.text('3 demo vehicles'), findsOneWidget);
    await visibleTap(tester, find.widgetWithText(FilterChip, 'Electric'));
    expect(find.text('1 demo vehicles'), findsOneWidget);
    expect(find.text('BMW i4'), findsOneWidget);
    expect(find.text('Image unavailable'), findsOneWidget);
    await visibleTap(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'no-such-model');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('No demo cars found'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await visibleTap(tester, find.widgetWithText(FilterChip, 'All'));
    expect(find.text('30 demo vehicles'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('BMW i4'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('BMW i4'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Favorites synchronize across Home, category, all cars, details and Favorites tab',
    (tester) async {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            onboardingData: OnboardingData(),
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await visibleTap(tester, find.byTooltip('Favorite Aston Martin Vantage'));
      await visibleTap(tester, find.widgetWithText(CarCategoryTile, 'Sports'));
      expect(
        find.byTooltip('Remove Aston Martin Vantage from favorites'),
        findsOneWidget,
      );
      await visibleTap(tester, find.byTooltip('View Aston Martin Vantage'));
      expect(find.byType(CarDetailsScreen), findsOneWidget);
      expect(find.textContaining('No live'), findsNothing);
      expect(find.textContaining('Demo vehicle only'), findsOneWidget);
      await visibleTap(tester, find.text('Remove from favorites'));
      expect(repository.byId('vantage').isFavorite, isFalse);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Favorite Aston Martin Vantage'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await visibleTap(tester, find.text('See All'));
      await visibleTap(tester, find.byTooltip('Favorite Aston Martin Vantage'));
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('tab-2')));
      await tester.pumpAndSettle();
      expect(find.text('Aston Martin Vantage'), findsOneWidget);
      await visibleTap(
        tester,
        find.byTooltip('Remove Aston Martin Vantage from favorites'),
      );
      expect(find.text('No favorites yet'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('tab-0')));
      await tester.pumpAndSettle();
      await visibleTap(tester, find.byTooltip('View Aston Martin Vantage'));
      expect(find.byType(CarDetailsScreen), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await visibleTap(tester, find.byTooltip('Notifications'));
      expect(
        find.textContaining('Notifications are not connected yet'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(320, 568), const Size(412, 892)]) {
    testWidgets('All 30 Home cards scroll above fixed navigation at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: HomeScreen(onboardingData: OnboardingData()),
        ),
      );
      await tester.pumpAndSettle();
      final bar = find.byKey(const ValueKey('tab-0'));
      final originalPosition = tester.getTopLeft(bar);
      await tester.scrollUntilVisible(
        find.text('BMW i4'),
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('car-i4')));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(bar), originalPosition);
      expect(
        tester.getBottomLeft(find.byKey(const ValueKey('car-i4'))).dy,
        lessThanOrEqualTo(originalPosition.dy),
      );
      await reveal(tester, find.widgetWithText(CarCategoryTile, 'Economy'));
      await tester.drag(
        find.byKey(const PageStorageKey('categories')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      await visibleTap(
        tester,
        find.widgetWithText(CarCategoryTile, 'Electric'),
      );
      expect(find.text('5 demo vehicles'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('BMW i4'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
