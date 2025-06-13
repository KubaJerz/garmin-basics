/**
 * SecondaryViewDelegate.mc - Simplified version without complex containers
 */
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class SecondaryViewDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    
    // Button area coordinates - calculated once
    private var _cigButtonX, _cigButtonY, _cigButtonWidth, _cigButtonHeight;
    private var _vapeButtonX, _vapeButtonY, _vapeButtonWidth, _vapeButtonHeight;
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
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
        var buttonSpacing = height * 0.05;
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
        
        // Check cig button
        if (_isPointInButton(x, y, _cigButtonX, _cigButtonY, _cigButtonWidth, _cigButtonHeight)) {
            _handleCigButtonPress();
            return true;
        }
        
        // Check vape button
        if (_isPointInButton(x, y, _vapeButtonX, _vapeButtonY, _vapeButtonWidth, _vapeButtonHeight)) {
            _handleVapeButtonPress();
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
    
    /**
     * Handle button presses
     */
    private function _handleCigButtonPress() {
        System.println("Cigarette button pressed");
        // Add your logic here
    }
    
    private function _handleVapeButtonPress() {
        System.println("Vape button pressed");
        // Add your logic here
    }
    
    /**
     * Handle swipe up to return to main screen
     */
    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            System.println("Swipe up - returning to main screen");
            _screenManager.handleSwipeUp();
            return true;
        }
        return false;
    }
    
    /**
     * Handle back button
     */
    function onBack() {
        System.println("Back button - returning to main screen");
        _screenManager.handleSwipeUp();
        return true;
    }
}