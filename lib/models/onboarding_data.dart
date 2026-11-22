import 'dart:typed_data';

/// Session-only draft. Never persist identity documents or passwords in preferences.
class OnboardingData {
  OnboardingData({
    this.userId,
    this.fullName = '',
    this.phoneNumber = '',
    this.country,
  });
  final String? userId;
  String fullName;
  String phoneNumber;
  String? country;
  Uint8List? profilePhoto;
  String licenseNumber = '';
  String? issuingCountry;
  DateTime? expirationDate;
  Uint8List? licenseFront;
  Uint8List? licenseBack;
  String city = '';
  String district = '';
  String street = '';
  String building = '';
  String apartment = '';
  String postalCode = '';
}
