import 'package:flutter/material.dart';

import '../data/demo_inventory.dart';
import '../repositories/car_repository.dart';
import '../screens/car_details_screen.dart';
import '../screens/filters_screen.dart';
import '../models/car_filters.dart';
import 'home_widgets.dart';

/// Shared lazy listing for category and all-car routes; no nested vertical lists.
class CarListingView extends StatefulWidget {
  const CarListingView({
    super.key,
    required this.title,
    required this.repository,
    this.category,
    this.filters = false,
    this.initialFilters = const CarFilters(),
    this.initialQuery = '',
  });
  final String title;
  final CarRepository repository;
  final String? category;
  final bool filters;
  final CarFilters initialFilters;
  final String initialQuery;
  @override
  State<CarListingView> createState() => _CarListingViewState();
}

class _CarListingViewState extends State<CarListingView> {
  late final _search = TextEditingController(text: widget.initialQuery);
  final _scroll = ScrollController();
  late String? _category = widget.category ?? widget.initialFilters.category;
  late CarFilters _filters = widget.initialFilters;

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final selection = await Navigator.of(context).push<CarFilters>(
      MaterialPageRoute(
        builder: (_) => FiltersScreen(
          repository: widget.repository,
          query: _search.text,
          initialFilters: _filters.withCategory(_category),
        ),
      ),
    );
    if (selection != null && mounted) {
      _update(() {
        _filters = selection;
        _category = selection.category;
      });
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _update(VoidCallback change) {
    setState(change);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.repository,
    builder: (context, _) {
      final cars = widget.repository.search(
        query: _search.text,
        category: _category,
        filters: _filters.withCategory(_category),
      );
      return Scaffold(
        backgroundColor: homeBackground,
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: homeBackground,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              tooltip: 'Filters',
              onPressed: _openFilters,
              icon: const Icon(Icons.tune_rounded, color: homePurple),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: CustomScrollView(
                key: const ValueKey('inventory-scroll'),
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Demo inventory · SAMPLE prices · No live availability',
                            style: TextStyle(color: homeMuted, fontSize: 11),
                          ),
                          ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _search,
                              onChanged: (_) => _update(() {}),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) {
                                FocusScope.of(context).unfocus();
                                _update(() {});
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search by brand or model',
                                hintStyle: const TextStyle(color: homeMuted),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: homeMuted,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: homeSurface,
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: homePurple,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final category in [
                                    'All',
                                    ...carCategories,
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: FilterChip(
                                        label: Text(category),
                                        selected:
                                            (category == 'All'
                                                ? null
                                                : category) ==
                                            _category,
                                        selectedColor: homePurple,
                                        backgroundColor: homeSurface,
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                        onSelected: (_) => _update(
                                          () => _category = category == 'All'
                                              ? null
                                              : category,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '${cars.length} demo vehicles',
                            key: const ValueKey('inventory-count'),
                            style: const TextStyle(
                              color: homeMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (cars.isEmpty)
                    const SliverToBoxAdapter(
                      child: DevelopmentPlaceholder(
                        title: 'No demo cars found',
                        message: 'Try another search, change your filters or use Reset in Filters.',
                        icon: Icons.search_off,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList.builder(
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          final car = cars[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: DemoCarCard(
                              key: ValueKey('car-${car.id}'),
                              car: car,
                              favorite: car.isFavorite,
                              onFavorite: () =>
                                  widget.repository.toggleFavorite(car.id),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => CarDetailsScreen(
                                    carId: car.id,
                                    repository: widget.repository,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
