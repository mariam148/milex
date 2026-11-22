import 'package:flutter/material.dart';

import '../models/car_filters.dart';
import '../models/demo_assistance_request.dart';
import '../widgets/demo_widgets.dart';

class NearbyMechanicsScreen extends StatefulWidget {
  const NearbyMechanicsScreen({super.key, required this.request});
  final DemoAssistanceRequest request;
  @override
  State<NearbyMechanicsScreen> createState() => _NearbyMechanicsScreenState();
}

class _NearbyMechanicsScreenState extends State<NearbyMechanicsScreen> {
  late String _location = widget.request.location;
  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Nearby Mechanics',
    children: [
      const DemoNotice(
        'SIMULATED MAP AND PROVIDERS - fictional examples, not verified businesses. No assistance request has been sent.',
      ),
      DropdownButtonFormField<String>(
        initialValue: _location,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Search demo location',
          prefixIcon: Icon(Icons.search),
        ),
        items: demoPickupLocations
            .map((v) => DropdownMenuItem(value: v, child: Text(v)))
            .toList(),
        onChanged: (v) {
          if (v != null) {
            setState(() => _location = v);
          }
        },
      ),
      TextButton.icon(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'GPS is not used in Demo Mode. Select a demo location above.',
            ),
          ),
        ),
        icon: const Icon(Icons.my_location),
        label: const Text('Use My Location'),
      ),
      DemoPanel(
        child: SizedBox(
          height: 180,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _DemoMapPainter())),
              const Align(
                alignment: Alignment(-.5, -.4),
                child: Icon(Icons.location_on, color: demoPurple, size: 38),
              ),
              const Align(
                alignment: Alignment(.5, .35),
                child: Icon(Icons.build_circle, color: Colors.amber, size: 32),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text('Simulated map - $_location'),
              ),
            ],
          ),
        ),
      ),
      Text(
        '${widget.request.service} examples',
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      for (var i = 1; i <= 3; i++)
        DemoPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Demo Provider $i (fictional)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Text(
                '${widget.request.service}\n$_location - sample distance ${i * 2} mi\nSimulated status: available',
                style: const TextStyle(height: 1.7),
              ),
              TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Demo provider preview'),
                    content: const Text(
                      'This is a fictional provider. No call, booking or dispatch is made.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
                child: const Text('View demo provider'),
              ),
            ],
          ),
        ),
    ],
  );
}

class _DemoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF30314D)
      ..strokeWidth = 8;
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(
        Offset(size.width * i / 5, 0),
        Offset(size.width * i / 5, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height * i / 5),
        Offset(size.width, size.height * i / 5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
