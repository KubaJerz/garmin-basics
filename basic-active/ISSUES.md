# Known Issues

## Bug #1: ScreenManager State Desynchronization After Recording Flow

**Status**: Fixed
**Severity**: Critical
**Reported**: 2026-01-07
**Fixed**: 2026-01-07
**Branch**: fix/timer-garbage-collection

### Symptoms

After completing a recording flow (activity selection → recording → stop), the navigation buttons become inverted or non-functional:

1. **UP button does nothing** (should navigate to secondary screen)
2. **DOWN button exits the app** (should do nothing or navigate back)

### Steps to Reproduce

1. Launch app (on main screen)
2. Press UP button to navigate to secondary screen (activity selection)
3. Tap "Cig" or "Vape" button to start recording
4. Tap stop button to end recording
5. Return to main screen
6. Press UP button → **Nothing happens** (expected: go to secondary screen)
7. Press DOWN button → **App exits** (expected: do nothing or stay on main)

### Root Cause

The `RecordingViewDelegate` directly calls `WatchUi.popView()` (line 66) without informing the `ScreenManager`. This causes the ScreenManager's `_currentScreen` state variable to become out of sync with the actual view stack.

**Flow Analysis** (from log `/Users/kuba/Desktop/kuba-daily-life-garmin/basicActive.TXT`):

```
Line 12-15:  Navigate main → secondary
             _currentScreen = ACTIVITY_SELECTION ✓

Line 20-25:  Navigate secondary → recording
             _currentScreen = RECORDING ✓

Line 26-30:  Tap stop button
             RecordingViewDelegate calls WatchUi.popView() directly
             View stack: recording → secondary
             BUT _currentScreen still = RECORDING ✗ (should be ACTIVITY_SELECTION)

Line 31-33:  Swipe up detected on secondary view
             ScreenManager thinks _currentScreen == RECORDING
             Calls handleSwipeUp() which pops to activity selection
             View stack: secondary → main (actually pops to main!)
             Sets _currentScreen = ACTIVITY_SELECTION ✗ (should be MAIN)

Line 111-120: Press UP button 3 times
              handleSwipeDown() checks if (_currentScreen == MAIN)
              But _currentScreen == ACTIVITY_SELECTION ✗
              Nothing happens

Line 121-126: Press DOWN button
              handleSwipeUp() checks if (_currentScreen == ACTIVITY_SELECTION) ✓
              Calls showMainScreen() which pops view
              But already on main → pops main view → APP EXITS
```

### Solution

**Never directly call `WatchUi.popView()` from delegates.** Instead, delegates should notify the ScreenManager to handle all navigation so it can properly track the `_currentScreen` state.

**Files affected**:
- `source/RecordingViewDelegate.mc:66` - Direct `WatchUi.popView()` call
- `source/ScreenManager.mc` - Needs method to handle recording stop navigation

### Implementation

**Fixed by adding three new navigation methods to ScreenManager:**
- `handleRecordingStop()` - Pops from RECORDING to ACTIVITY_SELECTION with state update
- `handlePasswordCancel()` - Pops from PASSWORD to MAIN with state update
- `handlePasswordSuccess()` - Pops from PASSWORD to MAIN before app exit

**Updated three delegates to use ScreenManager methods:**
- `RecordingViewDelegate.mc:65` - Calls `handleRecordingStop()` instead of direct `popView()`
- `PasswordInputDelegate.mc:73` - Calls `handlePasswordCancel()` instead of direct `popView()`
- `PasswordInputDelegate.mc:95` - Calls `handlePasswordSuccess()` instead of direct `popView()`

**Result:** ScreenManager is now the single source of truth for all navigation. The `_currentScreen` state always stays synchronized with the actual view stack.

### Related Issues

This is part of the broader timer garbage collection investigation on branch `fix/timer-garbage-collection`.
