import 'package:flutter/foundation.dart';

import '../models/booking_model.dart';

class BookingRepository extends ChangeNotifier {
  final List<BookingModel> _bookings = [];
  final Map<Object, BookingModel> _confirmed = {};
  static int _sequence = 0;
  List<BookingModel> get bookings => List.unmodifiable(_bookings.reversed);

  /// Idempotent for a single payment preview, including repeated button taps.
  BookingModel confirm(BookingDraft draft, Object confirmationKey) {
    final existing = _confirmed[confirmationKey];
    if (existing != null) return existing;
    if (!draft.valid ||
        draft.pickupLocation.trim().isEmpty ||
        draft.dropoffLocation.trim().isEmpty) {
      throw ArgumentError(
        'Valid rental dates and demo locations are required.',
      );
    }
    final now = DateTime.now();
    final booking = BookingModel(
      reference: 'DEMO-${now.microsecondsSinceEpoch}-${++_sequence}',
      draft: draft,
      createdAt: now,
    );
    _confirmed[confirmationKey] = booking;
    _bookings.add(booking);
    notifyListeners();
    return booking;
  }

  List<BookingModel> forStatus(DemoBookingStatus status, DateTime now) =>
      bookings.where((booking) => booking.statusAt(now) == status).toList();
  void clear() {
    _bookings.clear();
    _confirmed.clear();
    notifyListeners();
  }
}
