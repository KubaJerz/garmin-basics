// RecordingViewDelegate.mc - Handles input during recording
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles input for the recording screen
 * Responsible for detecting red button taps and showing stop confirmation
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
    }
    
    /**
     * Handle touch events on the recording screen
     */
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        
        // Check if red stop button was tapped
        if (_isStopButtonTapped(x, y)) {
            _showStopConfirmation();
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
     * Show confirmation dialog for stopping the recording
     */
    private function _showStopConfirmation() {
        System.println("Showing stop confirmation for: " + _activityType);
        
        var message = "Stop " + _activityType + " recording?";
        var confirmation = new WatchUi.Confirmation(message);
        var delegate = new StopConfirmationDelegate(_screenManager, _activityType);
        
        WatchUi.pushView(confirmation, delegate, WatchUi.SLIDE_UP);
    }
    
    /**
     * Handle back button - show stop confirmation
     */
    function onBack() {
        _showStopConfirmation();
        return true;
    }
}