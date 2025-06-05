import Toybox.ActivityRecording;
import Toybox.Sensor;
import Toybox.FitContributor;
import Toybox.System;
import Toybox.Time;
import Toybox.Lang;

/**
 * DataCollectionManager handles the overall data collection process.
 * Uses custom 50Hz sensor recording with numeric FIT fields.
 */
class DataCollectionManager {
    private var _session = null;
    private var _isRecording = false;

    private var _batteryManager = null;
    
    // Custom sensor recording fields - using separate fields for current values
    private var _accelXField = null;
    private var _accelYField = null;
    private var _accelZField = null;
    private var _gyroXField = null;
    private var _gyroYField = null;
    private var _gyroZField = null;
    private var _sampleCountField = null;
    
    private var _isCustomSensorRecording = false;
    private var _sampleCounter = 0;
    
    // Constants
    private const PREFIX = "BASIC_RECORDER_";
    private const ACCEL_X_FIELD_ID = 1;
    private const ACCEL_Y_FIELD_ID = 2;
    private const ACCEL_Z_FIELD_ID = 3;
    private const GYRO_X_FIELD_ID = 4;
    private const GYRO_Y_FIELD_ID = 5;
    private const GYRO_Z_FIELD_ID = 6;
    private const SAMPLE_COUNT_FIELD_ID = 7;
    private const SENSOR_SAMPLE_RATE = 50;

    function initialize() {
        _batteryManager = new BatteryManager();
    }

    /**
     * Start the data collection process with custom 50Hz sensor recording
     */
    function startDataCollection() {
        if (_isRecording) {
            System.println("Already recording... will continue, happened at time: " + Time.now().value().toString());
            return;
        }

        try {
            _createFitSession();
            _setupCustomSensorRecording();
            _startRecording();

        } catch (ex) {
            System.println("Error starting data collection: " + ex.getErrorMessage());
            _handleStartupError(ex);
            throw ex;
        }
    }

    /**
     * Create the FIT recording session (without SensorLogger)
     */
    private function _createFitSession() {
        var sessionName = _generateSessionName();
        
        _session = ActivityRecording.createSession({
            :name => sessionName,
            :sport => Activity.SPORT_GENERIC
            // Note: No sensorLogger here - we're doing custom recording
        });
    }

    /**
     * Setup custom sensor recording at 50Hz with numeric FIT fields
     */
    private function _setupCustomSensorRecording() {
        if (_session == null) {
            throw new Lang.InvalidValueException("Session must be created before setting up sensor recording");
        }

        // Create separate numeric FIT fields for each axis
        _accelXField = _session.createField(
            "accel_x_avg",
            ACCEL_X_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "mg"
            }
        );
        
