import 'package:flutter/material.dart';

import '../repositories/car_repository.dart';
import '../widgets/demo_widgets.dart';
import '../widgets/home_widgets.dart';
import 'car_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, required this.repository});
  final CarRepository repository;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: repository,
    builder: (context, _) => DemoPage(
      title: 'Favorites',
      children: [
        const Text(
          'Saved Cars',
          style: TextStyle(color: demoPurple, fontWeight: FontWeight.w600),
        ),
        if (repository.favorites.isEmpty)
          const DevelopmentPlaceholder(
            title: 'No favorites yet',
            message: 'Tap a car heart to save it for this demo session.',
            icon: Icons.favorite_border,
          ),
        for (final car in repository.favorites)
          DemoCarCard(
            key: ValueKey('car-${car.id}'),
            car: car,
            favorite: true,
            onFavorite: () => repository.toggleFavorite(car.id),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    CarDetailsScreen(carId: car.id, repository: repository),
              ),
            ),
          ),
      ],
    ),
  );
}
