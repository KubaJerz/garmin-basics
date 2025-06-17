// StopConfirmationDelegate.mc - Handles "Stop Recording?" confirmation
import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles the confirmation dialog for stopping activity recording
 * Follows Single Responsibility Principle - only handles stop confirmation
 */
class RecordingStopConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _screenManager;
    private var _activityType;
    
    function initialize(screenManager, activityType) {
        ConfirmationDelegate.initialize();
        _screenManager = screenManager;
        _activityType = activityType;
        System.println("=== StopConfirmationDelegate initialized for: " + activityType + " ===");
    }
    
    function onResponse(response) {
        System.println("=== Stop confirmation response: " + response + " ===");
        
        if (response == WatchUi.CONFIRM_YES) {
            System.println("User confirmed - stopping " + _activityType + " recording");

            // Record time stamp in file
            _screenManager.handleActivityStopEvent(_activityType);

            _stopActivityRecording();
            return true;
        } else {
            System.println("User cancelled - continuing recording");
            // Just return true - confirmation dialog closes, recording continues
            return true;
        }
    }
    
    /**
     * Stop the activity recording and return to previous screen
     */
    private function _stopActivityRecording() {
        // Pop the recording view to return to activity selection
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        
        // Here you could also save recording data, etc.
        System.println("Recording stopped and saved");
    }
}