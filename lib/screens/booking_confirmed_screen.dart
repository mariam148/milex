import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'my_bookings_screen.dart';

class BookingConfirmedScreen extends StatelessWidget {
  const BookingConfirmedScreen({
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
      title: 'Booking Confirmed',
      footer: DemoAction(
        'View My Booking',
        onPressed: () {
          session.bookingTab = booking.statusAt(DateTime.now());
          final selectTab = session.showBookings;
          if (selectTab != null) {
            selectTab();
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => MyBookingsScreen(session: session),
              ),
            );
          }
        },
      ),
      children: [
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: demoPurple,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 58,
              color: Color(0xFF5CE4A0),
            ),
          ),
        ),
        const Text(
          'Booking Confirmed!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const DemoNotice(
          'Demo booking - no real reservation or payment was made.',
        ),
        DemoVehicle(draft.car),
        DemoPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(booking.reference),
              Text(
                'Pickup: ${demoDate(draft.pickup)}\nReturn: ${demoDate(draft.returnAt)}\nPickup location: ${draft.pickupLocation}',
                style: const TextStyle(height: 1.8),
              ),
              Text(
                'Total: ${demoMoney(draft.totalCents, draft.car.currency)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
