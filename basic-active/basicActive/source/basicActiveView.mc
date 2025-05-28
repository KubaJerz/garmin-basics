import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Time;

class basicActiveView extends WatchUi.View {
    private var _timeField = null;

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

        updateUI();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        updateUI();

        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
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
        }
    }

}
