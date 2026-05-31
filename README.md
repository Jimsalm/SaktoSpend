# SaktoSpend

SaktoSpend is an offline-first Flutter shopping budget tracker for Android. It
helps shoppers monitor spending in real time, review every item before it is
added, and stay within a selected budget without relying on an internet
connection.

## Features

- dashboard overview with recent sessions and spending insights
- shopping, weekly, and monthly budgets
- live cart total and remaining budget during shopping sessions
- configurable spending threshold alerts
- optional hard budget mode to block overspending
- manual and voice-assisted cart entry
- product label OCR from camera or gallery photos
- editable OCR review before an item is added
- item source tracking for manual, voice, and label scan entries
- local cart persistence, history views, and budget summaries
- settings for profile, currency, theme, budget controls, and OCR scanning

## Product Flow

1. Create or select a budget.
2. Start a shopping session.
3. Add items manually, by voice, or by scanning a product label.
4. Review the cart total and remaining budget as items are added.
5. Revisit local summaries from the dashboard and history screens.

SaktoSpend currently uses visible product label text rather than barcode lookup.
The scanner extracts a product name and price from a photo, then lets the user
confirm or edit the result before saving it.

## Getting Started

### Requirements

- Flutter SDK compatible with Dart `^3.11.4`
- Android Studio or another Android SDK setup
- Android emulator or physical Android device

### Run Locally

```bash
flutter pub get
flutter run
```

### Quality Checks

```bash
flutter analyze
flutter test
```

## Tech Stack

- Flutter and Dart
- Riverpod for state management and dependency injection
- SQLite via `sqflite` for local persistence
- Google ML Kit text recognition for OCR
- `image_picker` for camera and gallery label photos
- `speech_to_text` for voice-assisted entry

## Local Storage

Core app data is stored locally in SQLite:

- `budgets`
- `session_cart_items`
- `user_profile`
- `app_settings`

Cart items keep their entry source as `manual`, `voice`, or `label_scan`.

## Project Structure

```text
lib/
  app/                  # app shell, routing, and providers
  core/                 # shared theme, services, constants, and utilities
  data/                 # SQLite database, models, and local repositories
  features/
    budgets/            # budget management
    dashboard/          # overview and local insights
    history/            # session history
    insights/           # planned insights expansion
    scanner/            # OCR label scan and review flow
    settings/           # profile and app preferences
    shopping_session/   # live cart and item entry
```

## Notes

- The project is Android-first.
- Core budget tracking works offline.
- The broader product plan lives in `docs/shopping_budget_tracker_plan.md`.
