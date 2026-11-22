import 'package:flutter/foundation.dart';

import '../data/demo_inventory.dart';
import '../models/car_model.dart';
import '../models/car_filters.dart';

/// One in-memory repository per Home session, shared by all browsing routes.
class CarRepository extends ChangeNotifier {
  CarRepository() : _cars = List.of(demoInventory);
  final List<CarModel> _cars;
  List<CarModel> get cars => List.unmodifiable(_cars);
  List<CarModel> get favorites =>
      _cars.where((car) => car.isFavorite).toList(growable: false);
  CarModel byId(String id) => _cars.firstWhere((car) => car.id == id);
  double get minPrice =>
      _cars.map((car) => car.dailyRentalPrice).reduce((a, b) => a < b ? a : b);
  double get maxPrice =>
      _cars.map((car) => car.dailyRentalPrice).reduce((a, b) => a > b ? a : b);
  List<CarModel> search({
    String query = '',
    String? category,
    CarFilters filters = const CarFilters(),
  }) {
    final terms = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty);
    return _cars
        .where(
          (car) =>
              (category == null || car.category == category) &&
              filters.matches(car) &&
              terms.every(car.name.toLowerCase().contains),
        )
        .toList(growable: false);
  }

  void toggleFavorite(String id) {
    final index = _cars.indexWhere((car) => car.id == id);
    if (index < 0) return;
    _cars[index] = _cars[index].withFavorite(!_cars[index].isFavorite);
    notifyListeners();
  }
}
