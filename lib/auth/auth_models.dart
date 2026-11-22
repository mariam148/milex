/// Retained domain types. Local Demo Mode does not use authentication sessions.
enum AuthNextStep {
  phoneVerification,
  profileDetails,
  profilePhoto,
  driversLicense,
  address,
  complete,
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.nextStep,
    this.phoneNumber = '',
    this.country,
  });
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? country;
  final AuthNextStep nextStep;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });
  final AuthUser user;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  bool get expired => !expiresAt.isAfter(DateTime.now().toUtc());
}

class RegistrationInput {
  const RegistrationInput({
    required this.fullName,
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
    required this.country,
  });
  final String fullName, countryCode, phoneNumber, password, country;
}

class LoginInput {
  const LoginInput({
    required this.countryCode,
    required this.phoneNumber,
    required this.password,
  });
  final String countryCode, phoneNumber, password;
}

enum AuthFailureCode {
  notConfigured,
  invalidCredentials,
  duplicatePhone,
  network,
  canceled,
  expired,
  verificationRequired,
  server,
  storage,
  busy,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code);
  final AuthFailureCode code;
  String get message => switch (code) {
    AuthFailureCode.notConfigured => 'Authentication is not connected yet. Backend and OAuth configuration are required.',
    AuthFailureCode.invalidCredentials =>
      'The phone number or password is incorrect.',
    AuthFailureCode.duplicatePhone =>
      'An account with this phone number already exists. Please log in.',
    AuthFailureCode.network =>
      'Could not connect. Check your connection and try again.',
    AuthFailureCode.canceled => 'Google sign-in was canceled. If this repeats after account selection, check OAuth configuration.',
    AuthFailureCode.expired => 'Your session has expired. Please log in again.',
    AuthFailureCode.verificationRequired =>
      'Complete the required account verification before continuing.',
    AuthFailureCode.storage =>
      'Could not securely save your session. Please try again.',
    AuthFailureCode.busy => 'An authentication request is already in progress.',
    AuthFailureCode.server =>
      'Authentication could not be completed. Please try again.',
  };
}
