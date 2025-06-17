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
        if (_mainView == null) {
            _mainView = new basicActiveView(_dataManager);
        }
        _currentScreen = MAIN;
        WatchUi.popView(WatchUi.SLIDE_UP);
    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        if (_secondaryView == null) {
            _secondaryView = new activityTypeView();
        }
        _currentScreen = SECONDARY;
        WatchUi.pushView(_secondaryView, new activityTypeViewDelegate(self), WatchUi.SLIDE_DOWN);
    }

    function showRecordingScreen(activityType) {
        var recordingView = new RecordingView(activityType);
        var recordingDelegate = new RecordingViewDelegate(self, activityType, recordingView);
        System.println("we are about to put the activyt view");
        WatchUi.pushView(recordingView, recordingDelegate, WatchUi.SLIDE_UP);
    }

    // records timestamp when a user starts or stops a Smoking or Vape event
    function handleActivityStartEvent(activityType){
        _dataManager.logActivityStartEvent(activityType);
    }

    function handleActivityStopEvent(activityType){
        _dataManager.logActivityStopEvent(activityType);
    }
    
    // Handles swipe navigation between screens
    function handleSwipeDown() {
        if (_currentScreen == MAIN) {
            showSecondaryScreen();
        }
    }
    
    function handleSwipeUp() {
        if (_currentScreen == SECONDARY) {
            showMainScreen();
        }
    }

    /**
     * MODIFIED: Now shows password input instead of direct confirmation
     */
    function requestExit() {
        System.println("Exit requested - showing password input");
        
        var passwordView = new PasswordInputView();
        var passwordDelegate = new PasswordInputDelegate(self, passwordView);
        
        WatchUi.pushView(passwordView, passwordDelegate, WatchUi.SLIDE_LEFT);
    }

    /**
     * Called by password delegate when password is correct
     */
    function confirmExit() {
        System.println("Password verified - exiting app");
        System.exit();
    }

    /**
     * Called when user cancels exit (back button on password or confirmation)
     */
    function cancelExit() {
        System.println("Exit cancelled");
        // Views are automatically popped by their delegates
    }
    
    function getCurrentScreen() {
        return _currentScreen;
    }
}