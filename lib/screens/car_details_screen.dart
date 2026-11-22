import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../services/demo_session.dart';
import 'booking_summary_screen.dart';
import '../repositories/car_repository.dart';
import '../widgets/home_widgets.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({
    super.key,
    required this.carId,
    required this.repository,
  });
  final String carId;
  final CarRepository repository;
  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  int _days = 1;

  Widget _spec(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: homeSurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: homePurple, size: 19),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.repository,
    builder: (context, _) {
      final car = widget.repository.byId(widget.carId);
      return Scaffold(
        backgroundColor: homeBackground,
        appBar: AppBar(
          backgroundColor: homeBackground,
          foregroundColor: Colors.white,
          title: const Text('Car Details'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 688),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 2.35,
                        child: CarArtwork(
                          asset: car.image,
                          fit: BoxFit.cover,
                          label: car.image == null
                              ? '${car.name}: image unavailable'
                              : '${car.name}: illustrative demo image',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      car.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC75B),
                          size: 20,
                        ),
                        Text(
                          '${car.rating.toStringAsFixed(1)} rating · ${car.tripCount} sample trips',
                          style: const TextStyle(color: homeMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Specifications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _spec(Icons.settings_outlined, car.transmission),
                        _spec(Icons.local_gas_station_outlined, car.fuelType),
                        _spec(
                          Icons.event_seat_outlined,
                          '${car.seatCount} seats',
                        ),
                        _spec(Icons.directions_car_outlined, car.category),
                        _spec(Icons.calendar_today_outlined, '${car.year}'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'About this car',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      car.description,
                      style: const TextStyle(color: homeMuted, height: 1.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo pickup: ${car.location} · ${car.distance} sample local distance',
                      style: const TextStyle(color: homeMuted, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      key: const ValueKey('rental-duration'),
                      initialValue: _days,
                      decoration: InputDecoration(
                        labelText: 'Rental duration',
                        prefixIcon: const Icon(Icons.date_range_outlined),
                        filled: true,
                        fillColor: homeSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [1, 3, 7, 14, 30]
                          .map(
                            (days) => DropdownMenuItem(
                              value: days,
                              child: Text(
                                '$days ${days == 1 ? 'day' : 'days'}',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (days) {
                        if (days != null) {
                          setState(() => _days = days);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => widget.repository.toggleFavorite(car.id),
                      icon: Icon(
                        car.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: homePurple,
                      ),
                      label: Text(
                        car.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        style: const TextStyle(color: homePurple),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Demo vehicle only. Availability is simulated; no identity verification or real reservation.',
                      style: TextStyle(
                        color: homeMuted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Text(
                  '${car.price} / day\nSample ${car.currency} price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: homePurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                  ),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BookingSummaryScreen(
                        car: car,
                        days: _days,
                        session: DemoSession.forCars(widget.repository),
                      ),
                    ),
                  ),
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Compatibility entry point for the original local booking preview.
class DemoBookingSummaryScreen extends StatelessWidget {
  const DemoBookingSummaryScreen({
    super.key,
    required this.car,
    required this.days,
  });
  final CarModel car;
  final int days;
  @override
  Widget build(BuildContext context) => BookingSummaryScreen(
    car: car,
    days: days,
    session: DemoSession.forCars(CarRepository()),
  );
}
