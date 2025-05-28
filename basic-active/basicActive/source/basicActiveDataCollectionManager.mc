import Toybox.ActivityRecording;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.Time;

class DataCollectionManager {
    private var _logger = null;
    private var _session = null;
    private var _isRecording = false;
    private const PREFIX = "BASIC_RECORDER_";

    function initialize() {
    }

    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happend at time: " + Time.now().value().toString());
            return;
        }

        try {
            // make sensor logger with proper sensors
            _logger = new SensorLogging.SensorLogger({
            :enableAccelerometer => true
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

}