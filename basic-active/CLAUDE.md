# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Garmin ConnectIQ watch application (MonkeyC) called "basicActive" that monitors and records physiological and behavioral data on Garmin wearables. Target device: Enduro 3 (API 4.0.0+).

## Build and Development

**Build Tool**: Garmin ConnectIQ SDK with Monkey Jungle build system

The project uses VS Code with the ConnectIQ extension. Build and deploy through the extension or command line:
- Build: `monkeyc` via ConnectIQ SDK
- Project file: `basicActive/monkey.jungle`
- Manifest: `basicActive/manifest.xml`

**Debug output**: Use `System.println()` statements; view in simulator console or device logs.

## Architecture

### Core Application Pattern: Model-View-Delegate (MVD)
- **Views** handle UI rendering (extend `WatchUi.View`)
- **Delegates** handle input (extend `WatchUi.BehaviorDelegate`)
- Views and delegates are paired and pushed together via `WatchUi.pushView()`

### Key Modules

**App Core** (`source/`):
- `basicActiveApp.mc` - Entry point, session lifecycle, coordinates data collection
- `ScreenManager.mc` - Navigation state machine

**Data Collection** (Facade Pattern):
- `DataCollectionManager.mc` - Facade coordinating all data collection subsystems
- `BatteryTracker.mc` - Battery level monitoring (FIT field ID 0)
- `ActivityEventManager.mc` - User-triggered cigarette/vape events (FIT fields 1-2)
- `HeartBeatIntervalManager.mc` - Beat-to-beat R-R intervals for HRV (FIT fields 3-8)

**Recording Flow**:
1. User selects activity type → `activityTypeView`
2. Recording starts → `RecordingView` with stop button
3. Data written to FIT session via `FitContributor` fields

### Session Management
- Sessions auto-rotate every 3 hours (`SESSION_DURATION_MS`)
- Background timer triggers save and restart
- FIT files contain custom fields defined in `resources/fitContributions/fitContributions.xml`

### Security
- 4-digit PIN required to exit app (`PasswordInputView/Delegate`)
- Current PIN: "1234" (hardcoded in `PasswordInputDelegate.mc`)

## MonkeyC Specifics

**Toybox modules used**:
- `ActivityRecording` - FIT session recording
- `FitContributor` - Custom FIT fields
- `Sensor` - Heart rate sensor callbacks
- `SensorLogging` - Accelerometer/gyroscope logging
- `Timer` - Background scheduling
- `WatchUi` - Views, delegates, input handling

**Common patterns**:
```monkeyc
// View lifecycle
function onLayout(dc) {}  // Setup, called once
function onShow() {}      // View becoming visible
function onHide() {}      // View being hidden
function onUpdate(dc) {}  // Draw frame

// Delegate input
function onSelect() {}    // Enter/select button
function onBack() {}      // Back button
function onSwipe(evt) {}  // Swipe gestures
```

**Memory management**: Watch has limited memory. Clean up timers and callbacks in `onHide()` or `onStop()`. Recent fix addressed timer garbage collection crashes.

## File Structure

```
basicActive/
├── source/           # MonkeyC source files
├── resources/
│   ├── layouts/      # XML UI layouts
│   ├── strings/      # Localization
│   ├── drawables/    # Icons and graphics
│   └── fitContributions/  # Custom FIT field definitions
├── manifest.xml      # App permissions and metadata
├── monkey.jungle     # Build configuration
└── bin/              # Build output (not committed)
```

## FIT Field IDs

| ID | Field | Type | Description |
|----|-------|------|-------------|
| 0 | Battery | FLOAT | Battery percentage (sampled every 60s) |
| 1 | Event Active | UINT32 | 1=recording event, 0=not recording |
| 2 | Event Type | UINT8 | 1=cigarette, 2=vape |
| 3-7 | Beat Intervals | UINT16 | R-R intervals in ms (up to 5/sec) |
| 8 | Beat Count | UINT8 | Number of valid intervals this second |

## Required Permissions

`Fit`, `FitContributor`, `Sensor`, `SensorLogging`, `PersistedLocations`

## Known Issues

### Timer Garbage Collection Bug (branch: `fix/timer-garbage-collection`)

**Symptoms**:
1. Navigate from main screen to second screen (activity selection)
2. Leave on second screen for extended period
3. Return to main screen → time display stops auto-updating
4. Time only updates when navigating to second screen and back
5. Battery display stops updating completely, even after screen switches

**Possible cause**: Timer objects get garbage collected by the runtime when views are inactive for too long. When returning to main screen, the UI update timers no longer exist.

**Partial fix status**:
- Session save timer (3-hour rotation) now works correctly after the fix
- UI update timers (time/battery display) still affected - investigation ongoing
