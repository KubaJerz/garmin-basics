import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class lifecycle_trackingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();

        System.println("   DELEGATE: initialize() - Input handler ready!");
        System.println("   → Ready to handle button presses");
        System.println("----------------------------------------");
    }


    function onSelect() as Boolean {
        System.println("  USER INPUT: Select button pressed!");
        System.println("   → User interaction detected");
        System.println("   → App is responding to input");
        System.println("----------------------------------------");
        
        // Force an update to show current time
        WatchUi.requestUpdate();
        return true;
    }

    function onBack() as Boolean {
        System.println("⬅  USER INPUT: Back button pressed!");
        System.println("   → User wants to exit or go back");
        System.println("   → This might trigger onHide() and onStop()");
        System.println("----------------------------------------");
        
        return false; // Let system handle back button (exit app)
    }

    function onMenu() as Boolean {
        System.println("  USER INPUT: Menu button pressed!");
        System.println("   → User wants to see menu options");
        System.println("----------------------------------------");
        
        return true;
    }

}