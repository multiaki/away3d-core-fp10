package satprof
{
	import com.satprof.lib.EventUtils;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class SpriteUtil extends Sprite
	{
		
		private var arrListeners:Array = [];
		
		private var eventUtils:EventUtils;
		
		public function SpriteUtil()
		{
			eventUtils = EventUtils.getInstance();
			super();
		}
		
		public function addListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true) {
			eventUtils.addListener(ownerObject, eventObject, handlerFunction, useCapture, priority, useWeakReference)
		}
	}
}