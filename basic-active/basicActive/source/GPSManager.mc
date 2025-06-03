import Toybox.Position;
import Toybox.Timer;
import Toybox.System;

/**
 * Handles all GPS-related functionality including status monitoring
 * and configuration management.
 */
class GPSManager {
    private var _enabled = false;
    private var _status = "No GPS data";
    private var _statusTimer = null;
    
    private const GPS_STATUS_CHECK_INTERVAL = 6000;
    
    public function initialize() {
        _startStatusMonitoring();
    }
    
    public function enable() {
        if (_enabled) {
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
            _enabled = true;
            System.println("GPS tracking enabled");
            
        } catch (ex) {
            System.println("Failed to enable GPS: "+ ex.getErrorMessage());
            throw ex;
        }
    }
    
    public function disable() {
        if (!_enabled) {
            return; // Already off so will return
        }

        try {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            _enabled = false;
            _status = "GPS Disabled";
            System.println("GPS tracking disabled");
            
        } catch (ex) {
            System.println("Error disabling GPS: " + ex.getErrorMessage());
        }
    }
    
    public function getStatus() {
        return _status;
    }
    
    // /**
    //  * Check GPS status by getting current location info
    //  * This method is called every GPS_STATUS_CHECK_INTERVAL to update color of the dot
    //  */
    public function checkStatus() as Void {
        var locationInfo = Position.getInfo();
        if (locationInfo != null) {
            onGPSUpdate(locationInfo);
        } else {
            _status = "GPS: No signal";
        }
    }
    
    /**
     * Handle GPS location updates and update status
     * This method is called by the watch when there is a gps update
     */
    public function onGPSUpdate(info as Position.Info) as Void {
        // Update GPS status based on quality
        switch (info.accuracy) {
            case Position.QUALITY_GOOD:
                _status = "GPS: Good signal";
                break;
            case Position.QUALITY_USABLE:
                _status = "GPS: Usable signal";
                break;
            case Position.QUALITY_POOR:
                _status = "GPS: Poor signal";
                break;
            case Position.QUALITY_LAST_KNOWN:
                _status = "GPS: Using last known position";
                break;
            default:
                _status = "GPS: Searching...";
        }
    }
    
    /**
     * Clean up GPS resources and timers
     */
    public function cleanup() {
        if (_statusTimer != null) {
            _statusTimer.stop();
            _statusTimer = null;
        }
        disable();
    }
    
    /**
     * Start monitoring GPS status with periodic checks
     */
    private function _startStatusMonitoring() {
        if (_statusTimer == null) {
            _statusTimer = new Timer.Timer();
            _statusTimer.start(method(:checkStatus), GPS_STATUS_CHECK_INTERVAL, true);
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