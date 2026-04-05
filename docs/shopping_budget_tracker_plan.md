# Shopping Budget Tracker for Android (Flutter)

## Overview

This document defines the product plan, feature scope, architecture, and implementation guidance for an **offline-first Android shopping budget tracker built with Flutter**.

The app helps users manage shopping expenses in real time so they do not exceed a set budget while shopping. It supports offline product entry, barcode scanning, OCR-based extraction where possible, and optional offline AI for structured parsing and smart suggestions.

This file is intended to provide project context for developers and AI coding tools.

---

## Product Vision

Build a private, offline-first shopping assistant that helps users stay within budget while shopping.

The app should:
- work without internet
- allow fast product input
- warn users before they exceed budget
- learn commonly purchased items locally
- optionally use on-device AI for extraction and suggestions

---

## Primary Goal

Help users avoid overspending during shopping sessions.

## Secondary Goals

- reduce manual input effort
- speed up product entry using scanning
- provide useful budget insights
- maintain privacy through local-only data storage
- support repeat shopping behavior through local product memory

---

## Core User Flow

1. User creates a budget.
2. User starts a shopping session.
3. User adds items manually, via barcode scan, or via OCR.
4. App updates the running total instantly.
5. App shows remaining budget and alerts when close to the limit.
6. App stores products and prices locally for future reuse.
7. App provides a summary and insights after the session.

---

## Product Scope

### In Scope
- offline budget tracking
- shopping sessions
- manual item entry
- barcode scanning
- local product catalog
- live remaining budget calculation
- warnings before overspending
- category-based summaries
- receipt or label OCR
- optional offline AI helpers

### Out of Scope for MVP
- cloud sync
- online product database dependency
- account system
- multi-device collaboration
- online price comparison services

---

## Key Product Principles

### 1. Offline First
The app must function fully without internet for all core tasks.

### 2. Budget Visibility
Remaining budget must always be visible during shopping.

### 3. Fast Input
The app should minimize typing through scanning, recent items, and saved products.

### 4. Local Learning
The app should improve over time by remembering products, prices, and stores locally.

### 5. AI as Assistant, Not Authority
Core calculations must use deterministic logic. AI should only assist with parsing, categorization, and suggestions.

---

## Feature Plan

## 1. Budget Management

Users can create and manage:
- trip budgets
- weekly budgets
- monthly budgets
- category budgets

Each budget should support:
- budget name
- budget type
- total amount
- reserve amount
- warning threshold percentage
- active date range
- current status

### Budget Status Rules
- Safe: spent is below warning threshold
- Warning: spent is near budget limit
- Exceeded: spent is equal to or above budget

---

## 2. Shopping Sessions

A shopping session represents one active shopping trip.

Each session should contain:
- linked budget
- store name
- session start time
- session end time
- list of cart items
- running total
- projected remaining budget
- session status

### Session Capabilities
- add item
- edit item
- remove item
- undo last add
- mark item as essential or non-essential
- end session and generate summary

---

## 3. Product Entry Methods

### A. Manual Entry
User manually enters:
- product name
- category
- price
- quantity
- unit
- notes

### B. Barcode Scanning
Use the camera to scan packaged products.

Expected behavior:
- if barcode exists in local catalog, auto-fill product details
- if barcode does not exist, prompt the user to enter product details
- once confirmed, save barcode and product locally for future use

### C. OCR Scanning
Use camera OCR to read:
- shelf labels
- receipt text
- product names
- prices
- quantities

Expected behavior:
- extract candidate text
- parse product and price fields
- show confirmation screen before saving

### D. Quick Add from History
Allow users to quickly add:
- recent products
- frequently bought products
- favorite products

---

## 4. Budget Protection Features

### Live Budget Shield
While shopping, show:
- total budget
- amount spent
- remaining amount
- budget health state

### Pre-Add Warning
Before confirming an item, simulate the new total and show:
- projected total
- projected remaining amount
- whether the item causes overspending

### Threshold Alerts
Examples:
- 80 percent of budget used
- 90 percent of budget used
- budget exceeded

### Hard Budget Mode
Optional mode where the app strongly warns before adding items that exceed the limit.
The user may still override the warning.

---

## 5. Local Product Memory

The app should maintain a local product catalog.

It should remember:
- barcode
- product name
- brand
- category
- default unit
- historical prices
- store-specific prices
- purchase frequency

### Benefits
- faster future scans
- reusable item templates
- local personalization without internet

---

## 6. Analytics and Insights

The app should provide local reports such as:
- spending by category
- spending by store
- average session spend
- monthly budget usage
- overspending frequency
- frequent purchases
- cheapest observed store for a product

### Useful Insight Examples
- snacks are consuming a high share of the budget
- this product was cheaper at another store in a previous session
- household spending is above normal this month

---

## 7. Offline AI Possibilities

Offline AI is optional and should be treated as an enhancement.

### Good Uses for Offline AI
- parsing messy OCR text into structured item entries
- suggesting categories
- generating short spending summaries
- recommending cheaper alternatives from local history
- detecting non-essential items likely safe to remove

