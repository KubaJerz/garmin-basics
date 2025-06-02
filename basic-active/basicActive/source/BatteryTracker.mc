// import Toybox.System;
// import Toybox.FitContributor;

// class BatteryTracker {
//     private var _batteryField;
//     private const BATTERY_FIELD_ID = 0;
    
//     public function initialize(session) {
//         _batteryField = session.createField(
//             "battery_level", 
//             BATTERY_FIELD_ID, 
//             FitContributor.DATA_TYPE_FLOAT, 
//             {
//                 :mesgType => FitContributor.MESG_TYPE_RECORD, 
//                 :units => "%"
//             }
//         );
//     }
    
//     public function updateBatteryLevel() {
//         var stats = System.getSystemStats();
//         if (stats != null && stats.battery != null) {
//             _batteryField.setData(stats.battery);
//         }
//     }
// }


import Toybox.System;
import Toybox.FitContributor;

/**
 * BatteryTracker is responsible for recording battery levels to the FIT file.
 * This class follows the Single Responsibility Principle by focusing only on
 * recording battery data to FIT files, not gathering or storing that data.
 */
class BatteryTracker {
    private var _batteryField;
    private const BATTERY_FIELD_ID = 0;
    
    /**
     * Initialize the battery tracker with a FIT recording session
     * @param session The FIT recording session
     */
    public function initialize(session) {
        _batteryField = session.createField(
            "battery_level", 
            BATTERY_FIELD_ID, 
            FitContributor.DATA_TYPE_FLOAT, 
            {
                :mesgType => FitContributor.MESG_TYPE_RECORD, 
                :units => "%"
            }
        );
    }
    
    /**
     * Record the provided battery level to the FIT file
     * @param batteryLevel The battery level to record
     */
    public function recordBatteryLevel(batteryLevel) {
        if (_batteryField != null && batteryLevel != null) {
            _batteryField.setData(batteryLevel);
        }
    }
}