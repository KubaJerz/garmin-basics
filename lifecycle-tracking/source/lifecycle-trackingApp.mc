import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class lifecycle_trackingApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        System.println("LIFECYCLE init()");
        System.println("-------------------------");
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        AppBase.onStart(state);
        if (state == null){
            System.println("Completely fesh start - null state");
        }

        if (state.get(:resume)){
            System.println("We are RESUMING from suspension");
        } else {
            System.println("We are new start butsome data");
            System.println(state);
        }

        System.println("   → Preparing to become visible to user");
        System.println("   → Setting up data structures");
        System.println("----------------------------------------");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println(" LIFECYCLE: onStop() - Going home!");
        
        if (state.get(:suspend)) {
            System.println("   → We're being SUSPENDED - might come back later");
            System.println("   → Saving complete state for quick resume");
        } else {
            System.println("   → We're being TERMINATED - full shutdown");
            System.println("   → Cleaning up all resources");
        }
        
        System.println("   → This is our last chance to save important data!");
        System.println("----------------------------------------");
        
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        System.println("   LIFECYCLE: getInitialView() - Setting up the screen!");
        System.println("   → Returning the view and input handler");
        System.println("----------------------------------------");

        return [ new lifecycle_trackingView(), new lifecycle_trackingDelegate() ];
    }

}

function getApp() as lifecycle_trackingApp {
    return Application.getApp() as lifecycle_trackingApp;
}