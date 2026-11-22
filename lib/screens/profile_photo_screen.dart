import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/profile_photo_picker.dart';
import '../widgets/onboarding_photo_input.dart';
import '../widgets/onboarding_widgets.dart';
import 'drivers_license_screen.dart';

class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key, this.photoPicker, this.data});
  final ProfilePhotoPicker? photoPicker;
  final OnboardingData? data;
  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  late final OnboardingData _data = widget.data ?? OnboardingData();
  String? _error;
  bool _navigating = false;
  Future<void> _continue() async {
    if (_navigating) return;
    if (_data.profilePhoto == null) {
      setState(() => _error = 'Please add a profile photo to continue.');
      return;
    }
    setState(() => _navigating = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            DriversLicenseScreen(data: _data, photoPicker: widget.photoPicker),
      ),
    );
    if (mounted) setState(() => _navigating = false);
  }

  @override
  Widget build(BuildContext context) => OnboardingLayout(
    step: 1,
    footer: OnboardingContinueButton(onPressed: _navigating ? null : _continue),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OnboardingTitle(
          title: 'Profile photo',
          subtitle: 'Please upload a clear photo of your face to your rental experience to a safe and secure.',
        ),
        const SizedBox(height: 28),
        OnboardingPhotoInput(
          label: 'Profile',
          bytes: _data.profilePhoto,
          picker: widget.photoPicker,
          profile: true,
          onChanged: (bytes) => setState(() {
            _data.profilePhoto = bytes;
            _error = null;
          }),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFFFB4AB)),
            ),
          ),
      ],
    ),
  );
}
