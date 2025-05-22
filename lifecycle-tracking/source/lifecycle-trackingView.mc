import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Timer;

class lifecycle_trackingView extends WatchUi.View {

    private var _updateCount = 0;
    private var _displayTimer;
    private var _startTime;

    function initialize() {
        View.initialize();

        System.println("VIEW LIFECYCLE: initialize() - View is being created!");
        System.println("   → Setting up view variables");
        System.println("   → This happens once per view creation");
        System.println("----------------------------------------");
        
        _startTime = System.getClockTime();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        System.println(" VIEW LIFECYCLE: onLayout() - Arranging the furniture!");
        System.println("   → Screen dimensions: " + dc.getWidth() + "x" + dc.getHeight());
        System.println("   → Setting up screen layout");
        System.println("----------------------------------------");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        System.println("  VIEW LIFECYCLE: onShow() - Time to start working!");
        System.println("   → User can now see our screen");
        System.println("   → Starting timers and heavy operations");
        System.println("   → THIS is where you'd start sensors to save battery");
        System.println("   → Battery impact: HIGH (sensors start here)");
        
        // Start a timer to simulate ongoing work
        _displayTimer = new Timer.Timer();
        _displayTimer.start(method(:onTimer), 2000, true); // Every 2 seconds
        
        System.println("   → Started display update timer");
        System.println("----------------------------------------");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
         _updateCount++;
        
        // Only print every 5th update to avoid spam
        if (_updateCount % 5 == 1) {
            System.println("    VIEW LIFECYCLE: onUpdate() #" + _updateCount + " - Working hard!");
            System.println("   → Refreshing the screen display");
            System.println("   → This happens 1-2 times per second while visible");
            System.println("   → Battery impact: MODERATE (screen updates)");
            System.println("----------------------------------------");
        }
        
        // Clear and draw the screen
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
        dc.clear();
        
        // Show current status
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        
        var currentTime = System.getClockTime();
        var timeString = currentTime.hour + ":" + 
                        currentTime.min.format("%02d") + ":" + 
                        currentTime.sec.format("%02d");
        
        dc.drawText(dc.getWidth()/2, 30, Graphics.FONT_MEDIUM,
                   "Lifecycle Tracker", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(dc.getWidth()/2, 70, Graphics.FONT_SMALL,
                   "Time: " + timeString, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(dc.getWidth()/2, 100, Graphics.FONT_SMALL,
                   "Updates: " + _updateCount, Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(dc.getWidth()/2, 130, Graphics.FONT_TINY,
                   "Check console for", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.drawText(dc.getWidth()/2, 150, Graphics.FONT_TINY,
                   "lifecycle messages!", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        System.println("☕ VIEW LIFECYCLE: onHide() - Taking a break!");
        System.println("   → User can no longer see our screen");
        System.println("   → Stopping display timer to save battery");
        System.println("   → THIS is where you'd reduce sensor frequency");
        System.println("   → Battery impact: REDUCED (stopping heavy operations)");
        
        if (_displayTimer != null) {
            _displayTimer.stop();
            _displayTimer = null;
            System.println("   → Display timer stopped");
        }
        
        System.println("----------------------------------------");
    }

    function onTimer() {
        System.println(" TIMER: Regular update - app is actively working");
        WatchUi.requestUpdate(); // Trigger onUpdate()
    }
    }

}
