import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'car_health_screen.dart';

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({
    super.key,
    required this.booking,
    required this.session,
  });
  final BookingModel booking;
  final DemoSession session;
  @override
  Widget build(BuildContext context) {
    final draft = booking.details;
    return DemoPage(
      title: 'Booking Details',
      children: [
        const DemoNotice(
          'Local demo booking. No external transaction or reservation.',
        ),
        DemoVehicle(draft.car),
        Text(booking.reference),
        Text('Status: ${booking.statusAt(DateTime.now()).name} (demo)'),
        Text(
          'Pickup: ${demoDate(draft.pickup)}\nReturn: ${demoDate(draft.returnAt)}\nFrom: ${draft.pickupLocation}\nTo: ${draft.dropoffLocation}',
          style: const TextStyle(height: 1.8),
        ),
        DemoPriceBreakdown(draft),
        DemoAction(
          'Car Health',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CarHealthScreen(car: draft.car, session: session),
            ),
          ),
        ),
      ],
    );
  }
}
