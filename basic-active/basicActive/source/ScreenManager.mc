import Toybox.WatchUi;

// ScreenManager.mc - Handles screen navigation logic
using Toybox.WatchUi;

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
        
        _pushView(_mainView, new SwipeInputDelegate(self));
        _currentScreen = MAIN;
    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        if (_secondaryView == null) {
            _secondaryView = new SecondaryView();
        }
        
        _pushView(_secondaryView, new SwipeInputDelegate(self));
        _currentScreen = SECONDARY;
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
    
    function getCurrentScreen() {
        return _currentScreen;
    }
    
    // Private helper to avoid code duplication
    private function _pushView(view, delegate) {
        WatchUi.pushView(view, delegate, WatchUi.SLIDE_IMMEDIATE);
    }
}