import Toybox.WatchUi;

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
        // WatchUi.pushView(_mainView, new SwipeInputDelegate(self), WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_UP);

    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        if (_secondaryView == null) {
            _secondaryView = new SecondaryView();
        }
        _currentScreen = SECONDARY;
        WatchUi.pushView(_secondaryView, new SwipeInputDelegate(self), WatchUi.SLIDE_IMMEDIATE);
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

    function handleBackButton() {
        if (_currentScreen == SECONDARY) {
            showMainScreen();
            return true;
        } else if (_currentScreen == MAIN) {
            exit();
            return true;
        }
        return false;
    }
    
    function getCurrentScreen() {
        return _currentScreen;
    }

    function exit() {
        _dataManager.onStop();

        System.exit();
    }
}