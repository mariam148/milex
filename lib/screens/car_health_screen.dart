import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../models/demo_diagnostic_model.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'diagnostic_details_screen.dart';
import 'roadside_help_screen.dart';

class CarHealthScreen extends StatelessWidget {
  const CarHealthScreen({super.key, required this.car, required this.session});
  final CarModel car;
  final DemoSession session;
  @override
  Widget build(BuildContext context) {
    final diagnostics = DemoDiagnosticModel.forCar(car);
    return DemoPage(
      title: 'Car Health',
      children: [
        const DemoNotice(
          'SIMULATED DIAGNOSTICS - not connected to a vehicle. No live sensor readings.',
        ),
        DemoVehicle(car),
        const Text(
          'Vehicle health: sample warnings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        for (final item in diagnostics.items)
          DemoPanel(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                item.warning
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                color: item.warning ? Colors.amber : Colors.greenAccent,
              ),
              title: Text(item.name),
              subtitle: Text(item.status),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DiagnosticDetailsScreen(
                    car: car,
                    session: session,
                    selected: item.name,
                  ),
                ),
              ),
            ),
          ),
        const Text(
          'Roadside Assistance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
}
