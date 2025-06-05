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
    private const TIMER_INTERVAL = 1000; // 1 second base interval

    // Update intervals (in seconds)
    private const BATTERY_DISPLAY_INTERVAL = 10;
    private const BATTERY_MONITOR_INTERVAL = 60;
    
    private var _secondsCounter = 0;

    function initialize(dataManager) {
        View.initialize();
        _dataManager = dataManager;
        if (_timer == null) {
            _timer = new Timer.Timer();
        }
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
        _timeField = View.findDrawableById("timeText");
        _batteryField = View.findDrawableById("batteryText");


        _timer.start(method(:updateAll), TIMER_INTERVAL, true);


        _updateBatteryDisplay();
        updateAll();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        _drawGPSStatusDot(dc);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    /**
     * Master update function called every second
     * Delegates to appropriate update methods based on intervals
     */
    public function updateAll() as Void {
        _secondsCounter++;
        
        // Always update time (every second)
        _updateTimeDisplay();
        
        // Update battery display every 10 seconds
        if (_secondsCounter % BATTERY_DISPLAY_INTERVAL == 0) {
            _updateBatteryDisplay();
        }
        
        
        // Update battery monitoring every 60 seconds
        if (_secondsCounter % BATTERY_MONITOR_INTERVAL == 0) {
            if (_dataManager != null) {
                _dataManager.updateBatteryMonitoring();
            }
        }
        
        // Reset counter to prevent overflow (every 12 hours)
        if (_secondsCounter >= 43200) {
            _secondsCounter = 0;
        }
        
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

        var dotColor = Graphics.COLOR_BLACK;
        var centerX = dc.getWidth() / GPS_DOT_X_RATIO;
        var centerY = dc.getHeight() / GPS_DOT_Y_RATIO;
        
        dc.setColor(dotColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(centerX, centerY, GPS_DOT_SIZE);
    }




}
