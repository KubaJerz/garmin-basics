// SecondaryViewDelegate.mc
import Toybox.Lang;
import Toybox.WatchUi;

/**
 * Handles input for the secondary screen with button detection
 * Follows Single Responsibility Principle - only handles secondary screen input
 */
class SecondaryViewDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    private var _buttonAreas; // Store button coordinates for touch detection
    
    function initialize(screenManager) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        _initializeButtonAreas();
    }
    
    /**
     * Define button areas for touch detection
     * Should match the button positions in SecondaryView
     */
    private function _initializeButtonAreas() {
        var deviceSettings = System.getDeviceSettings();
        var width = deviceSettings.screenWidth;
        var height = deviceSettings.screenHeight;
        
        var buttonWidth = width * 0.7;
        var buttonHeight = height * 0.12;
        var buttonSpacing = height * 0.15;
        var buttonX = (width - buttonWidth) / 2;
        
        // Calculate button areas (same as in SecondaryView)
        var cigButtonY = height * 0.35;
        var vapeButtonY = cigButtonY + buttonHeight + buttonSpacing;
        
        _buttonAreas = {
            "cig" => {
                :x => buttonX,
                :y => cigButtonY,
                :width => buttonWidth,
                :height => buttonHeight
            },
            "vape" => {
                :x => buttonX,
                :y => vapeButtonY,
                :width => buttonWidth,
                :height => buttonHeight
            }
        };
    }
    
    /**
     * Handle touch/tap events
     */
    function onTap(clickEvent) {
        var coords = clickEvent.getCoordinates();
        var button = _getButtonFromCoordinates(coords[0], coords[1]);
        
        if (button != null) {
            _handleButtonPress(button);
            return true; // Event handled
        }
        
        return false; // Event not handled
    }
    
    
    /**
     * Determine which button was pressed based on coordinates
     */
    private function _getButtonFromCoordinates(x, y) {
        // FIXED: Correct Monkey C foreach syntax
        var buttonNames = _buttonAreas.keys();
        for (var i = 0; i < buttonNames.size(); i++) {
            var buttonName = buttonNames[i];
            var area = _buttonAreas[buttonName];
            
            if (_isPointInArea(x, y, area)) {
                return buttonName;
            }
        }
        return null; // No button hit
    }
    /**
     * Check if a point is within a rectangular area
     */
    private function _isPointInArea(x, y, area) {
        return x >= area[:x] && 
               x <= area[:x] + area[:width] &&
               y >= area[:y] && 
               y <= area[:y] + area[:height];
    }
    
    /**
     * Handle the actual button press action
     */
    private function _handleButtonPress(buttonName) {
        System.println("Button pressed: " + buttonName);
        
        switch (buttonName) {
            case "cig":
                _handleCigButtonPress();
                break;
            case "vape":
                _handleVapeButtonPress();
                break;
        }
    }
    
    private function _handleCigButtonPress() {
        System.println("Cigarette tracking selected");
        // Add your cigarette tracking logic here
        // For example: _dataManager.setActivityType("cigarette");
    }
    
    private function _handleVapeButtonPress() {
        System.println("Vape tracking selected");
        // Add your vape tracking logic here  
        // For example: _dataManager.setActivityType("vape");
    }
    
    /**
     * Handle swipe up to return to main screen
     */
    function onSwipe(swipeEvent) {
        if (swipeEvent.getDirection() == WatchUi.SWIPE_UP) {
            _screenManager.handleSwipeUp();
            return true;
        }
        return false;
    }
    
    /**
     * Handle back button
     */
    function onBack() {
        _screenManager.handleSwipeUp(); // Return to main screen
        return true;
    }


    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        
        switch (key) {
                
            case WatchUi.KEY_DOWN:
                _screenManager.handleSwipeUp();
                return true;
        }
        
        return false;
    }
}