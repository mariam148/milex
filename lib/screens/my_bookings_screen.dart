import 'dart:async';

import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key, required this.session});
  final DemoSession session;
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late DemoBookingStatus _status = widget.session.bookingTab;
  Timer? _clock;
  @override
  void initState() {
    super.initState();
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.session.bookings,
    builder: (context, _) {
      final bookings = widget.session.bookings.forStatus(
        _status,
        DateTime.now(),
      );
      return DemoPage(
        title: 'My Bookings',
        children: [
          const DemoNotice(
            'Only bookings you create in this demo session appear here. No real rental or payment.',
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in DemoBookingStatus.values)
                ChoiceChip(
                  label: Text(
                    status.name[0].toUpperCase() + status.name.substring(1),
                  ),
                  selected: status == _status,
                  selectedColor: demoPurple,
                  onSelected: (_) => setState(() {
                    _status = status;
                    widget.session.bookingTab = status;
                  }),
                ),
            ],
          ),
          if (bookings.isEmpty)
            DemoPanel(child: Text('No ${_status.name} demo bookings yet.')),
          for (final booking in bookings)
            DemoPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DemoVehicle(booking.details.car),
                  const SizedBox(height: 12),
                  Text(booking.reference),
                  Text(
                    'Status: ${booking.statusAt(DateTime.now()).name} (demo)',
                  ),
                  Text(
                    '${demoDate(booking.details.pickup)}\nto ${demoDate(booking.details.returnAt)}',
                  ),
                  const SizedBox(height: 12),
                  DemoAction(
                    'View Details',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => BookingDetailsScreen(
                          booking: booking,
                          session: widget.session,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}
