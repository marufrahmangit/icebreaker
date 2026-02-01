This project ships without gradle-wrapper.jar due to environment limitations.

If Android Studio/Gradle complains about missing gradle-wrapper.jar, fix it by regenerating
the Android platform folder with Flutter on your machine:

  flutter create .

This will recreate android/ with the proper Gradle wrapper jar & scripts.
Then copy back only these files/folders if prompted:
  lib/
  pubspec.yaml
  web/ (optional)

Alternatively, re-run:
  flutter pub get
  flutter run
which often regenerates required local.properties on first run.
