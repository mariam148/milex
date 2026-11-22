import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../models/demo_diagnostic_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'roadside_help_screen.dart';

class DiagnosticDetailsScreen extends StatelessWidget {
  const DiagnosticDetailsScreen({
    super.key,
    required this.car,
    required this.session,
    this.selected,
  });
  final CarModel car;
  final DemoSession session;
  final String? selected;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Diagnostic Details',
    children: [
      const DemoNotice(
        'Simulated diagnostic examples only. No real vehicle telemetry or diagnosis.',
      ),
      Text(
        car.name,
        style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
      ),
      if (selected != null)
        Text(
          'Selected warning: $selected',
          style: const TextStyle(color: demoPurple),
        ),
      for (final item in DemoDiagnosticModel.forCar(car).items)
        DemoPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(item.status),
              const SizedBox(height: 8),
              DemoNotice(item.action),
            ],
          ),
        ),
      DemoAction(
        'Request Roadside Assistance',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RoadsideHelpScreen(session: session, car: car),
          ),
        ),
      ),
    ],
  );
}
