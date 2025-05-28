import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Timer;

class basicActiveView extends WatchUi.View {
    private var _timeField = null;
    private var _timer = null;
    private const TIMER_INTERVAL = 1000;

    function initialize() {
        View.initialize();
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
        if (_timer == null){
            _timer = new Timer.Timer();
            _timer.start(method(:updateUI), TIMER_INTERVAL, true); // repeat = true
        }

        updateUI();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        // updateUI();

        View.onUpdate(dc);
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

        if (_timeField != null){
            var dateInfo = Time.Gregorian.info( Time.now(), Time.FORMAT_SHORT );

            var timeString = Lang.format("$1$:$2$ $3$/$4$/$5$", [
                dateInfo.hour,
                dateInfo.min.format("%02d"),
                dateInfo.month,
                dateInfo.day,
                dateInfo.year
            ]);
            _timeField.setText(timeString);
            WatchUi.requestUpdate();
        }
    }

}
