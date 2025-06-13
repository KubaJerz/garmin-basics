// RecordingConfirmationDelegate.mc - Handles "Start Recording?" confirmation
import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles the confirmation dialog for starting activity recording
 * Follows Single Responsibility Principle - only handles recording confirmation
 */
class RecordingConfirmationDelegate extends WatchUi.ConfirmationDelegate {
    private var _screenManager;
    private var _activityType;
    
    function initialize(screenManager, activityType) {
        ConfirmationDelegate.initialize();
        _screenManager = screenManager;
        _activityType = activityType;
        System.println("=== RecordingConfirmationDelegate initialized for: " + activityType + " ===");
    }
    
    function onResponse(response) {
        System.println("=== Recording confirmation response: " + response + " ===");
        
        if (response == WatchUi.CONFIRM_YES) {
            System.println("User confirmed - starting " + _activityType + " recording");
            _startActivityRecording();
            return true;
        } else {
            System.println("User cancelled - returning to activity selection");
            // Just return true - confirmation dialog closes automatically
            return true;
        }
    }
    
    /**
     * Start the activity recording and show the recording screen
     */
    private function _startActivityRecording() {
        // Show the recording screen with red stop button
        // _screenManager.showRecordingScreen(_activityType);
        
    }
}