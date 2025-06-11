// SecondaryView.mc - Example secondary screen
using Toybox.WatchUi;
using Toybox.Graphics;

class SecondaryView extends WatchUi.View {
    
    function initialize() {
        View.initialize();
    }
    
    function onLayout(dc) {
        // Simple layout - you can customize this
    }
    
    function onShow() {
        // Called when screen becomes visible
        WatchUi.requestUpdate();
    }
    
    function onUpdate(dc) {
        // Clear the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        
        // Draw secondary screen content
        _drawSecondaryContent(dc);
    }
    
    // Separate drawing logic for better organization
    private function _drawSecondaryContent(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        // Title
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            width / 2, 
            height / 4, 
            Graphics.FONT_MEDIUM, 
            "Settings", 
            Graphics.TEXT_JUSTIFY_CENTER
        );
        
        // Instruction
        dc.drawText(
            width / 2, 
            height / 2, 
            Graphics.FONT_SMALL, 
            "Swipe up to return", 
            Graphics.TEXT_JUSTIFY_CENTER
        );
        

    }
}