// RecordingView.mc - Screen shown during activity recording
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Time;

/**
 * View displayed during activity recording
 * Shows activity type, timer, and red stop button
 */
class RecordingView extends WatchUi.View {
    private var _activityType;
    private var _startTime;
    
    function initialize(activityType) {
        View.initialize();
        _activityType = activityType;
        _startTime = Time.now();
    }
    
    function onLayout(dc) {
        // Simple layout
    }
    
    function onShow() {
        WatchUi.requestUpdate();
    }
    
    function onUpdate(dc) {
        // Clear screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        _drawRecordingContent(dc);
    }
    
    /**
     * Draw the recording screen content
     */
    private function _drawRecordingContent(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Activity type title
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // dc.drawText(
        //     width / 2, 
        //     height * 0.15, 
        //     Graphics.FONT_LARGE, 
        //     "Recording " + _activityType.toUpper(), 
        //     Graphics.TEXT_JUSTIFY_CENTER
        // );
        
        // Timer
        _drawTimer(dc, width, height);
        
        // Red stop button
        _drawStopButton(dc, width, height);
        
    }
    
    /**
     * Draw elapsed time timer
     */
    private function _drawTimer(dc, width, height) {
        var elapsed = Time.now().subtract(_startTime);
        var minutes = elapsed.value() / 60;
        var seconds = elapsed.value() % 60;
        
        var timeString = Lang.format("$1$:$2$", [
            minutes.format("%02d"),
            seconds.format("%02d")
        ]);
        
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height * 0.15, 
            Graphics.FONT_NUMBER_HOT, 
            timeString, 
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
    
    /**
     * Draw the red stop button
     */
    private function _drawStopButton(dc, width, height) {
        var buttonRadius = width * 0.15;
        var buttonX = width / 2;
        var buttonY = height * 0.65;
        
        // Red circle button
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_RED);
        dc.fillCircle(buttonX, buttonY, buttonRadius);
        
        // White border
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(buttonX, buttonY, buttonRadius);
        
        // Stop text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            buttonX, 
            buttonY, 
            Graphics.FONT_MEDIUM, 
            "STOP", 
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
    
    /**
     * Get button coordinates for touch detection
     */
    function getStopButtonArea() {
        var deviceSettings = System.getDeviceSettings();
        var width = deviceSettings.screenWidth;
        var height = deviceSettings.screenHeight;
        var buttonRadius = width * 0.15;
        
        return {
            :x => width / 2,
            :y => height * 0.65,
            :radius => buttonRadius
        };
    }
}