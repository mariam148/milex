import 'package:flutter/material.dart';

import '../repositories/car_repository.dart';
import '../widgets/car_listing_view.dart';

class CategoryCarsScreen extends StatelessWidget {
  const CategoryCarsScreen({
    super.key,
    required this.category,
    required this.repository,
  });
  final String category;
  final CarRepository repository;
  @override
  Widget build(BuildContext context) => CarListingView(
    title: category,
    category: category,
    repository: repository,
  );
}
