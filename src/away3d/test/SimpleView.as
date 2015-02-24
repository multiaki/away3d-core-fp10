package away3d.test
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.render.Renderer;
	import away3d.core.stats.Tasks;
	
	import satprof.SpriteUtil;
	
	public class SimpleView extends SpriteUtil
	{
		protected var task		:String;
		protected var view		:View3D;
		protected var target	:Object3D;
		
		/**
		 * SimpleView for testing/demo purpose
		 * 
		 * @param task Your task name for profiler
		 * @param desc Your description for this task
		 * 
		 */		
		public function SimpleView(task:String = "Draw", desc:String = "")
		{
			this.task = task;
			
			view = new View3D({
				x:stage.stageWidth * .5, y:stage.stageHeight * .5, 
				camera: new Camera3D( { y:2000*Math.sin(Math.PI/6), z:2000 } ), 
				renderer:Renderer.BASIC
			});
			
			target = new Object3D();
            add3dChild(target, view.scene);
            view.camera.lookAt(target.position);
			
			addListener(view, Event.ADDED_TO_STAGE, init);
			add3dChild(view);
			
			 //stat+profiler
			Tasks.init(this, desc);
		}
		
        protected function init(event:Event) : void
		{
			//stage
            stage.scaleMode = "noScale";
            stage.showDefaultContextMenu = true;
            stage.stageFocusRect = false;
            stage.quality = "medium";
            stage.frameRate = 30;
            
            create();
		}
        
        protected function create() : void
        {
        	 //plz override me
        }
        
        protected function start() : void
		{
			view.camera.lookAt(target.position);
			addListener(this, Event.ENTER_FRAME, run);
		}
		
        protected function run(event:Event) : void
        {
			//update
            view.render();
            
            //begin profiler
            Tasks.begin(task);
            
            //draw
            draw();
            
            //end profiler
            Tasks.end(task);
        }
        
        protected function draw() : void
        {
        	 //plz override me
        }
	}
}