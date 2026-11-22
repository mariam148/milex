import 'package:flutter/material.dart';

import '../repositories/car_repository.dart';
import '../widgets/car_listing_view.dart';
import '../models/car_filters.dart';

class AllCarsScreen extends StatelessWidget {
  const AllCarsScreen({
    super.key,
    required this.repository,
    this.initialQuery = '',
    this.initialFilters = const CarFilters(),
    this.title = 'All Cars',
  });
  final CarRepository repository;
  final String initialQuery;
  final CarFilters initialFilters;
  final String title;
  @override
  Widget build(BuildContext context) => CarListingView(
    title: title,
    repository: repository,
    filters: true,
    initialQuery: initialQuery,
    initialFilters: initialFilters,
  );
}
