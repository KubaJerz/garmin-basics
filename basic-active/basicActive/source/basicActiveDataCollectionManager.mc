import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;
import Toybox.Lang;

/**
 * DataCollectionManager handles the overall data collection process.
 * It coordinates sensors, GPS, and battery monitoring, following the 
 * Facade pattern by providing a simplified interface to these subsystems.
 */
class DataCollectionManager {
    private var _logger = null;
    private var _session = null;
    private var _isRecording = false;

    private var _gpsManager = null;
    private var _batteryManager = null;

    private const PREFIX = "BASIC_RECORDER_";

    function initialize() {
        _gpsManager = new GPSManager();
        _batteryManager = new BatteryManager();
    }

    /**
     * Start the data collection process
     */
    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happened at time: " + Time.now().value().toString());
            return;
        }

        try {
            _initializeSensorLogger();
            _createFitSession();
            _startRecording();

        } catch (ex) {
            System.println("Error starting data collection: " + ex.getErrorMessage());
            _handleStartupError(ex);
        }
    }

    /**
     * Initialize the sensor logger with accelerometer and gyroscope
     */
    private function _initializeSensorLogger() {
        _logger = new SensorLogging.SensorLogger({
            :accelerometer => {:enabled => true},
            :gyroscope => {:enabled => true}
        });
    }

    /**
     * Create the FIT recording session
     */
    private function _createFitSession() {
        var sessionName = _generateSessionName();
        
        _session = ActivityRecording.createSession({
            :name => sessionName,
            :sport => Activity.SPORT_GENERIC,
            :sensorLogger => _logger
        });
    }

    /**
     * Generate a unique session name with timestamp
     */
    private function _generateSessionName() {
        var dateInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var timeString = Lang.format("$1$_$2$_$3$_$4$_$5$", [
            dateInfo.hour,
            dateInfo.min.format("%02d"),
            dateInfo.month,
            dateInfo.day,
            dateInfo.year
        ]);
        return PREFIX + timeString;
    }

    /**
     * Start the recording session and initialize tracking
     */
    private function _startRecording() {
        // Start the FIT session first
        _session.start();
        _isRecording = true;
        
        // Enable battery monitoring
        _batteryManager.enable(_session);
        // Enable gps monitoring
        _gpsManager.enable();
        

        System.println("Data collection started successfully");
    }

    /**
     * Stop data collection and save the session
     */
    function stopDataCollection() {
        if (!_isRecording || _session == null) {
            return;
        }

        try {
            // Disable battery monitoring (records final level)
            _batteryManager.disable();
            
            // Turn off the GPS
            _gpsManager.disable();

            _session.stop(); // stop the session "pause"
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            
            System.println("Data collection stopped and saved");
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }
    
    /**
     * Clean up resources when app stops
     */
    function onStop() {
        // Cleanup managers
        if (_batteryManager != null) {
            _batteryManager.cleanup();
        }
        
        if (_gpsManager != null) {
            _gpsManager.cleanup();
        }

        // Make sure we stop data collection
        stopDataCollection();
    }

    /**
     * Handle errors during startup
     */
    private function _handleStartupError(exception) {
        // Clean error handling 
        _isRecording = false;
        _logger = null;
        _session = null;
        
        // Make sure managers are cleaned up
        if (_batteryManager != null) {
            _batteryManager.cleanup();
        }
        if (_gpsManager != null) {
            _gpsManager.cleanup();
        }
    }

    /**
     * Get current battery level
     */
    function getBatteryLevel() {
        return _batteryManager != null ? _batteryManager.getCurrentLevel() : 0;
    }

    /**
     * Check if currently recording data
     */
    function isRecording() {
        return _isRecording;
    }

    /**
     * Get current GPS status
     */
    function getGPSStatus() {
        return _gpsManager != null ? _gpsManager.getStatus() : "GPS Manager not initialized";
    }
    
    /**
     * Get battery monitoring status
     */
    function isBatteryMonitoringEnabled() {
        return _batteryManager != null && _batteryManager.isEnabled();
    }
}