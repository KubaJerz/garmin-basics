// ExitConfirmationDelegate.mc - Handles confirmation dialog responses
import Toybox.WatchUi;

class ExitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _screenManager;
    
    function initialize(screenManager) {
        ConfirmationDelegate.initialize();
        _screenManager = screenManager;
    }
    
    /**
     * Called when user confirms (selects "Yes")
     */
    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            // User confirmed exit
            _screenManager.confirmExit();
            return true;
        } else {
            // User cancelled exit (selected "No")
            _screenManager.cancelExit();
            return true;
        }
    }
}