# Bettboxt — Android Native

This branch contains a migrated native Android app (Kotlin).

Structure:
- settings.gradle
- build.gradle (root)
- app/ (Android app module)

How to build locally:
1. Install JDK 17+ and Android SDK (with compile SDK 34).
2. From repo root run:
   ./gradlew assembleDebug

CI:
- A GitHub Actions workflow is provided to run a build on push/PR.

Notes:
- Flutter sources were intentionally removed/archived during migration. If you need them restored, check the original branch or contact the maintainer.
