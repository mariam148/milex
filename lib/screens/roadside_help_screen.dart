import 'package:flutter/material.dart';

import '../models/car_model.dart';
import '../models/car_filters.dart';
import '../models/demo_assistance_request.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';
import 'nearby_mechanics_screen.dart';

class RoadsideHelpScreen extends StatefulWidget {
  const RoadsideHelpScreen({super.key, required this.session, this.car});
  final DemoSession session;
  final CarModel? car;
  @override
  State<RoadsideHelpScreen> createState() => _RoadsideHelpScreenState();
}

class _RoadsideHelpScreenState extends State<RoadsideHelpScreen> {
  final _form = GlobalKey<FormState>();
  late final _problem = TextEditingController(
    text: widget.session.assistance?.problem ?? '',
  );
  late String _location =
      widget.session.assistance?.location ??
      widget.car?.location ??
      demoPickupLocations.first;
  late String _service =
      widget.session.assistance?.service ?? 'Mobile Mechanic';
  @override
  void dispose() {
    _problem.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: 'Roadside Help',
    footer: DemoAction(
      'Request Assistance (Demo)',
      onPressed: () {
        if (!_form.currentState!.validate()) return;
        FocusScope.of(context).unfocus();
        final request = DemoAssistanceRequest(
          carId: widget.car?.id,
          service: _service,
          problem: _problem.text.trim(),
          location: _location,
        );
        widget.session.assistance = request;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NearbyMechanicsScreen(request: request),
          ),
        );
      },
    ),
    children: [
      const DemoNotice(
        'LOCAL DEMO - no real assistance, emergency request or dispatch. Choose a simulated service and location.',
      ),
      if (widget.car != null)
        Text(
          widget.car!.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final service in [
            'Mobile Mechanic',
            'Tow Truck / Vehicle Recovery',
          ])
            ChoiceChip(
              label: Text(service),
              selected: _service == service,
              selectedColor: demoPurple,
              onSelected: (_) => setState(() => _service = service),
            ),
        ],
      ),
      Form(
        key: _form,
        child: TextFormField(
          controller: _problem,
          maxLines: 3,
          maxLength: 300,
          decoration: const InputDecoration(
            labelText: 'Problem description (demo)',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Describe the demo problem'
              : null,
        ),
      ),
      DropdownButtonFormField<String>(
        initialValue: _location,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Your Location (manually selected demo zone)',
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
    ],
  );
}
