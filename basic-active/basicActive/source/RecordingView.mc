// RecordingView.mc - Screen shown during activity recording
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Time;

/**
 * View displayed during activity recording
 * Shows activity type, timer, and red stop button
 */
class RecordingView extends WatchUi.View {
    // private var _activityType;
    
    function initialize(activityType) {
        View.initialize();
        // _activityType = activityType;
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
        
        
        // Red stop button
        _drawStopButton(dc, width, height);
        
    }
    
    
    /**
     * Draw the red stop button
     */
    private function _drawStopButton(dc, width, height) {
        var buttonRadius = width * 0.15;
        var buttonX = width / 2;
        var buttonY = height * 0.65;
        
        // Red circle button
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_RED);
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