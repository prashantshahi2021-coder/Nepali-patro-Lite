# Nepali Patro Lite Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a clean, offline-first Flutter MVP for Nepali Patro Lite.

**Architecture:** Use local JSON assets for sample Nepali month metadata and holidays, a small service layer for date generation/conversion, reusable UI widgets, and five bottom-navigation screens. Keep dependencies to Flutter SDK defaults only.

**Tech Stack:** Flutter, Dart, Material 3, local JSON assets.

---

### Task 1: Project Shell

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Replace: `lib/main.dart`

- [x] Configure app metadata and JSON assets.
- [x] Build a red-accent Material app with bottom navigation tabs.

### Task 2: Offline Data Layer

**Files:**
- Create: `assets/data/calendar_2083.json`
- Create: `assets/data/holidays_2083.json`
- Create: `lib/models/patro_date.dart`
- Create: `lib/services/patro_repository.dart`

- [x] Store month metadata and holiday samples locally.
- [x] Generate monthly days and basic BS/AD conversion from local data.

### Task 3: UI MVP

**Files:**
- Create: `lib/widgets/app_card.dart`
- Create: `lib/screens/home_screen.dart`
- Create: `lib/screens/calendar_screen.dart`
- Create: `lib/screens/date_detail_screen.dart`
- Create: `lib/screens/converter_screen.dart`
- Create: `lib/screens/holidays_screen.dart`
- Create: `lib/screens/more_screen.dart`

- [x] Build the home, calendar, converter, holidays, more, and date detail UI.
- [x] Keep layouts compact and responsive for small Android phones.

### Task 4: Verification

**Files:**
- Modify: `test/widget_test.dart`

- [ ] Run `flutter format`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
