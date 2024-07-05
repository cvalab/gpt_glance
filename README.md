# chainformation

Use Flutter Stable (stable working with 3.19.1)

## Getting Started
flutter pub get

Create a .env file in the root folder with this text:
OPEN_AI_API_KEY=YOUR_API_KEY

Run:
dart run build_runner build

If you have changed your API key, than run:
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

flutter run

