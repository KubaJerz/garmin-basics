/**
 * SecondaryViewDelegate.mc - Simplified version without complex containers
 */
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class activityTypeViewDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    
    // Button area coordinates - calculated once
    private var _cigButtonX, _cigButtonY, _cigButtonWidth, _cigButtonHeight;
    private var _vapeButtonX, _vapeButtonY, _vapeButtonWidth, _vapeButtonHeight;
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        System.println("DELEGATE: activityTypeViewDelegate initialized for secondary view");
        _calculateButtonAreas();
    }
    
    /**
     * Calculate button positions (matches SecondaryView layout)
     * Simple approach - no complex data structures
     */
    private function _calculateButtonAreas() {
        var deviceSettings = System.getDeviceSettings();
        var width = deviceSettings.screenWidth;
        var height = deviceSettings.screenHeight;
        
        var buttonWidth = width * 0.7;
        var buttonHeight = height * 0.12;
        var buttonSpacing = height * 0.15;
        var buttonX = (width - buttonWidth) / 2;
        
        // Cig button area
        _cigButtonX = buttonX;
        _cigButtonY = height * 0.35;
        _cigButtonWidth = buttonWidth;
        _cigButtonHeight = buttonHeight;
        
        // Vape button area
        _vapeButtonX = buttonX;
        _vapeButtonY = _cigButtonY + buttonHeight + buttonSpacing;
        _vapeButtonWidth = buttonWidth;
        _vapeButtonHeight = buttonHeight;
    }
    
    /**
     * Handle touch/tap events - CLEAN & SIMPLE
     */
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var x = coords[0];
        var y = coords[1];
        
        System.println("INPUT: Tap detected on secondary view at (" + x + ", " + y + ")");
        
        // Check cig button
        if (_isPointInButton(x, y, _cigButtonX, _cigButtonY, _cigButtonWidth, _cigButtonHeight)) {
            System.println("INPUT: Cigarette button tapped");
            _showRecordingConfirmation("cigarette");
            return true;
        }
        
        // Check vape button
        if (_isPointInButton(x, y, _vapeButtonX, _vapeButtonY, _vapeButtonWidth, _vapeButtonHeight)) {
            System.println("INPUT: Vape button tapped");
            _showRecordingConfirmation("vape");
            return true;
        }
        
        return false; // No button hit
    }
    
    /**
     * Simple point-in-rectangle check
     */
    private function _isPointInButton(x, y, buttonX, buttonY, buttonWidth, buttonHeight) {
        return x >= buttonX && 
               x <= buttonX + buttonWidth &&
               y >= buttonY && 
               y <= buttonY + buttonHeight;
    }

    private function _showRecordingConfirmation(activityType) {
        System.println("VIEW STACK: Showing recording confirmation for: " + activityType);
        
        var message = "Start recording " + activityType + " activity?";
        var confirmation = new WatchUi.Confirmation(message);
        var delegate = new RecordingStartConfirmationDelegate(_screenManager, activityType);
        
        System.println("VIEW STACK: Pushing Confirmation dialog with SLIDE_UP transition");
        WatchUi.pushView(confirmation, delegate, WatchUi.SLIDE_UP);
    }
    
    /**
     * Handle swipe up to return to main screen
     */
    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            System.println("INPUT: Swipe up detected on secondary view - returning to main");
            _screenManager.handleSwipeUp();
            return true;
        }
        return false;
    }
    
    /**
     * Handle back button
     */
    function onBack() {
        System.println("INPUT: Back button pressed on secondary view - returning to main");
        _screenManager.handleSwipeUp();
        return true;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        System.println("INPUT: Key pressed on secondary view: " + key);
        
        switch (key) {
                
            case WatchUi.KEY_DOWN:
                System.println("INPUT: KEY_DOWN - returning to main screen");
                _screenManager.handleSwipeUp();
                return true;
            
        }
        
        return false;
    }
}