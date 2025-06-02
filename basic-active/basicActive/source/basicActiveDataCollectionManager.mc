import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;
import Toybox.Position;

class DataCollectionManager {
    private var _logger = null;
    private var _session = null;
    private var _isRecording = false;
    private var _gpsEnabled = false;
    private const PREFIX = "BASIC_RECORDER_";
    private var _gpsStatus = "No GPS data";

    function initialize() {
    }

    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happend at time: " + Time.now().value().toString());
            return;
        }

        try {

            
            _enableGPS();    //Turn on the GPS

            // make sensor logger with proper sensors
            _logger = new SensorLogging.SensorLogger({
                :accelerometer => {:enabled => true}, //, :sampleRate => 10},
                :gyroscope => {:enabled => true} //, :sampleRate => 10}
            });

            
            var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );    // make a unique name for our FIT session

            var timeString = Lang.format("$1$_$2$_$3$_$4$_$5$", [
                dateInfo.hour,
                dateInfo.min.format("%02d"),
                dateInfo.month,
                dateInfo.day,
                dateInfo.year
            ]);
            var sessionName = PREFIX + timeString;

            // make the FIT session
            _session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => Activity.SPORT_GENERIC,
                :sensorLogger => _logger

            });
            
            _batteryTracker = new BatteryTracker(_session);      // init battery tracking AFTER session has been init


            _session.start();             //start the FIT session
            _isRecording = true;

            updateBatteryTracking();        // Log start battery level
        } catch (ex) {
            System.println("Error starting data collection: " + ex.getErrorMessage());
            _handleStartupError(ex);
        }
    }

        function stopDataCollection() {
        if (!_isRecording || _session == null) {
            return;
        }

        try {
            _disableGPS();         //Turn off the GPS

            // Log final battery level before stopping
            updateBatteryTracking();

            _session.stop(); // "pause" the session 
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }

    private function _handleStartupError(exception) {
        // error handling 
        _isRecording = false;
        _logger = null;
        _session = null;
        _gpsEnabled = false;
        _batteryTracker = null;
        _gpsStatus = "No GPS data";
    }

    function updateBatteryTracking() {
        if (_batteryTracker != null && _isRecording) {
            _batteryTracker.updateBatteryLevel();
        }
    }

    function isRecording() {
        return _isRecording;
    }
    

    private function _enableGPS() {
        if (_gpsEnabled) {
            return ; //Return back since already one
        }

        try {
            // Configure GPS for optimal data collection
            var gpsOptions = {
                :acquisitionType => Position.LOCATION_CONTINUOUS,
                :mode => Position.POSITIONING_MODE_NORMAL
            };

            // check which GPS mode is aviailabe and use the best one
            if (_supportsMultiBandGPS()) {
                gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
            } else if (_supportsMultiGNSS()) {
                gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
            }

            Position.enableLocationEvents(gpsOptions, method(:onGPSUpdate));
            _gpsEnabled = true;
            System.println("GPS tracking enabled");
            
        } catch (ex) {
            System.println("Failed to enable GPS: "+ ex.getErrorMessage() );
            throw ex;
        }

    }

    private function _disableGPS(){
        if (!_gpsEnabled) {
            return; // already off so will return
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

    function getGPSStatus() {
        return _gpsStatus;
    }

}