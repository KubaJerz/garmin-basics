import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles the exit confirmation dialog response
 * Follows the Single Responsibility Principle by only handling exit confirmation
 */
class ExitConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _dataManager;
    
    /**
     * Initialize with reference to data manager for cleanup
     * @param dataManager The data collection manager to stop before exiting
     */
    public function initialize(dataManager) {
        ConfirmationDelegate.initialize();
        _dataManager = dataManager;
    }
    
    /**
     * Handle the user's response to the exit confirmation
     * @param response CONFIRM_YES or CONFIRM_NO
     * @return Boolean indicating if the response was handled
     */
    public function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            // User confirmed they want to exit
            _handleExit();
        } else {
            // User cancelled, return to main view
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return true; // Always return true - we handled the response
    }
    
    /**
     * Handle the exit process - stop data collection and exit app
     */
    private function _handleExit() {
        try {
            // Stop data collection if it's running
            if (_dataManager != null && _dataManager.isRecording()) {
                System.println("Stopping data collection before exit...");
                _dataManager.stopDataCollection();
            }
            
            // Clean shutdown
            if (_dataManager != null) {
                _dataManager.onStop();
            }
            
            // Exit the application
            System.println("Exiting application");
            System.exit();
            
        } catch (ex) {
            System.println("Error during exit: " + ex.getErrorMessage());
            // Exit anyway - don't leave user stuck
            System.exit();
        }
    }
}