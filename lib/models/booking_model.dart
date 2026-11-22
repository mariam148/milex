import 'car_model.dart';

/// Local quote only; times are local device times, prices are sample cents.
class BookingDraft {
  BookingDraft({
    required this.car,
    required this.pickup,
    required this.returnAt,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.paymentMethod = 'Visa demo',
  });
  final CarModel car;
  DateTime pickup, returnAt;
  String pickupLocation, dropoffLocation, paymentMethod;
  bool get valid => returnAt.isAfter(pickup);
  int get days => valid
      ? (returnAt.difference(pickup).inMicroseconds /
                Duration.microsecondsPerDay)
            .ceil()
      : 0;
  int get dailyCents => (car.dailyRentalPrice * 100).round();
  int get subtotalCents => dailyCents * days;
  // Transparent sample assumptions: 5% service fee, 8% tax on rental subtotal.
  int get serviceFeeCents => (subtotalCents * .05).round();
  int get taxCents => (subtotalCents * .08).round();
  int get totalCents => subtotalCents + serviceFeeCents + taxCents;
  BookingDraft snapshot() => BookingDraft(
    car: car,
    pickup: pickup,
    returnAt: returnAt,
    pickupLocation: pickupLocation,
    dropoffLocation: dropoffLocation,
    paymentMethod: paymentMethod,
  );
}

enum DemoBookingStatus { active, upcoming, past }

class BookingModel {
  BookingModel({
    required this.reference,
    required BookingDraft draft,
    required this.createdAt,
  }) : _draft = draft.snapshot();
  final String reference;
  final DateTime createdAt;
  final BookingDraft _draft;
  BookingDraft get details => _draft.snapshot();
  DemoBookingStatus statusAt(DateTime now) => !now.isBefore(_draft.returnAt)
      ? DemoBookingStatus.past
      : now.isBefore(_draft.pickup)
      ? DemoBookingStatus.upcoming
      : DemoBookingStatus.active;
}

String demoMoney(int cents, String currency) =>
    '$currency ${(cents / 100).toStringAsFixed(2)}';
String demoDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
