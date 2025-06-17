import Toybox.ActivityRecording;
import Toybox.FitContributor;
import Toybox.System;
import Toybox.Time;
import Toybox.Lang;

/**
 * ActivityEventManager handles recording cigarette/vape events to FIT files.
 * Follows Single Responsibility Principle - only manages activity events.
 */
class ActivityEventManager {
    private var _eventIsActiveField = null;
    private var _eventTypeField = null;
    private var _isEnabled = false;
    
    // FIT field IDs (must be unique within your app)
    private const EVENT_FIELD_ID = 1;
    private const EVENT_TYPE_FIELD_ID = 2;
    
    // Event type constants for consistency
    private const EVENT_TYPE_NONE = 0;
    private const EVENT_TYPE_CIGARETTE = 1;
    private const EVENT_TYPE_VAPE = 2;

    
    /**
     * Initialize the event manager
     */
    public function initialize() {
        // Nothing needed for initialization
    }
    
    /**
     * Enable event recording for the current FIT session
     * @param session The active FIT recording session
     */
    public function enable(session) {
        if (_isEnabled) {
            return; // Already enabled
        }
        
        if (session == null) {
            throw new Lang.InvalidValueException("Session cannot be null");
        }
        
        try {
            // Create FIT field for event timestamp
            _eventIsActiveField = session.createField(
                "activity_event_is_active", 
                EVENT_FIELD_ID, 
                FitContributor.DATA_TYPE_UINT32, 
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD, 
                    :units => ""
                }
            );
            
            // Create FIT field for event type
            _eventTypeField = session.createField(
                "activity_event_type", 
                EVENT_TYPE_FIELD_ID, 
                FitContributor.DATA_TYPE_UINT8, 
                {
                    :mesgType => FitContributor.MESG_TYPE_RECORD, 
                    :units => ""
                }
            );

            _eventIsActiveField.setData(0); // Defualt NOT active 
            _eventTypeField.setData(EVENT_TYPE_NONE); // defult NONE TYPE 

            
            _isEnabled = true;
            System.println("Activity event recording enabled");
            
        } catch (ex) {
            System.println("Failed to enable activity event recording: " + ex.getErrorMessage());
            throw ex;
        }
    }
    
    /**
     * Disable event recording
     */
    public function disable() {
        if (!_isEnabled) {
            return; // Already disabled
        }
        
        _eventIsActiveField = null;
        _eventTypeField = null;
        _isEnabled = false;
        
        System.println("Activity event recording disabled");
    }
    
    /**
     * Record a cigarette event
     */
    public function startCigaretteEvent() {
        _recordEvent(EVENT_TYPE_CIGARETTE, 1, "cigarette");
    }
    
    /**
     * Record a vape event
     */
    public function startVapeEvent() {
        _recordEvent(EVENT_TYPE_VAPE, 1, "vape");
    }

    public function endCigaretteEvent() {
        _recordEvent(EVENT_TYPE_CIGARETTE, 0, "cigarette");
    }
    
    /**
     * Record a vape event
     */
    public function endVapeEvent() {
        _recordEvent(EVENT_TYPE_VAPE, 0, "vape");
    }
    
    /**
     * Check if event recording is enabled
     */
    public function isEnabled() {
        return _isEnabled;
    }
    
    /**
     * Clean up resources
     */
    public function cleanup() {
        disable();
    }
    
    /**
     * Internal method to record an event to FIT file
     * @param eventType The type of event (cigarette or vape)
     * @param eventName Human-readable name for logging
     */
    private function _recordEvent(eventType, eventIsActive, eventName) {
        if (!_isEnabled || _eventIsActiveField == null || _eventTypeField == null) {
            System.println("Cannot record " + eventName + " event - not enabled");
            return;
        }
        
        try {            
            // Record if event is start ot stop and type to FIT file
            _eventIsActiveField.setData(eventIsActive);
            _eventTypeField.setData(eventType);
                        
        } catch (ex) {
            System.println("Error recording " + eventName + " event: " + ex.getErrorMessage());
        }
    }
}