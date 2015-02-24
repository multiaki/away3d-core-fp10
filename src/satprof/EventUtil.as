<<<<<<< HEAD
package satprof
{
	import com.satprof.lib.EventUtils;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class EventUtil extends EventDispatcher
	{
		
		private var arrListeners:Array = [];
		
		private var eventUtils:EventUtils;
		
		public function EventUtil()
		{
			eventUtils = EventUtils.getInstance();
			super();
		}
		
		public function clearEvents():void
		{
		   for(var i:Number = 0; i<arrListeners.length; i++){
		      if(this.hasEventListener(arrListeners[i].type)){
		         this.removeEventListener(arrListeners[i].type, arrListeners[i].listener);
		      }
		   }
		   arrListeners = null
		}
		
		public function addListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true) {
			eventUtils.addListener(ownerObject, eventObject, handlerFunction, useCapture, priority, useWeakReference)
		}
	}
}
=======
﻿import ../../../../

// Ralph added this.  committed
>>>>>>> origin/master
