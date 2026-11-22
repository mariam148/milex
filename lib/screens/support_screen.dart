import 'package:flutter/material.dart';

import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'roadside_help_screen.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, required this.session});
  final DemoSession session;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Help & Support',
    children: [
      const Text(
        'How can we help?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const DemoNotice(
        'Local demo support. No live messaging, emergency calls or assistance dispatch.',
      ),
      DemoAction(
        'Roadside Help',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RoadsideHelpScreen(session: session),
          ),
        ),
      ),
      const DemoPanel(
        child: ExpansionTile(
          title: Text('How do demo bookings work?'),
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Choose a car and dates, then use dummy payment confirmation. Records stay in memory and are cleared on logout.',
              ),
            ),
          ],
        ),
      ),
      const DemoPanel(
        child: ExpansionTile(
          title: Text('Are diagnostics live?'),
          children: [
            Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No. Vehicle health and map/provider examples are simulated.',
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
