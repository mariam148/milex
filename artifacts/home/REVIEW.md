# Home visual review

- Preview: `pixel-7-pro-widget.png`, rendered at 1440 × 3120 pixels / 3.5 device-pixel ratio (Pixel 7 Pro logical size), with Roboto and decoded bundled images.
- This is a Flutter widget render, not an Android emulator screenshot. It has been inspected for compact density, car crop, wordmark crop, spacing and navigation placement.
- The original current/target screenshots were not present in the attachment. No comparison against the Figma target was possible, and pixel-perfect matching is not claimed.
- A running AVD was confirmed as `Pixel_7_Pro`. Android build was attempted using `tool/preview_home.dart`, but Gradle failed downloading Kotlin Gradle plugin 2.3.0 because its JVM could not validate repository TLS certificates (`PKIX path building failed`). No certificate verification was disabled and no global SDK/build configuration was changed.
- Remaining asset mismatches: original dark-blue illuminated-road hero, original blue Aston Martin image, original gray Nissan image, original category artwork, standalone Figma wordmark. Current images are disclosed illustrative substitutes. The wordmark is cropped from the project's original logo. See `assets/images/DEMO_ARTWORK.md` for image provenance and edit prompt.
- The header disclosure was moved to the Profile preview. Authentication and onboarding navigation remain unchanged.
- Normal-size Pixel 7 Pro layout is tested to show six categories, the full first card and the second card title without scrolling. Larger text and smaller screens retain scrolling.

To rerun the widget capture: `flutter test tool/capture_home_preview_test.dart`.
To launch the debug-only emulator preview once Gradle downloads work: `flutter run -d emulator-5554 --target tool/preview_home.dart`.
Regular app startup remains `lib/main.dart`.
