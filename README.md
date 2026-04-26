# SaktoSpend

SaktoSpend is an offline-first Flutter shopping budget tracker for Android.

The app helps you stay inside a shopping budget while adding items in real time. It currently focuses on fast local entry through manual add, voice-assisted entry, and product label OCR that extracts the product name and price from a photo.

## Current Features

- budget-based shopping sessions
- live remaining budget and running total
- hard budget protection before overspending
- manual item entry
- voice entry review flow
- product label scan with OCR review
- local session cart persistence
- history and budget views
- local settings for OCR and budget behavior

## Product Direction

SaktoSpend is currently built around label scanning rather than barcode lookup.

- the scanner reads visible label text
- the app extracts product name and price
- users confirm or edit the result before saving
- all core budget tracking works offline

## Tech Stack

- Flutter
- Riverpod
- SQLite via `sqflite`
- Google ML Kit text recognition
- `image_picker` for label photos

## Project Structure

```text
lib/
  app/
  core/
  data/
  features/
    budgets/
    dashboard/
    history/
    insights/
    scanner/
    settings/
    shopping_session/
```

## Notes

- the project is Android-first
- the main product plan lives in `docs/shopping_budget_tracker_plan.md`
