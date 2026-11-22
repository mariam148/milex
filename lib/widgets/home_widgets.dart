import 'package:flutter/material.dart';

import '../models/car_model.dart';

const homePurple = Color(0xFF6036FF);
const homeBackground = Color(0xFF050519);
const homeSurface = Color(0xFF141426);
const homeMuted = Color(0xFF9695A7);

/// Displays only the original wordmark portion of the existing square logo.
class MileXWordmark extends StatelessWidget {
  const MileXWordmark({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'MileX',
    image: true,
    child: SizedBox(
      width: 88,
      height: 22,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 150,
          maxWidth: 150,
          minHeight: 150,
          maxHeight: 150,
          child: Transform.translate(
            offset: const Offset(-31, -99),
            child: Image.asset(
              'assets/images/milex_logo.png',
              width: 150,
              height: 150,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
}

class CarArtwork extends StatelessWidget {
  const CarArtwork({
    super.key,
    required this.asset,
    this.height,
    this.label,
    this.fit = BoxFit.contain,
  });
  final String? asset;
  final double? height;
  final String? label;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => asset == null
      ? _missing()
      : Image.asset(
          asset!,
          height: height,
          width: double.infinity,
          fit: fit,
          semanticLabel: label,
          excludeFromSemantics: label == null,
          errorBuilder: (_, error, stack) => _missing(),
        );
  Widget _missing() => Semantics(
    label: label ?? 'Car image unavailable',
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_car_outlined, size: 24, color: homeMuted),
            SizedBox(height: 4),
            Text(
              'Image unavailable',
              style: TextStyle(color: homeMuted, fontSize: 9),
            ),
          ],
        ),
      ),
    ),
  );
}

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: -22,
          bottom: 0,
          width: constraints.maxWidth * 0.68,
          top: 0,
          child: const CarArtwork(
            asset: 'assets/images/demo_sports.png',
            fit: BoxFit.contain,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  homeBackground,
                  homeBackground.withValues(alpha: 0.85),
                  homeBackground.withValues(alpha: 0),
                ],
                stops: const [0, 0.3, 0.7],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: SizedBox(
            width: constraints.maxWidth * 0.64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: 'Drive '),
                      TextSpan(
                        text: 'more.',
                        style: TextStyle(color: homePurple),
                      ),
                      TextSpan(text: '\nWorry less.'),
                    ],
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Premium cars.\nSeamless experience.',
                  style: TextStyle(
                    color: homeMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class CarCategoryTile extends StatelessWidget {
  const CarCategoryTile({
    super.key,
    required this.name,
    required this.image,
    required this.selected,
    required this.onTap,
  });
  final String name;
  final String image;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '$name category',
    child: Material(
      color: selected ? const Color(0xFF28204D) : homeSurface,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 56 + (MediaQuery.textScalerOf(context).scale(9) - 9) * 5,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? homePurple : const Color(0xFF28283B),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CarArtwork(asset: image, height: 27),
              const SizedBox(height: 3),
              Text(
                name,
                maxLines: 1,
                style: TextStyle(
                  color: selected ? Colors.white : homeMuted,
                  fontSize: 9,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class DemoCarCard extends StatelessWidget {
  const DemoCarCard({
    super.key,
    required this.car,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });
  final CarModel car;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: homeSurface,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFCA68),
                            size: 13,
                          ),
                          Text(
                            '${car.rating}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '(${car.trips} trips)',
                            style: const TextStyle(
                              color: homeMuted,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    tooltip: favorite
                        ? 'Remove ${car.name} from favorites'
                        : 'Favorite ${car.name}',
                    isSelected: favorite,
                    onPressed: onFavorite,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      favorite ? Icons.favorite : Icons.favorite_border,
                      color: favorite ? homePurple : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2.35,
                child: CarArtwork(
                  asset: car.image,
                  fit: BoxFit.cover,
                  label: car.image == null
                      ? '${car.name}: image unavailable'
                      : '${car.name}, illustrative demo image',
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: car.price,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 1.2,
                                color: homePurple,
                              ),
                            ),
                            const TextSpan(
                              text: '/day · SAMPLE',
                              style: TextStyle(color: homeMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 3,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: homeMuted,
                            ),
                            Text(
                              '${car.location} · ${car.distance}',
                              style: const TextStyle(
                                color: homeMuted,
                                fontSize: 10,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton.filled(
                    tooltip: 'View ${car.name}',
                    onPressed: onTap,
                    style: IconButton.styleFrom(
                      backgroundColor: homePurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class DevelopmentPlaceholder extends StatelessWidget {
  const DevelopmentPlaceholder({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });
  final String title;
  final String message;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
    child: Column(
      children: [
        Icon(icon, size: 48, color: homePurple),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: homeMuted, height: 1.5),
        ),
      ],
    ),
  );
}
