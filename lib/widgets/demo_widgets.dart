import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../models/booking_model.dart';
import 'home_widgets.dart';

const demoPurple = Color(0xFF6036FF);

class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.children,
    this.footer,
    this.actions,
  });
  final String title;
  final List<Widget> children;
  final Widget? footer;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: homeBackground,
    appBar: AppBar(
      backgroundColor: homeBackground,
      foregroundColor: Colors.white,
      title: Text(title),
      actions: actions,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              for (final child in children)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: child,
                ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: footer == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: footer,
            ),
          ),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: homeMuted, fontSize: 12, height: 1.5),
  );
}

class DemoPanel extends StatelessWidget {
  const DemoPanel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Material(
    color: homeSurface,
    borderRadius: BorderRadius.circular(16),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
}

class DemoAction extends StatelessWidget {
  const DemoAction(this.label, {super.key, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: demoPurple,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}

class DemoVehicle extends StatelessWidget {
  const DemoVehicle(this.car, {super.key});
  final CarModel car;
  @override
  Widget build(BuildContext context) => DemoPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CarArtwork(
          asset: car.image,
          height: 120,
          label: '${car.name}: demo artwork',
        ),
        const SizedBox(height: 12),
        Text(
          car.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${car.transmission} / ${car.seatCount} seats / ${car.fuelType}',
          style: const TextStyle(color: homeMuted, height: 1.6),
        ),
      ],
    ),
  );
}

class DemoPriceBreakdown extends StatelessWidget {
  const DemoPriceBreakdown(this.draft, {super.key});
  final BookingDraft draft;
  @override
  Widget build(BuildContext context) => DemoPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Daily price: ${demoMoney(draft.dailyCents, draft.car.currency)}'),
        Text('Rental days: ${draft.days} (each started 24-hour period)'),
        const SizedBox(height: 12),
        Text(
          'Sample subtotal: ${demoMoney(draft.subtotalCents, draft.car.currency)}',
          key: const ValueKey('booking-subtotal'),
        ),
        Text(
          'Demo service fee (5% of rental): ${demoMoney(draft.serviceFeeCents, draft.car.currency)}',
        ),
        Text(
          'Demo tax (8% of rental): ${demoMoney(draft.taxCents, draft.car.currency)}',
        ),
        const Divider(height: 24),
        Text(
          'Total: ${demoMoney(draft.totalCents, draft.car.currency)}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const DemoNotice(
          'Sample assumptions only. No deposit or real pricing quote.',
        ),
      ],
    ),
  );
}
