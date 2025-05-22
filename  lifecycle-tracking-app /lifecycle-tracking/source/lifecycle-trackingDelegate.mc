import Toybox.Lang;
import Toybox.WatchUi;

class lifecycle_trackingDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new lifecycle_trackingMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}