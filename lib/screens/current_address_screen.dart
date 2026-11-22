import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../widgets/onboarding_widgets.dart';
import '../auth/auth_navigation.dart';

class CurrentAddressScreen extends StatefulWidget {
  const CurrentAddressScreen({super.key, required this.data});
  final OnboardingData data;
  @override
  State<CurrentAddressScreen> createState() => _CurrentAddressScreenState();
}

class _CurrentAddressScreenState extends State<CurrentAddressScreen> {
  final _form = GlobalKey<FormState>();
  bool _navigating = false;
  Widget _field(
    String label,
    String hint,
    String value,
    ValueChanged<String> change, {
    bool postal = false,
  }) => OnboardingField(
    label: label,
    child: TextFormField(
      initialValue: value,
      onChanged: change,
      decoration: InputDecoration(hintText: hint),
      textInputAction: TextInputAction.next,
      textCapitalization: postal
          ? TextCapitalization.characters
          : TextCapitalization.words,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter ${label.toLowerCase()}';
        }
        if (postal) {
          final pattern = switch (widget.data.country) {
            'Egypt' ||
            'Saudi Arabia' ||
            'Jordan' ||
            'Germany' ||
            'France' => r'^\d{5}$',
            'United States' => r'^\d{5}(-\d{4})?$',
            'India' => r'^[1-9]\d{5}$',
            'Canada' => r'^[A-Z]\d[A-Z] ?\d[A-Z]\d$',
            'United Kingdom' => r'^[A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2}$',
            'UAE' => r'^(N/A|[0-9]{2,12})$',
            _ => r'^[A-Z0-9 -]{2,12}$',
          };
          if (!RegExp(pattern).hasMatch(value.trim().toUpperCase())) {
            return 'Enter a valid postal code';
          }
        }
        return null;
      },
    ),
  );
  Future<void> _continue() async {
    if (_navigating || !_form.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _navigating = true);
    await DemoNavigation.openHome(context, data: widget.data);
    if (mounted) setState(() => _navigating = false);
  }

  @override
  Widget build(BuildContext context) => OnboardingLayout(
    step: 3,
    footer: OnboardingContinueButton(onPressed: _navigating ? null : _continue),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingTitle(
            title: 'Current Address',
            subtitle: 'Enter the address where you currently live.',
          ),
          OnboardingField(
            label: 'Country',
            child: OnboardingCountryField(
              value: widget.data.country,
              onChanged: (value) => setState(() => widget.data.country = value),
            ),
          ),
          _field(
            'City',
            'Cairo',
            widget.data.city,
            (value) => widget.data.city = value,
          ),
          _field(
            'Area / District',
            'Maadi',
            widget.data.district,
            (value) => widget.data.district = value,
          ),
          _field(
            'Street',
            'Sarayat El Maadi',
            widget.data.street,
            (value) => widget.data.street = value,
          ),
          _field(
            'Building / No.',
            '23',
            widget.data.building,
            (value) => widget.data.building = value,
          ),
          _field(
            'Floor / Apartment',
            '4B',
            widget.data.apartment,
            (value) => widget.data.apartment = value,
          ),
          _field(
            'Postal Code',
            '11742',
            widget.data.postalCode,
            (value) => widget.data.postalCode = value,
            postal: true,
          ),
          if (widget.data.country == 'UAE')
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text(
                'The UAE does not use postal codes. Enter N/A if you do not have a P.O. Box.',
                style: TextStyle(color: milexMuted, fontSize: 12),
              ),
            ),
        ],
      ),
    ),
  );
}
