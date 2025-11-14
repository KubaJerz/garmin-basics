// ExitConfirmationDelegate.mc - FIXED version
import Toybox.WatchUi;
import Toybox.System;

class AppExitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _screenManager = null;
    
    function initialize(screenManager) {
        _screenManager = screenManager;
        ConfirmationDelegate.initialize();
        System.println("DELEGATE: AppExitConfirmationDelegate initialized");
    }


    function onResponse(response){
        System.println("INPUT: Exit confirmation response: " + response);
        
        if (response == WatchUi.CONFIRM_YES) {
            System.println("EVENT: User confirmed exit - shutting down");
            _screenManager.confirmExit();
            return true; // FIXED: Return true when handled
        } else {
            System.println("INPUT: User cancelled exit - staying in app");
            _screenManager.cancelExit();

            // The confirmation dialog will automatically close
            return true; // FIXED: Return true when handled
        }
    }
}