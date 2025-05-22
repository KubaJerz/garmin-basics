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

        if (state == null) {
            System.println(" Completely fresh start - null state");
        } else {
            // Check if we're resuming
            var isResuming = false;
            if (state.hasKey(:resume)) {
                var resumeValue = state.get(:resume);
                if (resumeValue instanceof Lang.Boolean && resumeValue) {
                    isResuming = true;
                }
            }
            
            if (isResuming) {
                System.println(" We are RESUMING from suspension");
            } else {
                System.println(" We are new start but some data");
                System.println("   → State contents: " + state.toString());
            }
        }

        System.println("   → Preparing to become visible to user");
        System.println("   → Setting up data structures");
        System.println("----------------------------------------");
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println(" LIFECYCLE: onStop() - Going home!");
        
        var isSuspended = false;
        
        if (state != null && state.hasKey(:suspend)) {
            var suspendValue = state.get(:suspend);
            // Explicitly check if it's a Boolean and true
            if (suspendValue instanceof Lang.Boolean) {
                isSuspended = suspendValue as Boolean;
            }
        }
        
        if (isSuspended) {
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