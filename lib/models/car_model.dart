/// Immutable, sample-only inventory record. Favorite state is owned by CarRepository.
class CarModel {
  const CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.imageAssetPath,
    required this.dailyRentalPrice,
    this.currency = 'USD',
    this.rating = 4.7,
    this.tripCount = 8,
    this.location = 'New York',
    this.distanceMiles = 1.9,
    this.isFavorite = false,
    this.showYear = true,
    this.transmission = 'Automatic',
    this.fuelType = 'Petrol',
    this.seatCount = 5,
    this.instantBookEligible = false,
  });
  final String id;
  final String brand;
  final String model;
  final int year;
  final String category;

  /// Null means the actual model's image is unavailable; never substitute another car.
  final String? imageAssetPath;
  final double dailyRentalPrice;
  final String currency;
  final double rating;
  final int tripCount;
  final String location;
  final double distanceMiles;
  final bool isFavorite;
  final bool showYear;
  final String transmission;
  final String fuelType;
  final int seatCount;
  final bool instantBookEligible;

  String get description =>
      'Explore the $brand $model in this local MileX demo. '
      'This $category vehicle has $seatCount seats, $transmission transmission '
      'and $fuelType power. All specifications, prices and pickup details are '
      'sample data for UI testing; availability is not live.';

  String get name => '$brand $model${showYear ? ' $year' : ''}';
  String? get image => imageAssetPath;
  int get trips => tripCount;
  String get distance => '${distanceMiles.toStringAsFixed(1)} mi';
  String get price {
    final digits = dailyRentalPrice.toStringAsFixed(
      dailyRentalPrice == dailyRentalPrice.roundToDouble() ? 0 : 2,
    );
    final parts = digits.split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '${currency == 'USD' ? r'$' : '$currency '}$grouped${parts.length > 1 ? '.${parts.last}' : ''}';
  }

  CarModel withFavorite(bool value) => CarModel(
    id: id,
    brand: brand,
    model: model,
    year: year,
    category: category,
    imageAssetPath: imageAssetPath,
    dailyRentalPrice: dailyRentalPrice,
    currency: currency,
    rating: rating,
    tripCount: tripCount,
    location: location,
    distanceMiles: distanceMiles,
    isFavorite: value,
    showYear: showYear,
    transmission: transmission,
    fuelType: fuelType,
    seatCount: seatCount,
    instantBookEligible: instantBookEligible,
  );
}
