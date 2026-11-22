import 'car_model.dart';

/// Immutable local filter selection. Null means any value.
class CarFilters {
  const CarFilters({
    this.minPrice,
    this.maxPrice,
    this.category,
    this.brand,
    this.transmission,
    this.fuelType,
    this.seats,
    this.minRating,
    this.pickupLocation,
    this.radiusMiles = 25,
    this.instantBook = false,
  });
  final double? minPrice, maxPrice, minRating;
  final String? category, brand, transmission, fuelType, pickupLocation;
  final int? seats;
  final double radiusMiles;
  final bool instantBook;

  CarFilters withCategory(String? value) => CarFilters(
    minPrice: minPrice,
    maxPrice: maxPrice,
    category: value,
    brand: brand,
    transmission: transmission,
    fuelType: fuelType,
    seats: seats,
    minRating: minRating,
    pickupLocation: pickupLocation,
    radiusMiles: radiusMiles,
    instantBook: instantBook,
  );

  bool matches(CarModel car) =>
      (minPrice == null || car.dailyRentalPrice >= minPrice!) &&
      (maxPrice == null || car.dailyRentalPrice <= maxPrice!) &&
      (category == null || car.category == category) &&
      (brand == null || car.brand == brand) &&
      (transmission == null || car.transmission == transmission) &&
      (fuelType == null || car.fuelType == fuelType) &&
      (seats == null ||
          (seats == 7 ? car.seatCount >= 7 : car.seatCount == seats)) &&
      (minRating == null || car.rating >= minRating!) &&
      (!instantBook || car.instantBookEligible) &&
      (pickupLocation == null ||
          demoPickupDistance(car, pickupLocation!) <= radiusMiles);
}

const demoPickupLocations = ['New York', 'Brooklyn', 'Jersey City'];

/// Synthetic hub-to-pickup distances for UI testing; never device/GPS distances.
/// Each car's sample local distance is added to a fixed demo hub route distance.
double demoPickupDistance(CarModel car, String origin) {
  if (origin == car.location) return car.distanceMiles;
  final pair = {origin, car.location};
  final hubMiles = pair.contains('Brooklyn') && pair.contains('Jersey City')
      ? 12.0
      : 6.0;
  return hubMiles + car.distanceMiles;
}
