import Toybox.Lang;
import Toybox.WatchUi;

class basicActiveDelegate extends WatchUi.BehaviorDelegate {

    private var _screenManager;
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        System.println("DELEGATE: basicActiveDelegate initialized for main view");
    }
    
    // Handle back button through BehaviorDelegate
    function onBack() {
        System.println("INPUT: Back button pressed on main view - requesting exit confirmation");
        _screenManager.requestExit();
        return true; // Prevent default behavior
    }
    
    // Handle swipes through InputDelegate methods
    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();
        
        switch (direction) {
            case WatchUi.SWIPE_DOWN:
                System.println("INPUT: Swipe down detected on main view");
                _screenManager.handleSwipeDown();
                return true;
                
            case WatchUi.SWIPE_UP:
                System.println("INPUT: Swipe up detected on main view");
                _screenManager.handleSwipeUp();
                return true;
        }
        
        return false;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        System.println("INPUT: Key pressed on main view: " + key);
        
        switch (key) {
            case WatchUi.KEY_UP:
                System.println("INPUT: KEY_UP - navigating to secondary screen");
                _screenManager.handleSwipeDown();
                return true;
                
            case WatchUi.KEY_DOWN:
                System.println("INPUT: KEY_DOWN - navigating to main screen");
                _screenManager.handleSwipeUp();
                return true;
                
            case WatchUi.KEY_ESC: // This might be the back button
                System.println("INPUT: ESC key (back button) pressed on main view");
                _screenManager.requestExit();
                return true;
        }
        
        return false;
    }
}