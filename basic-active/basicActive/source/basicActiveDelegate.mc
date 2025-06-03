import Toybox.Lang;
import Toybox.WatchUi;

class basicActiveDelegate extends WatchUi.BehaviorDelegate {
    private var _dataManager;
    
    /**
     * Initialize with reference to data manager
     * @param dataManager The data collection manager
     */
    public function initialize(dataManager) {
        BehaviorDelegate.initialize();
        _dataManager = dataManager;
    }

    /**
     * Handle menu button press
     */
    public function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new basicActiveMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }
    
    /**
     * Handle back button press - show exit confirmation
     */
    public function onBack() as Boolean {
        _showExitConfirmation();
        return true; // Indicate we handled the back press
    }
    
    /**
     * Show exit confirmation dialog
     */
    private function _showExitConfirmation() {
        var message = "Stop recording and exit?";
        
        // If not currently recording, change the message
        if (_dataManager != null && !_dataManager.isRecording()) {
            message = "Exit application?";
        }
        
        var confirmation = new WatchUi.Confirmation(message);
        var delegate = new ExitConfirmationDelegate(_dataManager);
        
        WatchUi.pushView(confirmation, delegate, WatchUi.SLIDE_UP);
    }
}