import 'package:flutter/foundation.dart';

import '../models/onboarding_data.dart';
import '../models/demo_assistance_request.dart';
import '../models/booking_model.dart';
import '../repositories/car_repository.dart';
import '../repositories/booking_repository.dart';

/// One memory-only session per shared car repository; contains no credentials.
class DemoSession extends ChangeNotifier {
  DemoSession._(this.cars) {
    bookings.addListener(notifyListeners);
  }
  static final _sessions = Expando<DemoSession>();
  static DemoSession forCars(CarRepository cars) =>
      _sessions[cars] ??= DemoSession._(cars);
  final CarRepository cars;
  final bookings = BookingRepository();
  OnboardingData profile = OnboardingData();
  DemoAssistanceRequest? assistance;
  bool notifications = false, darkAppearance = true;
  VoidCallback? showBookings;
  DemoBookingStatus bookingTab = DemoBookingStatus.upcoming;
  void profileChanged() => notifyListeners();
  void clear() {
    profile = OnboardingData();
    assistance = null;
    notifications = false;
    darkAppearance = true;
    bookingTab = DemoBookingStatus.upcoming;
    bookings.clear();
    for (final car in cars.favorites) {
      cars.toggleFavorite(car.id);
    }
    notifyListeners();
  }
}
