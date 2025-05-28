import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class basicActiveApp extends Application.AppBase {
    private var _recorder = null;

    function initialize() {
        AppBase.initialize();
        // _recorder = new AccelRecorder();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        if (_recorder != null ){
            //start recording
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    //if not null and is recording then stop then save
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        // return [ new basicActiveView(), new basicActiveDelegate(_recorder) ];

        return [ new basicActiveView(), new basicActiveDelegate() ];
    }

}

function getApp() as basicActiveApp {
    return Application.getApp() as basicActiveApp;
}