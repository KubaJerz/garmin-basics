import Toybox.System;
import Toybox.FitContributor;

class BatteryTracker {
    private var _batteryField;
    private const BATTERY_FIELD_ID = 0;
    
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
    
    public function updateBatteryLevel() {
        var stats = System.getSystemStats();
        if (stats != null && stats.battery != null) {
            _batteryField.setData(stats.battery);
        }
    }
}