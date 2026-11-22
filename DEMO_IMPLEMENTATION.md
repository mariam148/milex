# Complete MileX local demo

All new data stays in memory. There is no backend, real authentication, Firebase, payment gateway, GPS, live diagnostics, verified provider directory or assistance dispatch. Logout clears the shared local profile (including photo/document references), bookings, favorites, assistance draft and notification preference. The existing Remember Me checkbox remains a nonsensitive UI preference only.

## New files

- `lib/models/booking_model.dart`: booking draft, price calculations, immutable confirmed snapshots and time-based status.
- `lib/models/demo_diagnostic_model.dart`: selected-vehicle simulated diagnostic examples.
- `lib/models/demo_assistance_request.dart`: local assistance form draft.
- `lib/repositories/booking_repository.dart`: initially empty in-memory booking list, unique DEMO references and idempotent confirmation.
- `lib/services/demo_session.dart`: shared local state associated with the existing CarRepository.
- `lib/widgets/demo_widgets.dart`: reusable scrolling pages, panels, disclosures, vehicle summaries and price breakdowns.
- `lib/screens/booking_summary_screen.dart`
- `lib/screens/secure_payment_screen.dart`
- `lib/screens/booking_confirmed_screen.dart`
- `lib/screens/my_bookings_screen.dart`
- `lib/screens/booking_details_screen.dart`
- `lib/screens/car_health_screen.dart`
- `lib/screens/diagnostic_details_screen.dart`
- `lib/screens/roadside_help_screen.dart`
- `lib/screens/nearby_mechanics_screen.dart`
- `lib/screens/favorites_screen.dart`
- `lib/screens/my_profile_screen.dart`
- `lib/screens/profile_settings_screen.dart`
- `lib/screens/support_screen.dart`
- `test/complete_demo_test.dart`
- `DEMO_IMPLEMENTATION.md` (this file)

## Modified existing files

- `lib/auth/auth_navigation.dart`: keep the shared local session on demo Home navigation and clear it on logout.
- `lib/screens/home_screen.dart`: connect the five existing tabs and register the return-to-bookings action.
- `lib/screens/car_details_screen.dart`: send the selected car and duration into the complete booking flow; retain the old preview entry as a delegating compatibility widget.
- `lib/widgets/home_widgets.dart`: align the shared primary accent with requested #6036FF.
- `test/filters_test.dart`: follow the expanded booking summary and its scrolling layout.
- `AUTH_SETUP.md`: link the expanded demo behavior documentation.

## Navigation

- Car Details -> Booking Summary -> Secure Payment -> Booking Confirmed -> Bookings tab -> Booking Details -> Car Health -> Diagnostic Details -> Roadside Help -> Nearby Mechanics.
- Existing Home, All Cars, category, search and filters routes continue to share the same CarRepository. Favorites also uses this repository and updates everywhere.
- Profile -> Edit Profile/Personal Information, license draft review/edit, My Bookings, dummy Payment Methods, Saved Locations, Notifications, Help & Support, Settings and Logout.
- Existing Sign Up, Login, recovery previews, onboarding, Splash and Welcome screens remain in the project.

## Local behavior and assumptions

- Pickup/return date and time use local device time and native Flutter date/time pickers. Return must be strictly after pickup. Every started 24-hour period is charged as one demo rental day.
- Price arithmetic is in cents. Demo service fee = 5% of rental subtotal; demo taxes = 8% of rental subtotal. Each is rounded to the nearest cent. There is no deposit, real quote or availability check.
- Payment fields are disabled dummy labels. There is no real card number or CVV input, storage or logging. The user explicitly acknowledges the demo before confirmation.
- Only in-app confirmation creates booking records. Active, upcoming and past are derived from the chosen dates and current local time; no seeded user bookings are displayed. Confirmation returns to the relevant status section and newest booking.
- Diagnostics are visibly simulated and derived from the selected vehicle. Electric examples mark engine oil as not applicable.
- Assistance requests only preserve a local draft and open fictional provider examples. The map is a code-drawn simulated grid. Use My Location explains that GPS is not used.
- Profile updates mutate the existing onboarding draft and notify the shared session. Nothing is uploaded or verified. Payment Methods contains dummy labels only.

## Visual and verification limits

No Figma image or file link was supplied with this request; the attachment contains text only. Screens reuse existing MileX tokens, compact rounded surfaces and original car artwork. Exact screenshot fidelity cannot be verified. The 28 vehicles without original images continue to show honest unavailable-image placeholders.

Automated tests cover complete navigation, shared profile/favorite state, fee calculations, invalid date ordering, status boundaries, duplicate confirmation protection, logout clearing and large-text layouts at 320x568 and 412x892. Network-client creation is rejected in the end-to-end booking/assistance test. Physical-device and emulator interaction, native photo permissions, and exact visual comparison require a device/emulator and supplied visual references.

## Completed verification

- `flutter pub get`: passed, no packages added.
- `dart format .`: completed.
- `flutter analyze`: no issues.
- `flutter test`: all 44 tests passed.
- Android debug APK built and installed successfully on `emulator-5554` (Android 13 / API 33, 1440x3120).
- Main entry launched and Sign Up/Login rendered. New-screen device smoke testing used the project's existing debug-only `tool/preview_home.dart`; `lib/main.dart` startup is unchanged.
- Manually exercised selected-car Details -> Booking Summary -> explicit dummy-payment acknowledgement -> Booking Confirmed -> the Upcoming section of the Bookings tab. The new unique demo reference, dates, selected car and computed total appeared correctly.
- Screenshots: `artifacts/complete_demo/01_launch.png`, `02_login.png`, `03_home.png`, `04_details.png`, `05_summary.png`, `06_payment.png`, `07_confirmed.png`, `08_bookings.png`.
- The emulator is left in the debug Home-preview build on the Bookings tab with the one local smoke-test record. This is in-memory demo data, not a real reservation. Run the normal main entry to return to standard app startup.
- Full health/diagnostics/assistance/provider navigation, profile updates, logout clearing and responsive layouts were verified through widget tests. Physical-device permissions and exact Figma comparison were not tested.
