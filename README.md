# Icebreaker (Flutter)

Icebreaker is a mobile-first, map-based social connection app designed to encourage **real-world interactions** between people who are physically nearby. It prioritizes presence, availability signals, and proximity over endless online messaging.

---

## What Icebreaker Is

Icebreaker is **not** a dating app and **not** traditional social media.

It helps people already sharing the same physical space (cafes, campuses, events, beaches) connect naturally by:
- Showing nearby users on a live map
- Letting users signal availability (Open, Shy, Curious, Busy)
- Allowing chat only within a close physical distance

---

## Core Features

- Clean landing screen with smooth transition to map
- Google Map as the primary home screen (minimal UI)
- Nearby users displayed as circular markers
- Status-based social signals:
  - Open
  - Shy
  - Curious
  - Busy
- Tap a user to view a lightweight profile card:
  - Name
  - Interests (hashtags)
  - Spark Points
  - Status
  - Short bio
  - Distance
- Distance-gated interaction:
  - **Say Hi** enabled only within ~800m
- **Accept** action opens external walking directions in Google Maps
- Minimal chat UI designed as a bridge to real interaction
- Offline-aware behavior with graceful fallback

---

## Technology Stack

- **Flutter** (cross-platform UI)
- **Android (currently supported)**
- Google Maps SDK
- SharedPreferences (lightweight local state)
- Kotlin Gradle (KTS)

The project is structured feature-first under `lib/` (models, state, widgets, utils).

---

## Google Maps API Key (Required)

This project requires a Google Maps API key.

For security reasons:
- **API keys are NOT included in this repository**
- You must provide your own key locally

### Android setup
1. Copy the example file: android/secrets.properties.example
2. Rename it to: android/secrets.properties
3. Add your key: GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
The key is injected at build time via Gradle and **never committed to source control**.

---

## Running the App (Android)

### Prerequisites
- Flutter SDK
- Android Studio
- Android SDK

### Run
From the project root:
```bash
flutter pub get
flutter run
```
### Build APK
Debug build:
```bash
flutter build apk
```
Release build:
```bash
flutter build apk --release
```

### iOS & Web (Future)

- iOS builds require macOS and Xcode
- Google Maps key must be added via Info.plist / AppDelegate
- Web builds can be generated using:
```bash
flutter build web
```

### Security Notes
- API keys are kept out of version control
- Build artifacts and local configs are ignored via .gitignore
- This repository is safe to clone publicly

### Status
- 🚧 Active development
- Android-first, iOS support planned.
