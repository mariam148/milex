import 'package:flutter_test/flutter_test.dart';
import 'package:milex/data/demo_inventory.dart';
import 'package:milex/repositories/car_repository.dart';

void main() {
  test('Inventory has exactly the requested 30 unique vehicles and five per category', () {
    final repository = CarRepository();
    addTearDown(repository.dispose);
    expect(repository.cars.length, 30);
    expect(repository.cars.map((car) => car.id).toSet().length, 30);
    expect(repository.cars.map((car) => car.name).toSet().length, 30);
    final expected = {
      'Economy': [
        'Toyota Corolla 2025',
        'Nissan Sentra 2025',
        'Hyundai Elantra 2025',
        'Kia Cerato 2024',
        'Honda Civic 2025',
      ],
      'SUV': [
        'Toyota RAV4 2025',
        'Hyundai Tucson 2025',
        'Kia Sportage 2025',
        'Nissan X-Trail 2024',
        'BMW X5 2025',
      ],
      'Sports': [
        'Aston Martin Vantage',
        'Porsche 911 Carrera',
        'Ford Mustang GT',
        'Chevrolet Corvette C8',
        'Toyota GR Supra',
      ],
      'Family': [
        'Toyota Sienna 2025',
        'Honda Odyssey 2025',
        'Kia Carnival 2025',
        'Hyundai Santa Fe 2025',
        'Volkswagen Tiguan 2025',
      ],
      'Luxury': [
        'Mercedes-Benz S-Class',
        'BMW 7 Series',
        'Audi A8',
        'Lexus LS 500',
        'Porsche Panamera',
      ],
      'Electric': [
        'Tesla Model 3',
        'Tesla Model Y',
        'Hyundai IONIQ 5',
        'Kia EV6',
        'BMW i4',
      ],
    };
    for (final category in carCategories) {
      expect(
        repository.search(category: category).map((car) => car.name),
        unorderedEquals(expected[category]!),
      );
    }
    expect(
      repository.cars.where((car) => car.imageAssetPath == null).length,
      28,
    );
    expect(
      repository.cars.every(
        (car) => car.dailyRentalPrice > 0 && car.currency == 'USD',
      ),
      isTrue,
    );
    expect(repository.byId('vantage').price, r'$1,899');
  });

  test(
    'Search combines brand/model terms with category and favorites notify once',
    () {
      final repository = CarRepository();
      addTearDown(repository.dispose);
      expect(repository.search(query: '  BMW  ').length, 3);
      expect(
        repository.search(query: 'tesla model', category: 'Electric').length,
        2,
      );
      expect(repository.search(query: 'tesla', category: 'SUV'), isEmpty);
      var notifications = 0;
      repository.addListener(() => notifications++);
      repository.toggleFavorite('i4');
      expect(repository.byId('i4').isFavorite, isTrue);
      expect(repository.favorites.single.id, 'i4');
      repository.toggleFavorite('i4');
      expect(repository.favorites, isEmpty);
      expect(notifications, 2);
    },
  );
}
