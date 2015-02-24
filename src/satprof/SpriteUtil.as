package satprof
{
	import satprof.Away3dEventUtils;
	
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class SpriteUtil extends Sprite
	{
		
		private var arrListeners:Array = [];
		
		private var away3dEventUtils:Away3dEventUtils;
		
		public function SpriteUtil()
		{
			away3dEventUtils = Away3dEventUtils.getInstance();
			super();
		}
		
		public function removeListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false){
			away3dEventUtils.removeListener(ownerObject, eventObject, handlerFunction, useCapture);
		}
		
		public function addListener(ownerObject, eventObject, handlerFunction, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true) {
			away3dEventUtils.addListener(ownerObject, eventObject, handlerFunction, useCapture, priority, useWeakReference)
		}
	}
}