// // SwipeInputDelegate.mc - Handles only swipe input
// using Toybox.WatchUi;

// class SwipeInputDelegate extends WatchUi.InputDelegate {
//     private var _screenManager;
    
//     function initialize(screenManager) {
//         InputDelegate.initialize();
//         _screenManager = screenManager;
//     }
    
//     // Handle swipe gestures for navigation
//     function onSwipe(swipeEvent) {
//         var direction = swipeEvent.getDirection();
        
//         switch (direction) {
//             case WatchUi.SWIPE_DOWN:
//                 _screenManager.handleSwipeDown();
//                 return true;  // Event handled
                
//             case WatchUi.SWIPE_UP:
//                 _screenManager.handleSwipeUp();
//                 return true;  // Event handled
//         }
        
//         return false;  // Event not handled
//     }

//     function onKey(keyEvent) {
//         var key = keyEvent.getKey();
        
//         switch (key) {
//             case WatchUi.KEY_UP:
//                 _screenManager.handleSwipeDown(); // seems counter intuative but if the bottom button "key up" is pressed we want to go to the bottom
//                 return true;
                
//             case WatchUi.KEY_DOWN:
//                 _screenManager.handleSwipeUp(); // seems counter intuative but if the middle button "key down" is pressed we want to go to the top
//                 return true;
//             case WatchUi.KEY_ESC:
//                 _screenManager.ha
//         }
        
//         return false;
//     }
    
//     // // Allow back button to work normally
//     // function onBack() {
//     //     return false;
//     // }
// }