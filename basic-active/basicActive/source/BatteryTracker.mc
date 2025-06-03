import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
import Toybox.Lang;

/**
 * BatteryManager handles all battery-related functionality including
 * monitoring battery levels and recording them to FIT files.
 * Follows the same pattern as GPSManager for consistency.
 */
class BatteryManager {
    private var _batteryField = null;
    private var _currentLevel = 0;
    private var _isEnabled = false;
    private var _monitoringTimer = null;
    
    private const BATTERY_FIELD_ID = 0;
    private const BATTERY_UPDATE_INTERVAL = 60000; // Update every 60 seconds
    
    /**
     * Initialize the battery manager
     */
    public function initialize() {
        _updateBatteryLevel();
    }
    
    /**
     * Enable battery monitoring and FIT recording
     * @param session The FIT recording session to write battery data to
     */
    public function enable(session) {
        if (_isEnabled) {
            return; // Already enabled
        }
        
        if (session == null) {
            throw new Lang.InvalidValueException("Session cannot be null");
        }
        
        try {
            // Create FIT field for recording battery data
            _batteryField = session.createField(
                "battery_level", 
                BATTERY_FIELD_ID, 
                FitContributor.DATA_TYPE_FLOAT, 
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD, 
                    :units => "%"
                }
            );
            
            // Start periodic battery monitoring
            _startBatteryMonitoring();
            _isEnabled = true;
            
            // Record initial battery level
            _updateAndRecordBatteryLevel();
            
            System.println("Battery monitoring enabled");
            
        } catch (ex) {
            System.println("Failed to enable battery monitoring: " + ex.getErrorMessage());
            throw ex;
        }
    }
    
    /**
     * Disable battery monitoring and stop recording
     */
    public function disable() {
        if (!_isEnabled) {
            return; // Already disabled
        }
        
        try {
            // Record final battery level before disabling
            if (_batteryField != null) {
                _updateAndRecordBatteryLevel();
            }
            
            // Stop monitoring timer
            if (_monitoringTimer != null) {
                _monitoringTimer.stop();
                _monitoringTimer = null;
            }
            
            _batteryField = null;
            _isEnabled = false;
            
            System.println("Battery monitoring disabled");
            
        } catch (ex) {
            System.println("Error disabling battery monitoring: " + ex.getErrorMessage());
        }
    }
    
    /**
     * Get the current battery level
     * @return Current battery level as percentage (0-100)
     */
    public function getCurrentLevel() {
        return _currentLevel;
    }
    
    /**
     * Check if battery monitoring is currently enabled
     * @return true if enabled, false otherwise
     */
    public function isEnabled() {
        return _isEnabled;
    }
    
    /**
     * Manual update of battery level (useful for immediate updates)
     */
    public function updateLevel() {
        if (_isEnabled) {
            _updateAndRecordBatteryLevel();
        } else {
            _updateBatteryLevel();
        }
    }
    
    /**
     * Clean up battery manager resources
     */
    public function cleanup() {
        disable();
    }
    
    /**
     * Start periodic battery level monitoring
     */
    private function _startBatteryMonitoring() {
        if (_monitoringTimer == null) {
            _monitoringTimer = new Timer.Timer();
            _monitoringTimer.start(method(:_updateAndRecordBatteryLevel), BATTERY_UPDATE_INTERVAL, true);
        }
    }
    
    /**
     * Update battery level from system and record to FIT file
     */
    public function _updateAndRecordBatteryLevel() as Void {
        _updateBatteryLevel();
        
        // Record to FIT file if enabled and field is available
        if (_isEnabled && _batteryField != null && _currentLevel != null) {
            _batteryField.setData(_currentLevel);
        }
    }
    
    /**
     * Update the current battery level from system stats
     */
    private function _updateBatteryLevel() {
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            _currentLevel = stats.battery;
        }
    }
}