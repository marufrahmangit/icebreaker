# Icebreaker (Flutter)

A mobile-first map-based social simulation that mirrors the provided HTML prototypes:
- Landing screen with gradient + icon + Get Started fade-out (0.45s)
- Google Map centered on Sydney (-33.8688, 151.2093), default UI disabled, greedy gestures
- 60 simulated users as colored circle markers (Open/Shy/Curious/Busy) + "Me" purple marker
- Legend pill overlay at bottom
- Tap user marker -> custom popup card (name, interests, spark points, status badge, bio, distance)
- Buttons:
  - **Say Hi** only if within **800m** -> chat modal (me purple, them orange)
  - **Accept** opens external Google Maps walking directions
- Frost/blur overlay layer above map for depth (pointer-events none)
- Basic offline behavior:
  - Detects offline and shows an unobtrusive banner; app core UI still works.
  - Caches lightweight app state (last selected user, chat draft) via SharedPreferences.
  - NOTE: True Google Maps SDK tile caching is not officially supported by `google_maps_flutter`.
    This project includes the scaffolding for caching snapshots/state and graceful offline fallback.

## Important: Google Maps API Key
This project is pre-configured with your key in Android `AndroidManifest.xml`:
`AIzaSyDWkiFViy7PCYwEedXJXCWPggczfhsj63I`

For iOS/web you may need to add the key as well (see below).

## Open in Android Studio
1. Install Flutter SDK + Android Studio + Android SDK.
2. In Android Studio: **File → Open…** and pick this folder: `icebreaker_androidstudio`
3. Open a terminal in Android Studio and run:
   - `flutter pub get`
   - `flutter run`

## Build an APK (Android 7+ compatible)
From the project root:
- Debug APK:
  - `flutter build apk`
- Split per ABI (smaller):
  - `flutter build apk --split-per-abi`

### Signed release APK
1. Create a keystore:
   - `keytool -genkey -v -keystore icebreaker-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias icebreaker`
2. Put `icebreaker-release.jks` in `android/`
3. Create `android/key.properties`:
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=icebreaker
storeFile=icebreaker-release.jks
```
4. Build:
   - `flutter build apk --release`

## iOS
Open `ios/Runner.xcworkspace` in Xcode.
Add Google Maps key to `ios/Runner/Info.plist` or AppDelegate if you enable iOS builds.

## Web (PWA)
Run:
- `flutter build web`
Serve with any static host. Offline caching is handled by Flutter’s default service worker.

---
This codebase is organized feature-first in `lib/` (models, state, widgets, utils).