        _accelYField = _session.createField(
            "accel_y_avg",
            ACCEL_Y_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "mg"
            }
        );
        
        _accelZField = _session.createField(
            "accel_z_avg",
            ACCEL_Z_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "mg"
            }
        );
        
        _gyroXField = _session.createField(
            "gyro_x_avg",
            GYRO_X_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "deg/s"
            }
        );
        
        _gyroYField = _session.createField(
            "gyro_y_avg",
            GYRO_Y_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "deg/s"
            }
        );
        
        _gyroZField = _session.createField(
            "gyro_z_avg",
            GYRO_Z_FIELD_ID,
            FitContributor.DATA_TYPE_FLOAT,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "deg/s"
            }
        );
        
        _sampleCountField = _session.createField(
            "sample_count",
            SAMPLE_COUNT_FIELD_ID,
            FitContributor.DATA_TYPE_UINT16,
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "samples"
            }
        );

        // Check device capabilities
        var maxSampleRate = _getMaxSupportedSampleRate();
        var actualSampleRate = (SENSOR_SAMPLE_RATE <= maxSampleRate) ? SENSOR_SAMPLE_RATE : maxSampleRate;
        
        if (actualSampleRate < SENSOR_SAMPLE_RATE) {
            System.println("Warning: Requested " + SENSOR_SAMPLE_RATE + " Hz, using " + actualSampleRate + " Hz (device limit)");
        }

        // Setup high-frequency sensor data listener
        var options = {
            :period => 1, // 1 second of data per callback
            :accelerometer => {
                :enabled => true,
                :sampleRate => actualSampleRate
            },
            :gyroscope => {
                :enabled => true,
                :sampleRate => actualSampleRate
            }
        };

        Sensor.registerSensorDataListener(method(:onSensorData), options);
        _isCustomSensorRecording = true;
        _sampleCounter = 0;
        
        System.println("Custom sensor recording initialized at " + actualSampleRate + " Hz");
    }

    /**
     * Handle high-frequency sensor data and record averaged values to FIT fields
     */
    public function onSensorData(sensorData as Sensor.SensorData) as Void {
        if (!_isRecording || _accelXField == null) {
            return;
        }

        try {
            _sampleCounter++;
            
            // Process accelerometer data - calculate averages
            if (sensorData.accelerometerData != null) {
                var accelData = sensorData.accelerometerData;
                
                var avgX = _calculateAverage(accelData.x);
                var avgY = _calculateAverage(accelData.y);
                var avgZ = _calculateAverage(accelData.z);
                
                _accelXField.setData(avgX);
                _accelYField.setData(avgY);
                _accelZField.setData(avgZ);
            }

            // Process gyroscope data - calculate averages
            if (sensorData.gyroscopeData != null) {
                var gyroData = sensorData.gyroscopeData;
                
                var avgX = _calculateAverage(gyroData.x);
                var avgY = _calculateAverage(gyroData.y);
                var avgZ = _calculateAverage(gyroData.z);
                
                _gyroXField.setData(avgX);
                _gyroYField.setData(avgY);
                _gyroZField.setData(avgZ);
            }
            
            // Record how many samples we got in this callback
            var sampleCount = (sensorData.accelerometerData != null) ? 
                              sensorData.accelerometerData.x.size() : 0;
            _sampleCountField.setData(sampleCount);

        } catch (ex) {
            System.println("Error recording sensor data: " + ex.getErrorMessage());
        }
    }

    /**
     * Calculate average of an array of sensor values
     */
    private function _calculateAverage(dataArray as Array) as Float {
        if (dataArray == null || dataArray.size() == 0) {
            return 0.0;
        }
        
        var sum = 0.0;
        for (var i = 0; i < dataArray.size(); i++) {
            sum += dataArray[i];
        }
        
        return sum / dataArray.size();
    }

    /**
     * Get the maximum supported sample rate for sensors
     */
    private function _getMaxSupportedSampleRate() as Number {
        try {
            // Check if the device supports the sensor max sample rate API
            if (Toybox.Sensor has :getMaxSampleRate) {
                return Sensor.getMaxSampleRate();
            } else {
                // Fallback to conservative rate for older devices
                return 25;
            }
        } catch (ex) {
            System.println("Error getting max sample rate: " + ex.getErrorMessage());
            return 25; // Conservative fallback
        }
    }

    /**
     * Generate a unique session name with timestamp
     */
    private function _generateSessionName() as String {
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
    private function _startRecording() as Void {
        // Start the FIT session first
        _session.start();
        _isRecording = true;
        
        // Enable battery monitoring
        _batteryManager.enable(_session);
        

        System.println("Data collection started with custom 50Hz sensors, name: " + _generateSessionName());
    }

    /**
     * Stop custom sensor recording
     */
    private function _stopCustomSensorRecording() as Void {
        if (_isCustomSensorRecording) {
            try {
                Sensor.unregisterSensorDataListener();
                _isCustomSensorRecording = false;
                System.println("Custom sensor recording stopped. Total samples processed: " + _sampleCounter);
            } catch (ex) {
                System.println("Error stopping custom sensor recording: " + ex.getErrorMessage());
            }
        }
        
        // Clear field references
        _accelXField = null;
        _accelYField = null;
        _accelZField = null;
        _gyroXField = null;
        _gyroYField = null;
        _gyroZField = null;
        _sampleCountField = null;
    }

    /**
     * Stop data collection and save the session
     */
    function stopDataCollection() as Void {
        if (!_isRecording || _session == null) {
            return;
        }

        try {
            // Stop custom sensor recording first
            _stopCustomSensorRecording();
            
            // Disable battery monitoring (records final level)
            _batteryManager.disable();
            

            _session.stop(); // stop the session "pause"
            _session.save(); // end the session and save FIT file
            _isRecording = false;
            
            System.println("Data collection with 50Hz sensors stopped and saved");
            
        } catch (ex) {
            System.println("Error stopping data collection: " + ex.getErrorMessage());
        }
    }
    
    /**
     * Clean up resources when app stops
     */
    function onStop() as Void {
        // Stop custom sensor recording
        _stopCustomSensorRecording();
        
        // Cleanup managers
        if (_batteryManager != null) {
            _batteryManager.cleanup();
        }
        

        // Make sure we stop data collection
        stopDataCollection();
    }

    /**
     * Handle errors during startup
     */
    private function _handleStartupError(exception) as Void {
        // Clean error handling 
        _isRecording = false;
        _session = null;
        
        // Stop any custom sensor recording
        _stopCustomSensorRecording();
        
        // Make sure managers are cleaned up
        if (_batteryManager != null) {
            _batteryManager.cleanup();
        }

    }


    /**
     * Update battery monitoring (called by view timer)
     */
    function updateBatteryMonitoring() as Void {
        if (_batteryManager != null) {
            _batteryManager.updateLevel();
        }
    }

    /**
     * Get current battery level
     */
    function getBatteryLevel() as Number {
        return _batteryManager != null ? _batteryManager.getCurrentLevel() : 0;
    }

    /**
     * Check if currently recording data
     */
    function isRecording() as Boolean {
        return _isRecording;
    }
    
    /**
     * Get battery monitoring status
     */
    function isBatteryMonitoringEnabled() as Boolean {
        return _batteryManager != null && _batteryManager.isEnabled();
    }
    
    /**
     * Get custom sensor recording status
     */
    function isCustomSensorRecording() as Boolean {
        return _isCustomSensorRecording;
    }
}