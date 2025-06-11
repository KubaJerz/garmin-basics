import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

class basicActiveView extends WatchUi.View {
    // UI Layout constants
    private const GPS_DOT_X_RATIO = 5;
    private const GPS_DOT_Y_RATIO = 5;
    private const GPS_DOT_SIZE = 6;
    private const TIMER_INTERVAL = 1000; // 1 second base interval
    
    // Update intervals (in seconds)
    private const BATTERY_DISPLAY_INTERVAL = 10;
    private const BATTERY_MONITOR_INTERVAL = 60;
    
    // Instance variables
    private var _timeField = null;
    private var _batteryField = null;
    private var _timer = null;
    private var _dataManager = null;
    private var _secondsCounter = 0;
    private var _isActive = false; // Track if view is currently active

    function initialize(dataManager) {
        View.initialize();
        _dataManager = dataManager;
        _isActive = false;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
        // Mark view as active
        _isActive = true;
        
        // Get UI elements
        _timeField = View.findDrawableById("timeText");
        _batteryField = View.findDrawableById("batteryText");
        
        // Start timer only if not already running
        _startTimer();
        
        // Initial updates
        _updateBatteryDisplay();
        updateAll();
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        _drawGPSStatusDot(dc);
    }

    function onHide() as Void {
        // Mark view as inactive and stop timer
        _isActive = false;
        _stopTimer();
    }

    /**
     * Safely start the timer - prevents multiple timers
     */
    private function _startTimer() as Void {
        // Always stop existing timer first
        _stopTimer();
        
        // Create and start new timer
        _timer = new Timer.Timer();
        _timer.start(method(:updateAll), TIMER_INTERVAL, true);
    }

    /**
     * Safely stop and cleanup timer
     */
    private function _stopTimer() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
    }

    /**
     * Master update function called every second
     * Only runs if view is currently active
     */
    public function updateAll() as Void {
        // Safety check - don't update if view is not active
        if (!_isActive) {
            return;
        }

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

        // Request UI update only if view is active
        if (_isActive) {
            WatchUi.requestUpdate();
        }
    }

    private function _updateTimeDisplay() as Void {
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

    private function _updateBatteryDisplay() as Void {
        if (_dataManager != null && _batteryField != null) {
            // Only get current battery level - no updates triggered
            var batteryLevel = _dataManager.getBatteryLevel();
            _batteryField.setText(batteryLevel.format("%d") + "%");
        }
    }

    private function _drawGPSStatusDot(dc) as Void {
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