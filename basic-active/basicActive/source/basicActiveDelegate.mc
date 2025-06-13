import Toybox.Lang;
import Toybox.WatchUi;

class basicActiveDelegate extends WatchUi.BehaviorDelegate {

    private var _screenManager;
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
    }
    
    // Handle back button through BehaviorDelegate
    function onBack() {
        System.println("Back button pressed - requesting exit confirmation");
        _screenManager.requestExit();
        return true; // Prevent default behavior
    }
    
    // Handle swipes through InputDelegate methods
    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();
        
        switch (direction) {
            case WatchUi.SWIPE_DOWN:
                System.println("Swipe down detected");
                _screenManager.handleSwipeDown();
                return true;
                
            case WatchUi.SWIPE_UP:
                System.println("Swipe up detected");
                _screenManager.handleSwipeUp();
                return true;
        }
        
        return false;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        System.println("Key pressed: " + key);
        
        switch (key) {
            case WatchUi.KEY_UP:
                _screenManager.handleSwipeDown();
                return true;
                
            case WatchUi.KEY_DOWN:
                _screenManager.handleSwipeUp();
                return true;
                
            case WatchUi.KEY_ESC: // This might be the back button
                System.println("ESC key (back button) pressed");
                _screenManager.requestExit();
                return true;
        }
        
        return false;
    }
}