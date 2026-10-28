# JWallet Flutter starter

A runnable Flutter starter with four features: Login & Authentication, Wallet Dashboard, Send Money, and Transaction History. It uses a feature-first Clean Architecture layout, shared UI components, centralized colors/theme, and automatic system light/dark mode.

## Run
1. Install Flutter and confirm `flutter doctor` succeeds.
2. Extract this ZIP and open the `jwallet_clean_architecture` folder in VS Code or Android Studio.
3. Run `flutter pub get`.
4. Run `flutter run`.

## Demo login
Enter any non-empty email/mobile and password. This is a demo-only flow; it does not authenticate with a server.

## Project conventions
- `lib/app`: app root, routing shell and themes.
- `lib/core`: shared widgets, network helpers, validators and constants.
- `lib/features/<feature>/data`: static data sources and repository implementations.
- `lib/features/<feature>/domain`: entities, repository contracts and use cases.
- `lib/features/<feature>/presentation`: screens and BLoC state management.
- `lib/di`: dependency registration.

## Connect your API later
Replace each feature's `*_demo_data_source.dart` with a remote data source using `ApiClient` (Dio), then bind it in the repository implementation. Keep screen code calling BLoC/use cases; don't call APIs directly from widgets. Add your real endpoint paths and request/response models in the feature's data layer. No real API credentials are included.

## Theme
The app starts with `ThemeMode.system`, so it follows the device theme automatically. Change `themeMode` in `lib/app/app.dart` to `ThemeMode.light` or `ThemeMode.dark` if desired.
