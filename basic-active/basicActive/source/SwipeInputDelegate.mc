// SwipeInputDelegate.mc - Handles only swipe input
using Toybox.WatchUi;

class SwipeInputDelegate extends WatchUi.InputDelegate {
    private var _screenManager;
    
    function initialize(screenManager) {
        InputDelegate.initialize();
        _screenManager = screenManager;
    }
    
    // Handle swipe gestures for navigation
    function onSwipe(swipeEvent) {
        var direction = swipeEvent.getDirection();
        
        switch (direction) {
            case WatchUi.SWIPE_DOWN:
                _screenManager.handleSwipeDown();
                return true;  // Event handled
                
            case WatchUi.SWIPE_UP:
                _screenManager.handleSwipeUp();
                return true;  // Event handled
        }
        
        return false;  // Event not handled
    }
    
    // Allow back button to work normally
    function onBack() {
        // var result = _screenManager.handleBackButton();
        // return result;
        return false;
    }
}