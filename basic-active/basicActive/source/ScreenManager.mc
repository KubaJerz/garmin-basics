import Toybox.WatchUi;
import Toybox.System;

class ScreenManager {
    enum ScreenType {
        MAIN,
        SECONDARY
    }
    
    private var _currentScreen;
    private var _mainView;
    private var _secondaryView;
    private var _dataManager = null;

    
    function initialize(dataManager) {
        _currentScreen = MAIN;
        _mainView = null;
        _secondaryView = null;
        _dataManager = dataManager;
    }
    
    // Shows the main data collection screen
    function showMainScreen() {
        System.println("VIEW STACK: Showing main screen - popping to main view");
        if (_mainView == null) {
            _mainView = new basicActiveView(_dataManager);
        }
        _currentScreen = MAIN;
        System.println("VIEW STACK: Popping view with SLIDE_UP transition");
        WatchUi.popView(WatchUi.SLIDE_UP);
    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        System.println("VIEW STACK: Showing secondary screen (activity type selection)");
        if (_secondaryView == null) {
            _secondaryView = new activityTypeView();
        }
        _currentScreen = SECONDARY;
        System.println("VIEW STACK: Pushing activityTypeView with SLIDE_DOWN transition");
        WatchUi.pushView(_secondaryView, new activityTypeViewDelegate(self), WatchUi.SLIDE_DOWN);
    }

    function showRecordingScreen(activityType) {
        System.println("VIEW STACK: Showing recording screen for activity: " + activityType);
        var recordingView = new RecordingView(activityType);
        var recordingDelegate = new RecordingViewDelegate(self, activityType, recordingView);
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
        System.println("INPUT: Swipe down detected on main screen");
        if (_currentScreen == MAIN) {
            showSecondaryScreen();
        }
    }
    
    function handleSwipeUp() {
        System.println("INPUT: Swipe up detected on secondary screen");
        if (_currentScreen == SECONDARY) {
            showMainScreen();
        }
    }

    /**
     * MODIFIED: Now shows password input instead of direct confirmation
     */
    function requestExit() {
        System.println("VIEW STACK: Exit requested - showing password input");
        
        var passwordView = new PasswordInputView();
        var passwordDelegate = new PasswordInputDelegate(self, passwordView);
        
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
    }
    
    function getCurrentScreen() {
        return _currentScreen;
    }
}