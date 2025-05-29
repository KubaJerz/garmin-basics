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

    function initialize() {
    }

    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happend at time: " + Time.now().value().toString());
            return;
        }

        try {

            //Turn on the GPS
            _enableGPS();

            // make sensor logger with proper sensors
            _logger = new SensorLogging.SensorLogger({
                :accelerometer => {:enabled => true}, //, :sampleRate => 10},
                :gyroscope => {:enabled => true} //, :sampleRate => 10}
            });

            // make a unique name for our FIT session
            var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );

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

            //start the FIT session
            _session.start();
            _isRecording = true;
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
            //Turn off the GPS
            _disableGPS();


            _session.stop(); // stop the session "pause"
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }

    private function _handleStartupError(exception) {
        // clean error handling 
        _isRecording = false;
        _logger = null;
        _session = null;
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

            Position.enableLocationEvents(gpsOptions, null);
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

}