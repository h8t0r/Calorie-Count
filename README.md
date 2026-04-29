# Calorie Count (iPhone 17 Pro Focus)

This repository contains a SwiftUI-first app skeleton for an iOS calorie tracker designed around your requested flows:

- **Daily total resets automatically each day**.
- **Quick Add page** with a calorie picker (increments of 25) and add/undo actions.
- **Food Items page** where each item has a quantity picker (0...3) and contributes calories based on quantity × calories per item.
- **Settings page** to add/remove food items, set calories per item, and manually override/reset today’s total.

## Suggested project setup in Xcode

1. Open Xcode 16+.
2. Create a new **iOS App** project named `CalorieCount`.
3. Replace generated SwiftUI files with files from `ios/CalorieCount/`.
4. Ensure deployment target is set to your desired iOS version.
5. Run on iPhone 17 Pro simulator/device.

## Architecture

- `CalorieStore` is the single source of truth.
- Daily state is tracked by `dayStamp` (`yyyy-MM-dd`), and state is reset when a new day is detected.
- Actions are persisted in `UserDefaults` so the total survives app relaunch.
- Undo is implemented as a stack of `CalorieAction` records.

## Next enhancements

- HealthKit sync.
- iCloud data sync.
- Charts for weekly trends.
- Food search/import from nutrition APIs.
