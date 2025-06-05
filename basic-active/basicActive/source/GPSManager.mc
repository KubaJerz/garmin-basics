// import Toybox.Position;
// import Toybox.Timer;
// import Toybox.System;

/**
 * Handles all GPS-related functionality including status monitoring
 * and configuration management.
 */
class GPSManager {
    private var _enabled = false;
    private var _status = "No GPS data";
        
    public function initialize() {
    }
    
//     public function enable() {
//         if (_enabled) {
//             return;
//         }

//         try {
//             var gpsOptions = {
//                 :acquisitionType => Position.LOCATION_CONTINUOUS,
//                 :mode => Position.POSITIONING_MODE_NORMAL
//             };

//             if (_supportsMultiBandGPS()) {
//                 gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5;
//             } else if (_supportsMultiGNSS()) {
//                 gpsOptions[:configuration] = Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1;
//             }

//             Position.enableLocationEvents(gpsOptions, method(:onGPSUpdate));
//             _enabled = true;
//             _userWantsGPS = true;
            
//             // Start status monitoring only when GPS is enabled
//             _startStatusMonitoring();
            
//             System.println("GPS tracking enabled");
            
//         } catch (ex) {
//             System.println("Failed to enable GPS: "+ ex.getErrorMessage());
//             throw ex;
//         }
//     }
    
//     public function disable() {
//         try {
//             // Stop status monitoring FIRST
//             _stopStatusMonitoring();
            
//             // Disable GPS tracking
//             Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            
//             _enabled = false;
//             _userWantsGPS = false;
//             _status = "GPS disabled";
            
//             System.println("GPS tracking disabled completely");
            
//         } catch (ex) {
//             System.println("Error disabling GPS: " + ex.getErrorMessage());
//         }
//     }

//     public function getStatus() {
//         return _status;
//     }
    
//     public function checkStatus() as Void {
//         // Only check status if GPS is supposed to be enabled
//         if (!_enabled || !_userWantsGPS) {
//             System.println("we enter the right spot");
//             _status = "GPS disabled";
//             return;
//         }
//         System.println("we shoudl never get here");
//         var locationInfo = Position.getInfo();
//         if (locationInfo != null) {
//             onGPSUpdate(locationInfo);
//         } else {
//             _status = "GPS: No signal";
//         }
//     }
    
    public function updateStatus() as Void {
        if (_enabled) {
            checkStatus();
        }
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
    
//     /**
//      * Stop monitoring GPS status
//      */
//     private function _stopStatusMonitoring() {
//         if (_statusTimer != null) {
//             _statusTimer.stop();
//             _statusTimer = null;
//         }
//     }
    
    /**
     * Clean up GPS resources and timers
     */
    public function cleanup() {
        disable();
    }

//     /**
//      * Handle GPS location updates and update status
//      * This method is called by the watch when there is a gps update
//      */
//     public function onGPSUpdate(info as Position.Info) as Void {
//         // Update GPS status based on quality
//         switch (info.accuracy) {
//             case Position.QUALITY_GOOD:
//                 _status = "GPS: Good signal";
//                 break;
//             case Position.QUALITY_USABLE:
//                 _status = "GPS: Usable signal";
//                 break;
//             case Position.QUALITY_POOR:
//                 _status = "GPS: Poor signal";
//                 break;
//             case Position.QUALITY_LAST_KNOWN:
//                 _status = "GPS: Using last known position";
//                 break;
//             default:
//                 _status = "GPS: Searching...";
//         }
//     }
    
//     // /**
//     //  * Clean up GPS resources and timers
//     //  */
//     // public function cleanup() {
//     //     if (_statusTimer != null) {
//     //         _statusTimer.stop();
//     //         _statusTimer = null;
//     //     }
//     //     disable();
//     // }
    
//     // // /**
//     //  * Start monitoring GPS status with periodic checks
//     //  */
//     // private function _startStatusMonitoring() {
//     //     if (_statusTimer == null) {
//     //         _statusTimer = new Timer.Timer();
//     //         _statusTimer.start(method(:checkStatus), GPS_STATUS_CHECK_INTERVAL, true);
//     //     }
//     // }

//     private function _supportsMultiBandGPS() {
//         return (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5) &&
//                (Position has :hasConfigurationSupport) &&
//                Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1_L5);
//     }

//     private function _supportsMultiGNSS() {
//         return (Position has :CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1) &&
//                (Position has :hasConfigurationSupport) &&
//                Position.hasConfigurationSupport(Position.CONFIGURATION_GPS_GLONASS_GALILEO_BEIDOU_L1);
//     }
// }