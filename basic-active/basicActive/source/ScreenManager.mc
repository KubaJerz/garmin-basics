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
    function handleActivityTimestampEvent(activityType){
        _dataManager.logActivityTimestampEvent(activityType);
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

    function requestExit() {
        var dialog = new WatchUi.Confirmation("Exit app and stop data collection?");
        var delegate = new AppExitConfirmationDelegate(self);
        WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_LEFT);
    }

    function confirmExit() {
        System.println("User confirmed exit");
        System.exit();
    }

    function cancelExit() {
        System.println("User cancelled exit");
        // WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
    
    
    function getCurrentScreen() {
        return _currentScreen;
    }

}