import 'package:flutter/material.dart';

import '../data/demo_inventory.dart';
import '../models/car_filters.dart';
import '../repositories/car_repository.dart';
import '../widgets/home_widgets.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({
    super.key,
    required this.repository,
    this.initialFilters = const CarFilters(),
    this.query = '',
  });
  final CarRepository repository;
  final CarFilters initialFilters;
  final String query;
  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  late RangeValues _prices;
  String? _category, _brand, _transmission, _fuel, _pickup;
  int? _seats;
  double? _rating;
  double _radius = 25;
  bool _instant = false, _allBrands = false;

  @override
  void initState() {
    super.initState();
    _load(widget.initialFilters);
  }

  void _load(CarFilters value) {
    final min = widget.repository.minPrice, max = widget.repository.maxPrice;
    final low = (value.minPrice ?? min).clamp(min, max);
    _prices = RangeValues(low, (value.maxPrice ?? max).clamp(low, max));
    _category = value.category;
    _brand = value.brand;
    _transmission = value.transmission;
    _fuel = value.fuelType;
    _pickup = value.pickupLocation;
    _seats = value.seats;
    _rating = value.minRating;
    _radius = value.radiusMiles;
    _instant = value.instantBook;
  }

  CarFilters get _selection => CarFilters(
    minPrice: _prices.start == widget.repository.minPrice
        ? null
        : _prices.start,
    maxPrice: _prices.end == widget.repository.maxPrice ? null : _prices.end,
    category: _category,
    brand: _brand,
    transmission: _transmission,
    fuelType: _fuel,
    seats: _seats,
    minRating: _rating,
    pickupLocation: _pickup,
    radiusMiles: _radius,
    instantBook: _instant,
  );

  Widget _section(String title, Widget child, {Widget? action}) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: homeSurface,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );

  Widget _choices<T>(
    List<T> values,
    T? selected,
    ValueChanged<T?> changed, {
    String Function(T)? label,
    bool horizontal = false,
  }) {
    final items = values
        .map(
          (value) => ChoiceChip(
            key: ValueKey('filter-${label?.call(value) ?? value.toString()}'),
            label: Text(label?.call(value) ?? value.toString()),
            selected: value == selected,
            selectedColor: homePurple,
            backgroundColor: const Color(0xFF1B1B30),
            labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
            onSelected: (on) => setState(() => changed(on ? value : null)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
        .toList();
    if (horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: item,
                ),
              )
              .toList(),
        ),
      );
    }
    return Wrap(spacing: 8, runSpacing: 8, children: items);
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.repository
        .search(query: widget.query, filters: _selection)
        .length;
    final brands =
        widget.repository.cars.map((car) => car.brand).toSet().toList()..sort();
    final popular = ['BMW', 'Mercedes-Benz', 'Audi', 'Porsche', 'Tesla'];
    return Scaffold(
      backgroundColor: homeBackground,
      appBar: AppBar(
        backgroundColor: homeBackground,
        foregroundColor: Colors.white,
        title: const Text('Filters'),
        actions: [
          TextButton(
            key: const ValueKey('reset-filters'),
            onPressed: () => setState(() {
              _load(const CarFilters());
              _allBrands = false;
            }),
            child: const Text('Reset', style: TextStyle(color: homePurple)),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Demo inventory only. Pickup zones and distances are simulated, not GPS-based availability.',
                  style: TextStyle(color: homeMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                _section(
                  'Price Range',
                  Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Text('USD ${_prices.start.toStringAsFixed(0)} / day'),
                          Text('USD ${_prices.end.toStringAsFixed(0)} / day'),
                        ],
                      ),
                      RangeSlider(
                        values: _prices,
                        min: widget.repository.minPrice,
                        max: widget.repository.maxPrice,
                        divisions:
                            (widget.repository.maxPrice -
                                    widget.repository.minPrice)
                                .round(),
                        activeColor: homePurple,
                        labels: RangeLabels(
                          _prices.start.toStringAsFixed(0),
                          _prices.end.toStringAsFixed(0),
                        ),
                        onChanged: (value) => setState(() => _prices = value),
                      ),
                    ],
                  ),
                ),
                _section(
                  'Car Type',
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in carCategories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CarCategoryTile(
                              name: category,
                              image: demoCategories[category]!,
                              selected: _category == category,
                              onTap: () => setState(
                                () => _category = _category == category
                                    ? null
                                    : category,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _section(
                  'Brand',
                  _choices(
                    _allBrands ? brands : popular,
                    _brand,
                    (v) => _brand = v,
                    label: (v) => v == 'Mercedes-Benz' ? 'Mercedes' : v,
                    horizontal: true,
                  ),
                  action: TextButton(
                    onPressed: () => setState(() => _allBrands = !_allBrands),
                    child: Text(
                      _allBrands ? 'Show Less' : 'See All',
                      style: const TextStyle(color: homePurple),
                    ),
                  ),
                ),
                _section(
                  'Transmission',
                  _choices(
                    ['Automatic', 'Manual'],
                    _transmission,
                    (v) => _transmission = v,
                  ),
                ),
                _section(
                  'Fuel Type',
                  _choices(
                    ['Petrol', 'Diesel', 'Hybrid', 'Electric'],
                    _fuel,
                    (v) => _fuel = v,
                  ),
                ),
                _section(
                  'Seats',
                  _choices(
                    [2, 4, 5, 7],
                    _seats,
                    (v) => _seats = v,
                    label: (v) => v == 7 ? '7+' : '$v',
                  ),
                ),
                _section(
                  'Rating',
                  _choices(
                    [4.0, 4.5, 4.8],
                    _rating,
                    (v) => _rating = v,
                    label: (v) => '${v.toStringAsFixed(1)}+',
                  ),
                ),
                _section(
                  'Pickup Location',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DropdownButtonFormField<String>(
                        key: ValueKey('pickup-$_pickup'),
                        initialValue: _pickup ?? 'Any location',
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          labelText: 'Demo pickup zone',
                        ),
                        items: ['Any location', ...demoPickupLocations]
                            .map(
                              (v) => DropdownMenuItem(value: v, child: Text(v)),
                            )
                            .toList(),
                        onChanged: (v) => setState(
                          () => _pickup = v == 'Any location' ? null : v,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Sample radius: ${_radius.toStringAsFixed(0)} mi'),
                      Slider(
                        value: _radius,
                        min: 1,
                        max: 25,
                        divisions: 24,
                        activeColor: homePurple,
                        label: '${_radius.toStringAsFixed(0)} mi',
                        onChanged: _pickup == null
                            ? null
                            : (v) => setState(() => _radius = v),
                      ),
                    ],
                  ),
                ),
                _section(
                  'Instant Book',
                  Material(
                    color: Colors.transparent,
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Instant Book eligible',
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Demo flag only; no reservation is made.',
                        style: TextStyle(color: homeMuted, fontSize: 12),
                      ),
                      value: _instant,
                      activeThumbColor: homePurple,
                      onChanged: (v) => setState(() => _instant = v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            key: const ValueKey('show-filter-results'),
            style: FilledButton.styleFrom(
              backgroundColor: homePurple,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => Navigator.of(context).pop(_selection),
            child: Text('Show Results ($count)'),
          ),
        ),
      ),
    );
  }
}
