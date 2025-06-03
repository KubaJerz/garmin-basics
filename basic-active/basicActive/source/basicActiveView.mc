import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

class basicActiveView extends WatchUi.View {
    // UI Layout constants
    private const GPS_DOT_X_RATIO = 5;
    private const GPS_DOT_Y_RATIO = 5;
    private const GPS_DOT_SIZE = 6;

    private var _timeField = null;
    private var _batteryField = null;
    
    private var _timer = null;
    private var _dataManager = null;
    private const TIMER_INTERVAL = 1000;

    private const BATTERY_DISPLAY_INTERVAL = 10;        // Refresh battery display every 10 seconds
    private var _timerCounter = 0;

    function initialize(dataManager) {
        View.initialize();
        _dataManager = dataManager;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));

    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        _timeField = View.findDrawableById("timeText");
        _batteryField = View.findDrawableById("batteryText");


        if (_timer == null){
            _timer = new Timer.Timer();
            _timer.start(method(:updateUI), TIMER_INTERVAL, true); // repeat = true
        }

        _updateBatteryDisplay();
        updateUI();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        _drawGPSStatusDot(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    function updateUI() as Void {

        _timerCounter++;
        
        // Update time every time
        _updateTimeDisplay();
        
        // Update battery display less frequently to optimize performance
        if (_timerCounter >= BATTERY_DISPLAY_INTERVAL) {
            _timerCounter = 0;
            _updateBatteryDisplay();
            
        }
        
        // Request UI refresh
        WatchUi.requestUpdate();
    }

    private function _updateTimeDisplay() {
        if (_timeField != null) {
            var dateInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);

            var timeString = Lang.format("$1$:$2$ $3$/$4$/$5$", [
                dateInfo.hour,
                dateInfo.min.format("%02d"),
                dateInfo.month,
                dateInfo.day,
                dateInfo.year
            ]);
            _timeField.setText(timeString);
        }
    }

    private function _updateBatteryDisplay() {
        if (_dataManager != null && _batteryField != null) {
            // Only get current battery level - no updates triggered
            var batteryLevel = _dataManager.getBatteryLevel();
            _batteryField.setText(batteryLevel.format("%d") + "%");
        }
    }

    private function _drawGPSStatusDot(dc) {
        if (_dataManager == null) {
            return;
        }

        var gpsStatus = _dataManager.getGPSStatus();
        var dotColor = _getGPSColor(gpsStatus);
        var centerX = dc.getWidth() / GPS_DOT_X_RATIO;
        var centerY = dc.getHeight() / GPS_DOT_Y_RATIO;
        
        dc.setColor(dotColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, GPS_DOT_SIZE);
    }



    private function _getGPSColor(gpsStatus) {
        if (gpsStatus.find("Good") != null) {
            return Graphics.COLOR_GREEN;      // Good signal
        } else if (gpsStatus.find("Usable") != null) {
            return Graphics.COLOR_YELLOW;     // Usable signal  
        } else if (gpsStatus.find("Poor") != null) {
            return Graphics.COLOR_YELLOW;     // Poor signal
        } else if (gpsStatus.find("Searching") != null) {
            return Graphics.COLOR_ORANGE;     // Searching (orange-ish)
        } else {
            return Graphics.COLOR_RED;        // No GPS/Error
        }
    }

}
