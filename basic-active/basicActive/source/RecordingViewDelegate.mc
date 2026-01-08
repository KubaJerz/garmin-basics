// RecordingViewDelegate.mc - Handles input during recording
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles input for the recording screen
 * Responsible for detecting red button taps and stopping recording directly
 */
class RecordingViewDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    private var _activityType;
    private var _recordingView;
    
    function initialize(screenManager, activityType, recordingView) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        _activityType = activityType;
        _recordingView = recordingView;
        System.println("DELEGATE: RecordingViewDelegate initialized for: " + activityType);
    }
    
    /**
     * Handle touch events on the recording screen - Direct stop without confirmation
     */
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        
        System.println("INPUT: Tap detected on recording view at (" + x + ", " + y + ")");
        
        // Check if red stop button was tapped
        if (_isStopButtonTapped(x, y)) {
            System.println("INPUT: Stop button tapped for " + _activityType);
            _stopRecordingDirectly();
            return true;
        }
        
        return false;
    }
    
    /**
     * Check if the stop button was tapped (circular button)
     */
    private function _isStopButtonTapped(x, y) {
        var buttonArea = _recordingView.getStopButtonArea();
        var dx = x - buttonArea[:x];
        var dy = y - buttonArea[:y];
        var distance = Math.sqrt(dx * dx + dy * dy);
        
        return distance <= buttonArea[:radius];
    }
    
    /**
     * Stop recording directly without confirmation
     */
    private function _stopRecordingDirectly() {
        System.println("EVENT: Stopping " + _activityType + " recording directly");

        // Record stop timestamp
        _screenManager.handleActivityStopEvent(_activityType);

        // Pop back to previous screen via ScreenManager
        _screenManager.handleRecordingStop();
    }
    
    /**
     * Handle back button - Direct stop without confirmation
     */
    function onBack() {
        System.println("INPUT: Back button pressed on recording view");
        _stopRecordingDirectly();
        return true;
    }
}