import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Timer;
import Toybox.System;

/**
 * Main application class that manages the app lifecycle and session rotation.
 * Handles the "when" of data collection (timing/scheduling).
 */
class basicActiveApp extends Application.AppBase {
    private var _dataManager = null;
    private var _rotationTimer = null;
    private var _screenManager;
    private var _mainView = null;  // Store reference to the main view

    // 3 hours in milliseconds
    private const SESSION_DURATION_MS = 3 * 60 * 60 * 1000;

    function initialize() {
        AppBase.initialize();
        _dataManager = new DataCollectionManager();
        
        // Create the main view first
        _mainView = new basicActiveView(_dataManager);
        
        // Pass the main view to the screen manager
        _screenManager = new ScreenManager(_dataManager, _mainView);
    }

    /**
     * Called on application start up
     * Starts data collection and schedules automatic rotation
     */
    function onStart(state as Dictionary?) as Void {
        // Initial view is already shown by getInitialView()
        // No need to call showMainScreen() here
        
        if (_dataManager != null) {
            // Start initial data collection
            _dataManager.startDataCollection();
            
            // Schedule automatic session rotation
            _scheduleNextRotation();
        }
    }

    /**
     * Called when application is exiting
     * Stops data collection and cleans up timers
     */
    function onStop(state as Dictionary?) as Void {
        // Stop rotation timer
        if (_rotationTimer != null) {
            _rotationTimer.stop();
            _rotationTimer = null;
        }
        
        // Stop and save current data collection
        if (_dataManager != null) {
            _dataManager.stopDataCollection();
        }
    }

    /**
     * Schedule the next session rotation
     */
    private function _scheduleNextRotation() {
        if (_rotationTimer == null) {
            _rotationTimer = new Timer.Timer();
        }
        
        // Schedule rotation after SESSION_DURATION_MS
        _rotationTimer.start(method(:_performSessionRotation), SESSION_DURATION_MS, false);
        
        System.println("Next session rotation scheduled in 12 hours");
    }

    /**
     * Perform session rotation - saves current and starts new session
     */
    public function _performSessionRotation() as Void {
        System.println("Performing scheduled session rotation...");
        
        try {
            if (_dataManager != null && _dataManager.isRecording()) {
                // Stop current session (saves it)
                _dataManager.stopDataCollection();
                
                // Small delay to ensure file is written
                var delayTimer = new Timer.Timer();
                delayTimer.start(method(:_startNewSessionAfterDelay), 1000, false);
            }
        } catch (ex) {
            System.println("Error during session rotation: " + ex.getErrorMessage());
            // Try to recover by starting fresh
            _startNewSessionAfterDelay();
        }
    }

    /**
     * Start new session after rotation delay
     */
    public function _startNewSessionAfterDelay() as Void {
        try {
            // Start new session
            _dataManager.startDataCollection();
            
            // Schedule next rotation
            _scheduleNextRotation();
            
            System.println("Session rotation completed successfully: " + System.getClockTime().hour + ":" + System.getClockTime().min + ":" + System.getClockTime().sec);
        } catch (ex) {
            System.println("Failed to start new session after rotation: " + ex.getErrorMessage());
        }
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ _mainView, new basicActiveDelegate(_screenManager) ];
    }
}

function getApp() as basicActiveApp {
    return Application.getApp() as basicActiveApp;
}