### Bad Uses for Offline AI
- deciding exact totals
- replacing core budget logic
- assuming unknown barcode metadata without local data
- making critical decisions without user confirmation

### Recommendation
Use rule-based logic for core flows and optional local AI for assistance only.

---

## Suggested Feature Priorities

## MVP
- budget CRUD
- shopping session CRUD
- manual item entry
- running total and remaining budget
- threshold warnings
- local product catalog
- barcode scanning with local lookup
- basic category summaries
- export session summary

## V2
- OCR for receipts and shelf labels
- recent and favorite products
- store-specific price history
- cheaper alternative suggestions using local history
- improved analytics dashboards

## V3
- optional offline AI integration
- voice item entry offline
- smarter product parsing
- remove-items-to-fit-budget suggestions
- unit price comparison

---

## Recommended Technical Architecture

## Platform
- Flutter
- Android-first
- offline-first design

## State Management
Recommended:
- Riverpod

Reason:
- scalable
- testable
- clean separation of concerns

## Local Database
Recommended:
- Drift

Reason:
- strong relational modeling
- good for reports and queries
- fits budgets, sessions, products, and analytics well

Alternative:
- Isar for simpler, high-performance object storage

## Scanning
- barcode scanning module
- OCR text recognition module

## AI Module
Optional and disabled by default on unsupported devices.

---

## Suggested Flutter Layers

### Presentation Layer
- screens
- widgets
- view models/providers

### Domain Layer
- entities
- use cases
- business rules
- budget calculations

### Data Layer
- local database
- repositories
- scanner adapters
- OCR adapters
- AI adapters

---

## Proposed App Modules

### 1. Budget Module
Responsibilities:
- create and edit budgets
- compute remaining amount
- compute warning state
- validate thresholds

### 2. Shopping Session Module
Responsibilities:
- start and end sessions
- manage cart items
- update totals
- trigger warnings

### 3. Product Catalog Module
Responsibilities:
- local product storage
- barcode mapping
- recent and favorites tracking
- store-specific price history

### 4. Scanner Module
Responsibilities:
- barcode camera flow
- OCR camera flow
- scan result validation
- unknown product handling

### 5. Analytics Module
Responsibilities:
- summaries
- trends
- category reports
- store comparisons

### 6. AI Helper Module
Responsibilities:
- OCR cleanup
- category suggestion
- insight generation
- optional natural-language summaries

---

## Data Model

## UserSettings
Fields:
- id
- currencyCode
- defaultWarningPercent
- defaultBudgetType
- darkModeEnabled
- ocrEnabled
- offlineAiEnabled
- hardBudgetModeEnabled

## Budget
Fields:
- id
- name
- type
- amount
- reserveAmount
- warningPercent
- startDate
- endDate
- isActive
- createdAt
- updatedAt

## ShoppingSession
Fields:
- id
- budgetId
- storeName
- startedAt
- endedAt
- runningTotal
- status
- projectedRemaining
- notes

## Product
Fields:
- id
- barcode
- name
- brand
- category
- defaultUnit
- notes
- createdAt
- updatedAt

## ProductPrice
Fields:
- id
- productId
- storeName
- price
- quantity
- unit
- dateRecorded

## CartItem
Fields:
- id
- sessionId
- productId
- nameSnapshot
- priceSnapshot
- quantity
- unit
- lineTotal
- sourceType
- isEssential
- createdAt

## Receipt
Fields:
- id
- sessionId
- imagePath
- rawOcrText
- parsedDataJson
- finalTotal
- createdAt

## Insight
Fields:
- id
- type
- message
- relatedBudgetId
- relatedSessionId
- createdAt

---

## Source Types for Item Entry

Each cart item should track how it was created:
- manual
- barcode
- OCR
- favorite
- recent
- AI parsed

This is useful for debugging, analytics, and improving UX.

---

## Business Rules

### Running Total
The app must recalculate the session total whenever an item is added, edited, or removed.

### Remaining Budget
remainingBudget = budgetAmount - runningTotal

### Projected Budget Check
projectedTotal = runningTotal + newItemTotal
projectedRemaining = budgetAmount - projectedTotal

### Warning Trigger
If projectedTotal crosses a configured threshold, show a warning before confirming the item.

### Exceeded Trigger
If projectedTotal exceeds the budget, show a stronger warning and require confirmation if hard budget mode is enabled.

---

## UX Requirements

### Active Shopping Screen Must Show
- current budget
- current spend
- remaining amount
- scan button
- add item button
- cart list
- warning banner when needed

### UX Principles
- one-hand friendly
- large action buttons
- low typing requirement
- instant feedback after scan
- always confirm uncertain OCR results
- keep the most important numbers visible

---

## Suggested Screen List

### 1. Onboarding
- choose currency
- choose warning threshold
- enable OCR
- enable offline AI
- choose default budget type

### 2. Home Screen
- active budget summary
- recent sessions
- quick start session
- budget usage snapshot

### 3. Budgets Screen
- list budgets
- create budget
- edit budget
- delete budget

### 4. Active Session Screen
- cart items
- running total
- remaining budget
- scan actions
- add manual item
- session warnings

### 5. Scan Screen
- barcode mode
- OCR mode
- camera preview
- recognized results
- confirm and save flow

