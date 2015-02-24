package satprof
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class Away3dEventUtils extends EventDispatcher
	{
		private var eventList:Array;
		private var _dispatcher:*;
		private var _showTraces = false;
		
		public var eventLog:Array; // Array of objects
		
		private static var instance: Away3dEventUtils;
		private static var allowInstance:Boolean;

		public function Away3dEventUtils(target:IEventDispatcher=null)
		{
			if(!allowInstance) { 
				throw new Error("Error: use ConfigController.getInstance() instead of new keyword");
			}
			instance = this;
			eventLog = [];
		}
		
		public function addListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true){
			ownerObject.addEventListener(eventObject, handlerFunction, useCapture, priority, useWeakReference);
			var i = eventLog.length;
			eventLog[i] = new Object();
			eventLog[i].eventOwner = ownerObject;
			eventLog[i].eventObject = eventObject;
			eventLog[i].eventHandler = handlerFunction;
			if (_showTraces){
				var str:String = "";
				try {
					str = ownerObject.name
				} catch (error:Error) {
					str = "";
				}
				if (str == ""){
					trace("FYI, in Away3dEventUtils.addListener, logged event "+i+": "+String(eventObject) );
				} else {
					trace("FYI: In Away3dEventUtils.addListener, logged event "+i+": "+String(eventObject)+" to " + ownerObject.name);
				}
			}
		}
		
		public function removeListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false){
			for (var i = 0; i<eventLog.length; i++){
				if ( ownerObject == eventLog[i].eventOwner && eventObject == eventLog[i].eventObject && handlerFunction == eventLog[i].eventHandler){
					eventLog[i].eventOwner.removeEventListener(eventLog[i].eventObject, eventLog[i].eventHandler, useCapture);
					eventLog.splice(i, 1); // Delete this item from array.
					if (_showTraces){
						trace("FYI, in EventUtils.removeListener, removed event "+i);
					}
				}
			}
		}
		
		public function resumeListeners(){
			for (var i=0; i<eventLog.length; i++){
				///eventOwnerLog[i].removeEventListener(eventObjectLog[i], eventHandlerLog[i]);
				addListener(eventLog[i].eventOwner, eventLog[i].eventObject, eventLog[i].eventHandler);
			}
			eventLog = [];
		}
		
		public function kill(){
			if (_showTraces){
				trace("FYI, in Away3dEventUtils.kill, starting with " +eventLog.length+" logged event listeners...");
			}
			for (var i=0; i<eventLog.length; i++){
				///eventOwnerLog[i].removeEventListener(eventObjectLog[i], eventHandlerLog[i]);
				eventLog[i].eventOwner.removeEventListener(eventLog[i].eventObject, eventLog[i].eventHandler);
			}
			eventLog = [];
			if (_showTraces){
				trace("  ... now all events are cleared. Now we have " +eventLog.length+" logged event listeners.");
			}
		}
		
		public static function getInstance():Away3dEventUtils {
			if(instance == null) {
				allowInstance = true;
				instance = new Away3dEventUtils();
				//trace("Away3dEventUtils instance created");
				allowInstance = false;
			} else { 
				//trace("Away3dEventUtils instance already exists");
			}
			return instance;
		}
		
	}
}