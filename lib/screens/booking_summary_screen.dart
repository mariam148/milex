import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/car_filters.dart';
import '../models/car_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'secure_payment_screen.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({
    super.key,
    required this.car,
    required this.session,
    this.days = 1,
  });
  final CarModel car;
  final DemoSession session;
  final int days;
  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  late final BookingDraft _draft;
  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final pickup = DateTime(now.year, now.month, now.day + 1, 10);
    _draft = BookingDraft(
      car: widget.car,
      pickup: pickup,
      returnAt: pickup.add(Duration(days: widget.days)),
      pickupLocation: widget.car.location,
      dropoffLocation: widget.car.location,
    );
  }

  Future<void> _pick(bool pickup) async {
    final value = pickup ? _draft.pickup : _draft.returnAt;
    final date = await showDatePicker(
      context: context,
      initialDate: value,
      firstDate: pickup
          ? DateUtils.dateOnly(DateTime.now())
          : DateUtils.dateOnly(_draft.pickup),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (!mounted || time == null) return;
    final candidate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (pickup
        ? !candidate.isBefore(_draft.returnAt)
        : !candidate.isAfter(_draft.pickup)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return must be after pickup. Please select another date or time.',
          ),
        ),
      );
      return;
    }
    setState(() {
      if (pickup) {
        _draft.pickup = candidate;
      } else {
        _draft.returnAt = candidate;
      }
    });
  }

  Widget _location(bool pickup) => DropdownButtonFormField<String>(
    initialValue: pickup ? _draft.pickupLocation : _draft.dropoffLocation,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: pickup ? 'Pickup location (demo)' : 'Drop-off location (demo)',
      prefixIcon: const Icon(Icons.location_on_outlined),
    ),
    items: demoPickupLocations
        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
        .toList(),
    onChanged: (value) {
      if (value != null) {
        setState(() {
          if (pickup) {
            _draft.pickupLocation = value;
          } else {
            _draft.dropoffLocation = value;
          }
        });
      }
    },
  );
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Booking Summary',
    footer: DemoAction(
      'Continue',
      onPressed: () {
        if (!_draft.valid) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SecurePaymentScreen(
              draft: _draft.snapshot(),
              session: widget.session,
            ),
          ),
        );
      },
    ),
    children: [
      const DemoNotice(
        'LOCAL DEMO ONLY - sample rental quote. No real reservation or payment.',
      ),
      DemoVehicle(widget.car),
      DemoPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Rental details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              key: const ValueKey('pickup-date'),
              onPressed: () => _pick(true),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Pickup: ${demoDate(_draft.pickup)}'),
            ),
            TextButton.icon(
              key: const ValueKey('return-date'),
              onPressed: () => _pick(false),
              icon: const Icon(Icons.event_outlined),
              label: Text('Return: ${demoDate(_draft.returnAt)}'),
            ),
            _location(true),
            const SizedBox(height: 16),
            _location(false),
          ],
        ),
      ),
      DemoPriceBreakdown(_draft),
      DropdownButtonFormField<String>(
        initialValue: _draft.paymentMethod,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Dummy payment method'),
        items: [
          'Visa demo',
          'Mastercard demo',
        ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _draft.paymentMethod = value);
          }
        },
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Back to car details'),
      ),
    ],
  );
}
