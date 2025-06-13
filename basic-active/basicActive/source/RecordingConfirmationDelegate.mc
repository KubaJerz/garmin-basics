// RecordingConfirmationDelegate.mc - FIXED VERSION
import Toybox.WatchUi;
import Toybox.System;

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
        
        if (response == WatchUi.CONFIRM_NO) {
            System.println("User cancelled - returning to activity selection");
            return false; // Let the confirmation dialog handle the dismissal
        } 
        else {
            System.println("User confirmed - starting " + _activityType + " recording");
            
            // FIXED: Use switchToView instead of pushView
            var recordingView = new RecordingView(_activityType);
            var recordingDelegate = new RecordingViewDelegate(_screenManager, _activityType, recordingView);
            
            WatchUi.switchToView(recordingView, recordingDelegate, WatchUi.SLIDE_UP);
            WatchUi.pushView(recordingView, recordingDelegate, WatchUi.SLIDE_UP);
            
            return true;
        }
    }
}