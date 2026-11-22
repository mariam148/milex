import 'package:flutter/material.dart';

import '../models/demo_car.dart';
import '../models/onboarding_data.dart';
import '../repositories/car_repository.dart';
import 'all_cars_screen.dart';
import 'category_cars_screen.dart';
import 'car_details_screen.dart';
import 'filters_screen.dart';
import 'my_bookings_screen.dart';
import 'favorites_screen.dart';
import 'my_profile_screen.dart';
import 'support_screen.dart';
import '../services/demo_session.dart';
import '../auth/auth_navigation.dart';
import '../models/car_filters.dart';
import '../widgets/home_widgets.dart';

/// Development preview. This screen does not establish an authenticated session.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onboardingData, this.repository});
  final OnboardingData onboardingData;
  final CarRepository? repository;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();
  late final CarRepository _repository;
  late final DemoSession _session;
  int _tab = 0;
  String _query = '';
  String? _category;
  static const _tabs = ['Home', 'Bookings', 'Favorites', 'Support', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.calendar_month_outlined,
    Icons.favorite_border,
    Icons.headset_mic_outlined,
    Icons.person_outline,
  ];
  static const _activeIcons = [
    Icons.home,
    Icons.calendar_month,
    Icons.favorite,
    Icons.headset_mic,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? CarRepository();
    _repository.addListener(_refresh);
    _session = DemoSession.forCars(_repository);
    _session.profile = widget.onboardingData;
    DemoNavigation.useSession(_session);
    _session.showBookings = _showBookings;
    _session.addListener(_refresh);
  }

  void _showBookings() {
    if (mounted) setState(() => _tab = 1);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _repository.removeListener(_refresh);
    _session.removeListener(_refresh);
    if (_session.showBookings == _showBookings) {
      _session.showBookings = null;
    }
    _search.dispose();
    super.dispose();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    setState(() => _query = _search.text.trim().toLowerCase());
  }

  Future<void> _openFilters() async {
    FocusScope.of(context).unfocus();
    final selection = await Navigator.of(context).push<CarFilters>(
      MaterialPageRoute(
        builder: (_) => FiltersScreen(repository: _repository, query: _query),
      ),
    );
    if (selection != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AllCarsScreen(
            repository: _repository,
            initialQuery: _query,
            initialFilters: selection,
            title: 'Search Results',
          ),
        ),
      );
    }
  }

  void _showPlaceholder(String title, String message, IconData icon) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            backgroundColor: homeBackground,
            appBar: AppBar(title: Text(title), backgroundColor: homeBackground),
            body: SafeArea(
              child: SingleChildScrollView(
                child: DevelopmentPlaceholder(
                  title: 'Development preview',
                  message: message,
                  icon: icon,
                ),
              ),
            ),
          ),
        ),
      );
  void _openCar(CarModel car) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => CarDetailsScreen(carId: car.id, repository: _repository),
    ),
  );
  void _openCategory(String category) {
    setState(() => _category = category);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            CategoryCarsScreen(category: category, repository: _repository),
      ),
    );
  }

  Widget _card(CarModel car) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DemoCarCard(
      key: ValueKey('car-${car.id}'),
      car: car,
      favorite: car.isFavorite,
      onFavorite: () => _repository.toggleFavorite(car.id),
      onTap: () => _openCar(car),
    ),
  );
  List<Widget> _home() {
    final cars = _repository.search(query: _query);
    final categoryHeight = 44 + MediaQuery.textScalerOf(context).scale(9) * 1.4;
    return [
      const HomeHero(),
      const SizedBox(height: 10),
      TextField(
        controller: _search,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        onChanged: (value) =>
            setState(() => _query = value.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search cars, brands, models...',
          hintStyle: const TextStyle(color: homeMuted, fontSize: 11),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 40,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          filled: true,
          fillColor: homeSurface,
          prefixIcon: const Icon(Icons.search, color: homeMuted, size: 18),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(4),
            child: IconButton.filled(
              tooltip: 'Search cars',
              onPressed: _submitSearch,
              style: IconButton.styleFrom(
                backgroundColor: homePurple,
                minimumSize: const Size(30, 30),
                padding: const EdgeInsets.all(6),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF252538)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: homePurple),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: categoryHeight,
        child: ListView.separated(
          key: const PageStorageKey('categories'),
          scrollDirection: Axis.horizontal,
          itemCount: demoCategories.length,
          separatorBuilder: (_, index) => const SizedBox(width: 6),
          itemBuilder: (_, index) {
            final entry = demoCategories.entries.elementAt(index);
            return CarCategoryTile(
              name: entry.key,
              image: entry.value,
              selected: _category == entry.key,
              onTap: () => _openCategory(entry.key),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Cars nearby',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded, color: homePurple),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AllCarsScreen(repository: _repository),
              ),
            ),
            child: const Text(
              'See All',
              style: TextStyle(color: homePurple, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      if (_query.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${cars.length} demo results',
            style: const TextStyle(color: homeMuted, fontSize: 12),
          ),
        ),
      const SizedBox(height: 4),
      if (cars.isEmpty)
        const DevelopmentPlaceholder(
          title: 'No demo cars found',
          message: 'Try another search or category, or choose See All.',
          icon: Icons.search_off,
        ),
    ];
  }

  List<Widget> _content() => _home();

  @override
  Widget build(BuildContext context) {
    final cars = _tab == 0
        ? _repository.search(query: _query)
        : _tab == 2
        ? _repository.favorites
        : <CarModel>[];
    return Scaffold(
      backgroundColor: _tab == 4 ? const Color(0xFF080D1B) : homeBackground,
      body: _tab != 0
          ? switch (_tab) {
              1 => MyBookingsScreen(session: _session),
              2 => FavoritesScreen(repository: _repository),
              3 => SupportScreen(session: _session),
              _ => MyProfileScreen(session: _session),
            }
          : SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: CustomScrollView(
                    key: PageStorageKey('home-tab-$_tab'),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const MileXWordmark(
                                    key: ValueKey('home-wordmark'),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    tooltip: 'Notifications',
                                    onPressed: () => _showPlaceholder(
                                      'Notifications',
                                      'Notifications are not connected yet. This preview does not show real alerts.',
                                      Icons.notifications_none,
                                    ),
                                    icon: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              ..._content(),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        sliver: SliverList.builder(
                          itemCount: cars.length,
                          itemBuilder: (context, index) => _card(cars[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: _tab == 4
            ? EdgeInsets.zero
            : const EdgeInsets.fromLTRB(12, 0, 12, 6),
        child: Material(
          color: _tab == 4 ? const Color(0xFF10131E) : const Color(0xFF0D0D20),
          shape: RoundedRectangleBorder(
            borderRadius: _tab == 4
                ? const BorderRadius.vertical(top: Radius.circular(24))
                : BorderRadius.circular(18),
            side: BorderSide(
              color: _tab == 4 ? Colors.transparent : const Color(0xFF252538),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                _tabs.length,
                (index) => Expanded(
                  child: Semantics(
                    selected: _tab == index,
                    button: true,
                    label: '${_tabs[index]} tab',
                    child: InkWell(
                      key: ValueKey('tab-$index'),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        setState(() => _tab = index);
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 6,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tab == index
                                    ? _activeIcons[index]
                                    : _icons[index],
                                color: _tab == index ? homePurple : homeMuted,
                                size: 18,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _tabs[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _tab == index ? homePurple : homeMuted,
                                  fontSize: 8.5,
                                  height: 1.2,
                                  fontWeight: _tab == index
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
