import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;
import Toybox.Timer;
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

    private var _batteryTracker = null;
    private var _batteryLevel = 0;

    private var _logTimer = null;
    private const LOG_INTERVAL = 6000; // Log battery every 6 seconds

    private const PREFIX = "BASIC_RECORDER_";

    function initialize() {
        _gpsManager = new GPSManager();
    }

    /**
     * Timer callback that handles periodic data updates
     */
    function _timerCallback() as Void {
        _updateBatteryLevel();
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
            _gpsManager.enable();
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
        _batteryTracker = new BatteryTracker(_session);
        _logTimer = new Timer.Timer();
        _logTimer.start(method(:_timerCallback), LOG_INTERVAL, true);
        
        _session.start();
        _isRecording = true;
        _updateBatteryLevel();
    }

    /**
     * Stop data collection and save the session
     */
    function stopDataCollection() {
        if (!_isRecording || _session == null) {
            return;
        }

        try {
            // Record final battery level before stopping
            _updateBatteryLevel();
            
            // Turn off the GPS
            _gpsManager.disable();

            _session.stop(); // stop the session "pause"
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            _batteryTracker = null;
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }
    
    /**
     * Clean up resources when app stops
     */
    function onStop() {
        // Cleanup battery logging timer
        if (_logTimer != null) {
            _logTimer.stop();
            _logTimer = null;
        }

        // Cleanup GPS manager
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
        _batteryTracker = null;
    }

    /**
     * Update and record current battery level
     */
    private function _updateBatteryLevel() as Void {
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            _batteryLevel = stats.battery;
            // Record to FIT if we're recording
            if (_batteryTracker != null) {
                _batteryTracker.recordBatteryLevel(_batteryLevel);
            }
        }
    }

    /**
     * Get current battery level
     */
    function getBatteryLevel() {
        return _batteryLevel;
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
}