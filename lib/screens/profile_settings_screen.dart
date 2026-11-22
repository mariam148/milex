import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/demo_session.dart';
import '../widgets/demo_widgets.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    super.key,
    required this.session,
    this.editProfile = false,
  });
  final DemoSession session;
  final bool editProfile;
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.session.profile.fullName,
  );
  late final _phone = TextEditingController(
    text: widget.session.profile.phoneNumber,
  );
  late final _city = TextEditingController(text: widget.session.profile.city);
  late String? _country = widget.session.profile.country;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoPage(
    title: widget.editProfile ? 'Edit Profile' : 'Profile Settings',
    footer: widget.editProfile
        ? DemoAction(
            'Save local profile',
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              final OnboardingData data = widget.session.profile;
              data.fullName = _name.text.trim();
              data.phoneNumber = _phone.text.trim();
              data.country = _country;
              data.city = _city.text.trim();
              widget.session.profileChanged();
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
          )
        : null,
    children: [
      const DemoNotice(
        'Local demo information only. No information is uploaded or identity verified.',
      ),
      if (widget.editProfile)
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number (including country code)',
                ),
                validator: (v) =>
                    v == null || !RegExp(r'^\+?[0-9]{8,15}$').hasMatch(v.trim())
                    ? 'Enter a valid mobile number'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _country,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Country'),
                items: {'Egypt', 'Saudi Arabia', 'UAE', ?_country}
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                validator: (v) => v == null ? 'Please select a country' : null,
                onChanged: (v) => setState(() => _country = v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City (optional)'),
              ),
            ],
          ),
        )
      else ...[
        DemoPanel(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: widget.session.notifications,
            title: const Text('Demo notifications'),
            subtitle: const Text('Local preference only; no push service.'),
            onChanged: (v) => setState(() {
              widget.session.notifications = v;
              widget.session.profileChanged();
            }),
          ),
        ),
        const DemoPanel(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.dark_mode_outlined),
            title: Text('MileX dark appearance'),
            subtitle: Text('The existing navy and purple theme is retained.'),
          ),
        ),
        DemoAction(
          'Edit Profile',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileSettingsScreen(
                session: widget.session,
                editProfile: true,
              ),
            ),
          ),
        ),
      ],
    ],
  );
}
