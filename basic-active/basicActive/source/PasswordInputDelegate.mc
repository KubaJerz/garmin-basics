// PasswordInputDelegate.mc - Handles password input interactions
import Toybox.WatchUi;
import Toybox.System;

/**
 * Handles input for password entry screen
 * Follows Single Responsibility Principle - only manages password input logic
 */
class PasswordInputDelegate extends WatchUi.BehaviorDelegate {
    private var _screenManager;
    private var _passwordView;
    private var _currentDigit = 0; // Current digit being selected (0-9)
    
    // Set your desired password here (store securely in real app)
    private const CORRECT_PASSWORD = "1234"; // Change this to your desired PIN
    
    function initialize(screenManager, passwordView) {
        BehaviorDelegate.initialize();
        _screenManager = screenManager;
        _passwordView = passwordView;
        _currentDigit = 0;
    }
    
    /**
     * Handle up button - increment current digit
     */
    function onNextPage() {
        _currentDigit = (_currentDigit + 1) % 10; // Cycle 0-9
        _passwordView.setCurrentDigit(_currentDigit);
        return true;
    }
    
    /**
     * Handle down button - decrement current digit  
     */
    function onPreviousPage() {
        _currentDigit = (_currentDigit - 1 + 10) % 10; // Cycle 0-9 backwards
        _passwordView.setCurrentDigit(_currentDigit);
        return true;
    }
    
    /**
     * Handle select button - add current digit to password
     */
    function onSelect() {
        var isComplete = _passwordView.addDigit(_currentDigit);
        
        if (isComplete) {
            _checkPassword();
        } else {
            _currentDigit = 0; 
            _passwordView.setCurrentDigit(_currentDigit);
        }
        return true;
    }
    
    /**
     * Handle back button - remove last digit or cancel
     */
    function onBack() {
        if (_passwordView.isPasswordComplete() || _passwordView.getEnteredPassword().length() > 0) {
            _passwordView.removeLastDigit();
            return true;
        } else {
            // Cancel password entry
            System.println("Password entry cancelled");
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
    }
    
    /**
     * Get current digit for display
     */
    function getCurrentDigit() {
        return _currentDigit;
    }
    
    /**
     * Check if entered password is correct
     */
    private function _checkPassword() {
        var enteredPassword = _passwordView.getEnteredPassword();
        
        if (enteredPassword.equals(CORRECT_PASSWORD)) {
            System.println("Password correct - allowing app exit");
            
            // Pop password view first
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            
            // Then confirm exit
            _screenManager.confirmExit();
        } else {
            System.println("Incorrect password entered");
            _showIncorrectPasswordMessage();
        }
    }
    
    /**
     * Show incorrect password message and reset
     */
    private function _showIncorrectPasswordMessage() {
        // Clear the password
        _passwordView.clearPassword();
        _currentDigit = 0;
        
        // You could show a toast or brief message here
        // For now, just reset the view
        WatchUi.requestUpdate();
        
        // Optional: Add a brief vibration or tone to indicate wrong password
        // if (Toybox has :Attention) {
        //     Attention.vibrate([new VibeProfile(50, 200)]);
        // }
    }
}