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
        WatchUi.popView(WatchUi.SLIDE_UP);
    }
    
    // Shows the secondary screen (settings, stats, etc.)
    function showSecondaryScreen() {
        if (_secondaryView == null) {
            _secondaryView = new SecondaryView();
        }
        _currentScreen = SECONDARY;
        WatchUi.pushView(_secondaryView, new basicActiveDelegate(self), WatchUi.SLIDE_DOWN);
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
        var delegate = new ExitConfirmationDelegate(self);
        WatchUi.pushView(dialog, delegate, WatchUi.SLIDE_UP);
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