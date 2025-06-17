// PasswordInputView.mc - Simple password input using number sequence
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.System;

/**
 * Simple password input view using number sequence
 * Follows Single Responsibility Principle - only handles password input
 */
class PasswordInputView extends WatchUi.View {
    private var _enteredDigits = [];
    private var _maxDigits = 4; // 4-digit PIN
    private var _title = "Enter PIN to Exit";
    private var _currentDigitFromDelegate = 0;
    
    function initialize() {
        View.initialize();
        _enteredDigits = [];
    }
    
    function onLayout(dc) {
        // Simple layout
    }
    
    function onShow() {
        WatchUi.requestUpdate();
    }
    
    function onUpdate(dc) {
        _drawPasswordScreen(dc);
    }
    
    /**
     * Draw the password input screen
     */
    private function _drawPasswordScreen(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height * 0.2, 
            Graphics.FONT_SMALL, 
            _title, 
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Draw entered digits as dots/asterisks
        _drawPasswordDots(dc, width, height);
        
        // Instructions
        dc.drawText(
            width / 2, 
            height * 0.65, 
            Graphics.FONT_XTINY, 
            "Use Up/Down, Select to confirm", 
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    /**
     * Draw password dots showing progress
     */
    private function _drawPasswordDots(dc, width, height) {
        var dotSpacing = width / (_maxDigits + 1);
        var dotY = height * 0.4;
        var dotRadius = 16;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        for (var i = 0; i < _maxDigits; i++) {
            var dotX = dotSpacing * (i + 1);
            
            if (i < _enteredDigits.size()) {
                // Filled dot for entered digit
                dc.fillCircle(dotX, dotY, dotRadius);
            } else {
                // Empty circle for remaining digits
                dc.drawCircle(dotX, dotY, dotRadius);
            }
        }
        
        // Show current digit being entered
        if (_enteredDigits.size() < _maxDigits) {
            var currentX = dotSpacing * (_enteredDigits.size() + 1);
            dc.drawText(
                currentX, 
                dotY - 15, 
                Graphics.FONT_SMALL, 
                getCurrentDigit().toString(), 
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }
    
    /**
     * Add a digit to the password
     */
    function addDigit(digit) {
        if (_enteredDigits.size() < _maxDigits) {
            _enteredDigits.add(digit);
            WatchUi.requestUpdate();
            return _enteredDigits.size() == _maxDigits; // Return true if complete
        }
        return false;
    }
    
    /**
     * Remove last digit
     */
    function removeLastDigit() {
        if (_enteredDigits.size() > 0) {
            _enteredDigits = _enteredDigits.slice(0, _enteredDigits.size() - 1);
            WatchUi.requestUpdate();
        }
    }
    
    /**
     * Get current digit being selected (0-9, cycles)
     * This is called by the delegate to show current selection
     */
    function getCurrentDigit() {
        // Return the digit being managed by delegate
        return _currentDigitFromDelegate;
    }
    
    /**
     * Set current digit from delegate
     */
    function setCurrentDigit(digit) {
        _currentDigitFromDelegate = digit;
        WatchUi.requestUpdate();
    }
    
    /**
     * Get the entered password as string
     */
    function getEnteredPassword() {
        var password = "";
        for (var i = 0; i < _enteredDigits.size(); i++) {
            password += _enteredDigits[i].toString();
        }
        return password;
    }
    
    /**
     * Clear entered digits
     */
    function clearPassword() {
        _enteredDigits = [];
        WatchUi.requestUpdate();
    }
    
    /**
     * Check if password is complete
     */
    function isPasswordComplete() {
        return _enteredDigits.size() == _maxDigits;
    }
}