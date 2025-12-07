import Toybox.Sensor;
import Toybox.FitContributor;
import Toybox.System;
import Toybox.Lang;

/**
 * HeartBeatIntervalManager handles beat-to-beat heart rate interval data.
 * 
 * Stores up to 5 raw R-R intervals per second for HRV research.
 * Each interval is stored in its own FIT field to preserve raw data.
 * 
 * Typical intervals per second based on heart rate:
 * - 60 BPM = ~1 interval/sec
 * - 120 BPM = ~2 intervals/sec  
 * - 180 BPM = ~3 intervals/sec
 * 
 * 5 fields covers most cases including high heart rates.
 */
class HeartBeatIntervalManager {
    // FIT field IDs (must be unique within your app)
    // Using IDs 3-8 (assuming 0-2 are used by other managers)
    private const HBI_BASE_FIELD_ID = 3;
    private const HBI_COUNT_FIELD_ID = 8;
    private const MAX_INTERVALS = 5;
    
    // Array of FIT fields for raw intervals
    private var _hbiFields = null;
    // Field to store count of valid intervals this second
    private var _hbiCountField = null;
    
    private var _isEnabled = false;
    private var _lastIntervals = null;
    
    /**
     * Initialize the manager
     */
    public function initialize() {
        _hbiFields = new [MAX_INTERVALS];
        _lastIntervals = [];
    }
    
    /**
     * Enable heart beat interval monitoring
     * Creates 5 FIT fields for raw intervals + 1 count field
     * @param session The FIT recording session
     */
    public function enable(session) {
        if (_isEnabled) {
            System.println("HBI: Already enabled");
            return;
        }
        
        if (session == null) {
            throw new Lang.InvalidValueException("Session cannot be null");
        }
        
        try {
            // Create 5 fields for raw intervals (hbi_0 through hbi_4)
            for (var i = 0; i < MAX_INTERVALS; i++) {
                _hbiFields[i] = session.createField(
                    "hbi_" + i,
                    HBI_BASE_FIELD_ID + i,
                    FitContributor.DATA_TYPE_UINT16,
                    {
                        :mesgType => FitContributor.MESG_TYPE_RECORD,
                        :units => "ms"
                    }
                );
                _hbiFields[i].setData(0);
            }
            
            // Create field to store count of valid intervals
            _hbiCountField = session.createField(
                "hbi_count",
                HBI_COUNT_FIELD_ID,
                FitContributor.DATA_TYPE_UINT8,
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD,
                    :units => ""
                }
            );
            _hbiCountField.setData(0);
            
            // Register for heart beat interval data
            var options = {:period => 1,:enabledheartBeatIntervals => true};
            
            Sensor.registerSensorDataListener(method(:onSensorData), options);
            
            _isEnabled = true;
            System.println("HBI: Enabled with " + MAX_INTERVALS + " interval fields");
            
        } catch (ex) {
            System.println("HBI: Failed to enable - " + ex.getErrorMessage());
            _cleanup();
            throw ex;
        }
    }
    
    /**
     * Callback when sensor data is received
     * Stores all raw intervals in separate FIT fields
     */
    public function onSensorData(sensorData as Sensor.SensorData) as Void {
        if (!_isEnabled || sensorData == null) {
            return;
        }
        
        var hrData = sensorData.heartRateData;
        if (hrData == null) {
            _writeEmptyRecord();
            return;
        }
        
        var intervals = hrData.heartBeatIntervals;
        if (intervals == null || intervals.size() == 0) {
            _writeEmptyRecord();
            return;
        }
        
        // Store for external access
        _lastIntervals = intervals;
        
        // Write each interval to its own field
        var count = intervals.size();
        if (count > MAX_INTERVALS) {
            count = MAX_INTERVALS;
            System.println("HBI: Warning - received " + intervals.size() + 
                          " intervals, only storing " + MAX_INTERVALS);
        }

        System.println("HBI: Writing " + intervals.toString());
        
        // Write intervals to fields
        for (var i = 0; i < MAX_INTERVALS; i++) {
            if (i < count) {
                _hbiFields[i].setData(intervals[i]);
            } else {
                _hbiFields[i].setData(0);
            }
        }
        
        // Write count of valid intervals
        _hbiCountField.setData(count);
    }
    
    /**
     * Write zeros when no data is available
     */
    private function _writeEmptyRecord() {
        for (var i = 0; i < MAX_INTERVALS; i++) {
            if (_hbiFields[i] != null) {
                _hbiFields[i].setData(0);
            }
        }
        if (_hbiCountField != null) {
            _hbiCountField.setData(0);
        }
    }
    
    /**
     * Disable heart beat interval monitoring
     */
    public function disable() {
        if (!_isEnabled) {
            return;
        }
        
        try {
            Sensor.unregisterSensorDataListener();
            System.println("HBI: Disabled");
        } catch (ex) {
            System.println("HBI: Error during disable - " + ex.getErrorMessage());
        }
        
        _cleanup();
    }
    
    /**
     * Get the last received intervals array
     */
    public function getLastIntervals() {
        return _lastIntervals;
    }
    
    /**
     * Check if monitoring is enabled
     */
    public function isEnabled() {
        return _isEnabled;
    }
    
    /**
     * Clean up resources
     */
    public function cleanup() {
        disable();
    }
    
    /**
     * Internal cleanup helper
     */
    private function _cleanup() {
        for (var i = 0; i < MAX_INTERVALS; i++) {
            _hbiFields[i] = null;
        }
        _hbiCountField = null;
        _isEnabled = false;
        _lastIntervals = [];
    }
}