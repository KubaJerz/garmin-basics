import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;
import Toybox.Position;
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

    private var _gpsEnabled = false;
    private var _gpsStatus = "No GPS data";

    private var _batteryTracker = null;
    private var _batteryLevel = 0;

    private var _logTimer = null;
    private const LOG_INTERVAL = 6000; // Log battery every 6 seconds

    private const PREFIX = "BASIC_RECORDER_";


    function initialize() {
    }

    function _timerCallback() as Void{
        _updateBatteryLevel();
        _checkGPSStatus();
    }

    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happened at time: " + Time.now().value().toString());
            return;
        }

        try {

            _enableGPS();
            _initializeSensorLogger();
            _createFitSession();
            _startRecording();

        } catch (ex) {
            System.println("Error starting data collection: " + ex.getErrorMessage());
            _handleStartupError(ex);
        }
    }


    private function _initializeSensorLogger() {
        _logger = new SensorLogging.SensorLogger({
            :accelerometer => {:enabled => true},
            :gyroscope => {:enabled => true}
        });
    }

    private function _createFitSession() {
        var sessionName = _generateSessionName();
        
        _session = ActivityRecording.createSession({
            :name => sessionName,
            :sport => Activity.SPORT_GENERIC,
            :sensorLogger => _logger
        });
    }

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

    private function _startRecording() {
        _batteryTracker = new BatteryTracker(_session);
        _logTimer = new Timer.Timer();
        _logTimer.start(method(:_timerCallback), LOG_INTERVAL, true);
        
        _session.start();
        _isRecording = true;
        _updateBatteryLevel();
    }


    function stopDataCollection() {
        if (!_isRecording || _session == null) {
            return;
        }

        try {
            // Record final battery level before stopping
            _updateBatteryLevel();
            
            // Turn off the GPS
            _disableGPS();

            _session.stop(); // stop the session "pause"
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            _batteryTracker = null;
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }
    

    function onStop() {
        // Cleanup when app stops
        if (_timerCallback() != null) {
            _logTimer.stop();
            _logTimer = null;
        }

        // Make sure we stop data collection
        stopDataCollection();
    }

    private function _handleStartupError(exception) {
        // Clean error handling 
        _isRecording = false;
        _logger = null;
        _session = null;
        _batteryTracker = null;
    }

    private function _updateBatteryLevel() as Void{
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            _batteryLevel = stats.battery;
            // Record to FIT if we're recording
            _batteryTracker.recordBatteryLevel(_batteryLevel);
        }
    }

    private function _checkGPSStatus() as Void {
        // Get current GPS/location status without enabling full GPS
        var locationInfo = Position.getInfo();
        if (locationInfo != null) {
            onGPSUpdate(locationInfo);
        } else {
            _gpsStatus = "GPS: No signal";
        }
    }


    private function _enableGPS() {
        if (_gpsEnabled) {
            return; // Return back since already on
        }

        try {
            // Configure GPS for optimal data collection
            var gpsOptions = {
                :acquisitionType => Position.LOCATION_CONTINUOUS,
                :mode => Position.POSITIONING_MODE_NORMAL
            };

            // Check which GPS mode is available and use the best one
            if (_supportsMultiBandGPS()) {
                gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
            } else if (_supportsMultiGNSS()) {
                gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
            }

            Position.enableLocationEvents(gpsOptions, method(:onGPSUpdate));
            _gpsEnabled = true;
            System.println("GPS tracking enabled");
            
        } catch (ex) {
            System.println("Failed to enable GPS: "+ ex.getErrorMessage());
            throw ex;
        }
    }

    private function _disableGPS() {
        if (!_gpsEnabled) {
            return; // Already off so will return
        }

        try {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            _gpsEnabled = false;
            _gpsStatus = "GPS Disabled";
            System.println("GPS tracking disabled");
            
        } catch (ex) {
            System.println("Error disabling GPS: " + ex.getErrorMessage());
        }
    }

    private function _supportsMultiBandGPS() {
        return (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) &&
               (Position has :hasConfigurationSupport) &&
               Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5);
    }

    private function _supportsMultiGNSS() {
        return (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) &&
               (Position has :hasConfigurationSupport) &&
               Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1);
    }

    function onGPSUpdate(info as Position.Info) as Void {
        // Update GPS status based on quality
        switch (info.accuracy) {
            case Position.QUALITY_GOOD:
                _gpsStatus = "GPS: Good signal";
                break;
            case Position.QUALITY_USABLE:
                _gpsStatus = "GPS: Usable signal";
                break;
            case Position.QUALITY_POOR:
                _gpsStatus = "GPS: Poor signal";
                break;
            case Position.QUALITY_LAST_KNOWN:
                _gpsStatus = "GPS: Using last known position";
                break;
            default:
                _gpsStatus = "GPS: Searching...";
        }
    }

    function getBatteryLevel() {
        return _batteryLevel;
    }


    function isRecording() {
        return _isRecording;
    }

    function getGPSStatus() {
        return _gpsStatus;
    }
}