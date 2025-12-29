import Toybox.WatchUi;
import Toybox.System;

class ScreenManager {
    enum ScreenType {
        MAIN,
        ACTIVITY_SELECTION,
        RECORDING,
        PASSWORD
    }
    
    private var _currentScreen;
    private var _dataManager = null;

    
    function initialize(dataManager) {
        _currentScreen = MAIN;
        _dataManager = dataManager;
    }
    
    // Shows the main data collection screen
    function showMainScreen() {
        System.println("VIEW STACK: Showing main screen - popping to main view");
        
        if (_currentScreen != MAIN) {
            System.println("VIEW STACK: Popping view with SLIDE_UP transition");
            WatchUi.popView(WatchUi.SLIDE_UP);
            _currentScreen = MAIN;
        } else {
            System.println("VIEW STACK: Already on main screen, not popping");
        }
    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        System.println("VIEW STACK: Showing secondary screen (activity type selection)");
        
        var activityView = new activityTypeView();
        var activityDelegate = new activityTypeViewDelegate(self);
        
        _currentScreen = ACTIVITY_SELECTION;
        System.println("VIEW STACK: Pushing activityTypeView with SLIDE_DOWN transition");
        WatchUi.pushView(activityView, activityDelegate, WatchUi.SLIDE_DOWN);
    }

    function showRecordingScreen(activityType) {
        System.println("VIEW STACK: Showing recording screen for activity: " + activityType);
        
        var recordingView = new RecordingView(activityType);
        var recordingDelegate = new RecordingViewDelegate(self, activityType, recordingView);
        
        _currentScreen = RECORDING;
        System.println("VIEW STACK: Pushing RecordingView with SLIDE_UP transition");
        WatchUi.pushView(recordingView, recordingDelegate, WatchUi.SLIDE_UP);
    }

    // records timestamp when a user starts or stops a Smoking or Vape event
    function handleActivityStartEvent(activityType){
        System.println("EVENT: Recording start event for activity: " + activityType);
        _dataManager.logActivityStartEvent(activityType);
    }

    function handleActivityStopEvent(activityType){
        System.println("EVENT: Recording stop event for activity: " + activityType);
        _dataManager.logActivityStopEvent(activityType);
    }
    
    // Handles swipe navigation between screens
    function handleSwipeDown() {
        System.println("INPUT: Swipe down detected");
        if (_currentScreen == MAIN) {
            showSecondaryScreen();
        }
    }
    
    function handleSwipeUp() {
        System.println("INPUT: Swipe up detected");
        if (_currentScreen == ACTIVITY_SELECTION) {
            showMainScreen();
        } else if (_currentScreen == RECORDING) {
            // Pop back to activity selection
            System.println("VIEW STACK: Popping from recording to activity selection");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _currentScreen = ACTIVITY_SELECTION;
        }
    }

    /**
     * MODIFIED: Now shows password input instead of direct confirmation
     */
    function requestExit() {
        System.println("VIEW STACK: Exit requested - showing password input");
        
        var passwordView = new PasswordInputView();
        var passwordDelegate = new PasswordInputDelegate(self, passwordView);
        
        _currentScreen = PASSWORD;
        System.println("VIEW STACK: Pushing PasswordInputView with SLIDE_LEFT transition");
        WatchUi.pushView(passwordView, passwordDelegate, WatchUi.SLIDE_LEFT);
    }

    /**
     * Called by password delegate when password is correct
     */
    function confirmExit() {
        System.println("EVENT: Password verified - exiting app");
        System.exit();
    }

    /**
     * Called when user cancels exit (back button on password or confirmation)
     */
    function cancelExit() {
        System.println("EVENT: Exit cancelled - returning to app");
        // Views are automatically popped by their delegates
        // Reset to previous screen state (password is always shown from main)
        _currentScreen = MAIN;
    }
    
    function getCurrentScreen() {
        return _currentScreen;
    }
}