### 6. Product Editor Screen
- barcode
- name
- category
- price
- quantity
- unit
- essential toggle

### 7. Product Catalog Screen
- all products
- search
- favorites
- recent products
- price history

### 8. Insights Screen
- category breakdown
- budget trend
- frequent products
- store comparisons

### 9. Settings Screen
- AI toggle
- OCR toggle
- hard budget mode
- theme
- export and backup settings

---

## Barcode Scan Workflow

### Known Barcode
1. Scan barcode.
2. Look up barcode in local database.
3. Auto-fill product details.
4. Allow user to update price and quantity.
5. Add to current session.

### Unknown Barcode
1. Scan barcode.
2. No local match found.
3. Prompt user to enter product data.
4. Save product and barcode locally.
5. Add item to current session.

---

## OCR Workflow

### Shelf Label OCR
1. Open OCR scan mode.
2. Capture image.
3. Extract text.
4. Parse likely product name and price.
5. Show editable confirmation form.
6. Save item and optionally save as product.

### Receipt OCR
1. Capture or import receipt image.
2. Extract full text.
3. Parse items, quantities, and totals.
4. Show a review screen.
5. Save validated entries into the session.

---

## AI Workflow Suggestions

### OCR Cleanup Flow
Input:
- raw OCR text

Output:
- product candidates
- quantity candidates
- price candidates
- confidence hints

### Category Suggestion Flow
Input:
- product name
- brand
- previous local patterns

Output:
- suggested category

### Savings Suggestion Flow
Input:
- current session items
- remaining budget
- local purchase history

Output examples:
- remove one non-essential item to remain under budget
- choose the cheaper known variant from previous history

---

## Offline AI Constraints

Potential issues:
- increased app size
- RAM usage on low-end devices
- slower inference on older phones
- battery usage

Mitigations:
- make AI optional
- use small local models only
- allow users to disable AI
- never block core app flows on AI
- fall back to rules and manual confirmation

---

## Security and Privacy

Since the app is offline-first, all sensitive data should remain local by default.

Guidelines:
- store all budgets and products locally
- avoid requiring accounts
- do not send scans or receipts to external services in the base version
- make exports explicit and user-controlled

---

## Export and Backup

Even though the app is offline, it should support manual export.

Suggested export options:
- CSV for sessions and items
- JSON backup for app data
- text or PDF session summary

Optional later:
- encrypted local backup
- import from backup file

---

## Suggested Repository Structure

```text
lib/
  core/
    constants/
    theme/
    utils/
    services/
  data/
    db/
    models/
    repositories/
    datasources/
  domain/
    entities/
    repositories/
    usecases/
  features/
    budgets/
      presentation/
      domain/
      data/
    shopping_session/
      presentation/
      domain/
      data/
    products/
      presentation/
      domain/
      data/
    scanner/
      presentation/
      domain/
      data/
    insights/
      presentation/
      domain/
      data/
    settings/
      presentation/
      domain/
      data/
  app/
    router/
    providers/
    app.dart
```

---

## Suggested Milestones

## Milestone 1: Foundation
- create project structure
- set up state management
- set up local database
- define models and repositories
- build budget CRUD

## Milestone 2: Session Management
- create session flow
- add manual item entry
- compute totals and remaining budget
- show warnings

## Milestone 3: Product Catalog
- save reusable products
- add favorites and recent items
- map barcodes to products

## Milestone 4: Scanner Integration
- barcode scanning
- unknown barcode handling
- local auto-fill for known products

## Milestone 5: OCR
- receipt OCR
- shelf label OCR
- editable extraction confirmation

## Milestone 6: Insights
- category charts
- spending reports
- store comparisons

## Milestone 7: Offline AI
- optional model integration
- OCR cleanup helpers
- categorization suggestions
- savings hints

---

## Quality Requirements

The app should be:
- responsive on low to mid-range Android devices
- fully usable offline
- resilient to scan failures
- easy to understand during active shopping
- testable at the domain and repository layers

---

## Testing Strategy

### Unit Tests
- budget calculations
- threshold logic
- projected total logic
- product reuse logic

### Widget Tests
- budget cards
- session totals display
- warning banners
- product entry forms

### Integration Tests
- create budget to session flow
- barcode scan to product save flow
- OCR result confirmation flow

---

## Recommended Build Order

1. offline data layer
2. budget engine
3. shopping session screen
4. manual item entry
5. local product catalog
6. barcode scanning
7. warnings and projections
8. analytics
9. OCR
10. optional offline AI

---

## Final Recommendation

Build the app in phases and do not start with offline AI first.

The highest-value version of the product is:
- offline budget tracking
- live spending awareness
- barcode-assisted input
- local product memory
- warning system that prevents overspending

Offline AI should only be introduced after the core shopping and budget flow is stable.

---

## Short Project Summary

This project is an offline-first Flutter Android app for shopping budget control. It helps users track spending in real time, add products quickly using scanning or manual entry, store product data locally, and receive warnings before exceeding their budget. Optional on-device AI can enhance OCR parsing, categorization, and savings suggestions without replacing core deterministic budget logic.

