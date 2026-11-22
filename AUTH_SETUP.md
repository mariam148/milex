# Local Demo Mode

Backend authentication has been canceled. All development flows run locally.

- Sign Up validates name, mobile number, password and country, then opens Profile Photo ? Driver's License ? Current Address ? Home.
- Demo Login validates form input for UI testing and opens Home. It does not match credentials, create an account or establish an authenticated session. Use any locally valid form values; no password is saved.
- The current onboarding draft is kept only in memory and reused when opening demo Home. No images or identity details are uploaded.
- Remember Me saves only the existing checkbox boolean in SharedPreferences. It does not remember credentials or restore a real session.
- Google retains its existing button styling and displays “Google Sign-In is not available in Demo Mode.” No SDK or API is invoked. Apple buttons are absent.
- Forgot Password and Create New Password remain labeled development previews. Demo actions validate local input and navigate without sending OTPs or changing credentials. Real Continue and Resend remain disabled.
- Splash/Welcome, onboarding, six categories, 30 demo cars, search, See All, favorites, details and bottom navigation remain available.

The unused backend API/repository/session services and Google/secure-token SDK dependencies were removed. Existing models, including the unused auth domain model, were retained. `lib/auth/auth_navigation.dart` now contains local demo navigation only. There are no active authentication endpoints, token handling or network clients.

This is a demo build in every build mode. Before any production release, real authentication and server-side verification would need a separate implementation.

The expanded booking, diagnostics, assistance, profile and tab flows are documented in DEMO_IMPLEMENTATION.md.
