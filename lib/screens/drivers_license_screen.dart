import 'package:flutter/material.dart';

import '../models/onboarding_data.dart';
import '../services/profile_photo_picker.dart';
import '../widgets/onboarding_photo_input.dart';
import '../widgets/onboarding_widgets.dart';
import 'current_address_screen.dart';

class DriversLicenseScreen extends StatefulWidget {
  const DriversLicenseScreen({super.key, required this.data, this.photoPicker});
  final OnboardingData data;
  final ProfilePhotoPicker? photoPicker;
  @override
  State<DriversLicenseScreen> createState() => _DriversLicenseScreenState();
}

class _DriversLicenseScreenState extends State<DriversLicenseScreen> {
  final _form = GlobalKey<FormState>();
  late final _date = TextEditingController(
    text: _format(widget.data.expirationDate),
  );
  String? _photoError;
  bool _navigating = false;
  String _format(DateTime? date) => date == null
      ? ''
      : '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';
  DateTime get _today => DateUtils.dateOnly(DateTime.now());
  Future<void> _pickDate() async {
    final today = _today;
    // Use a calendar day so daylight-saving transitions cannot select today.
    final first = DateTime(today.year, today.month, today.day + 1);
    final saved = widget.data.expirationDate;
    final date = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: DateTime(_today.year + 100),
      initialDate: saved != null && saved.isAfter(_today) ? saved : first,
    );
    if (!mounted || date == null) return;
    setState(() {
      widget.data.expirationDate = date;
      _date.text = _format(date);
    });
  }

  Future<void> _continue() async {
    if (_navigating) return;
    final valid = _form.currentState!.validate();
    setState(
      () => _photoError =
          widget.data.licenseFront == null || widget.data.licenseBack == null
          ? 'Please add both front and back license photos.'
          : null,
    );
    if (!valid || _photoError != null) return;
    setState(() => _navigating = true);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CurrentAddressScreen(data: widget.data),
      ),
    );
    if (mounted) setState(() => _navigating = false);
  }

  @override
  void dispose() {
    _date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingLayout(
    step: 2,
    footer: OnboardingContinueButton(onPressed: _navigating ? null : _continue),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingTitle(
            title: "Driver's License",
            subtitle: 'Please enter your driver license details.',
          ),
          OnboardingField(
            label: 'License Number',
            child: TextFormField(
              initialValue: widget.data.licenseNumber,
              decoration: const InputDecoration(
                hintText: 'Enter license number',
              ),
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              onChanged: (value) => widget.data.licenseNumber = value,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Please enter your license number'
                  : null,
            ),
          ),
          OnboardingField(
            label: 'Issuing Country',
            child: OnboardingCountryField(
              value: widget.data.issuingCountry,
              onChanged: (value) =>
                  setState(() => widget.data.issuingCountry = value),
            ),
          ),
          OnboardingField(
            label: 'Expiration Date',
            child: TextFormField(
              controller: _date,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                hintText: 'DD / MM / YYYY',
                suffixIcon: Icon(Icons.calendar_today_outlined),
              ),
              validator: (_) =>
                  widget.data.expirationDate == null ||
                      !widget.data.expirationDate!.isAfter(_today)
                  ? 'Choose a future expiration date'
                  : null,
            ),
          ),
          const Text(
            'License Photos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: OnboardingPhotoInput(
                  label: 'Front Side',
                  bytes: widget.data.licenseFront,
                  picker: widget.photoPicker,
                  onChanged: (bytes) =>
                      setState(() => widget.data.licenseFront = bytes),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OnboardingPhotoInput(
                  label: 'Back Side',
                  bytes: widget.data.licenseBack,
                  picker: widget.photoPicker,
                  onChanged: (bytes) =>
                      setState(() => widget.data.licenseBack = bytes),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Use clear photos. Hide unrelated personal details.',
            style: TextStyle(color: milexMuted, fontSize: 12),
          ),
          if (_photoError != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _photoError!,
                style: const TextStyle(color: Color(0xFFFFB4AB)),
              ),
            ),
        ],
      ),
    ),
  );
}
