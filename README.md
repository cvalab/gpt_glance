# chainformation

Use Flutter Stable (stable working with 3.19.1)

## Environment build script
Run from project folder
sh ../build.sh prod
sh ../build.sh rollout
sh ../build.sh stage

## Getting Started
flutter pub get
flutter pub run intl_utils:generate
flutter packages pub run build_runner build --delete-conflicting-outputs


keytool -list -v \
-alias key0 -keystore releasekey.keystore

App Links server configuration:
Android:
https://hostname/.well-known/assetlinks.json

iOS:
https://hostname/.well-known/apple-app-site-association
