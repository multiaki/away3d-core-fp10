﻿package away3d.core.geom
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.primitives.*;
	import away3d.materials.*;
	import satprof.EventUtil;
	
	import flash.display.*;
	
	/**
	 * displays the path information
	 */
    public class PathDebug extends EventUtil
    {
        private var _path:Path;
		private var _scene:Scene3D;
		private var _displayAnchors:Boolean = true;
		private var _showPath:Boolean = true;
		
		public var _container:ObjectContainer3D;
		private var _aCurves:Vector.<CurveLineSegment>;
		private var _aSpheres:Vector.<Sphere>;
		private var _matline:WireframeMaterial;
		private var _matsphere:BitmapMaterial;
		private var _matspherecontrol:BitmapMaterial;
		 
		/**
		 * Creates a new <code>PathDebug</code> object.
		 * @param	 scene		Scene3D. The scene to addchild the visualisation of the Path object
		 * @param	 path			Path. The Path object to be displayed
		 */
        public function PathDebug(scene:Scene3D, path:Path)
        {
			_scene = scene;
			 _path = path;
			_matline= new WireframeMaterial( 0xFFFF99, {thickness:0});
			_matsphere = new BitmapMaterial(new BitmapData(64,64,false, 0x00ff00));
			_matspherecontrol = new BitmapMaterial(new BitmapData(64,64,false, 0xFF9900));
			_container = new ObjectContainer3D();
			_aCurves = new Vector.<CurveLineSegment>();
			_aSpheres = new Vector.<Sphere>();
			var loop:int = _path.aSegments.length;
			var pStart:Vertex;
			var pControl:Vertex;
			var pEnd:Vertex;
			var cs:PathCommand;
			var cls:CurveLineSegment;
			 
			for(var i:int = 0; i<loop; ++i){
				cs = _path.aSegments[i];
				pStart = new Vertex(cs.pStart.x, cs.pStart.y, cs.pStart.z);
				pControl = new Vertex(cs.pControl.x, cs.pControl.y, cs.pControl.z);
				pEnd = new Vertex(cs.pEnd.x, cs.pEnd.y, cs.pEnd.z);
				
				cls = 	new CurveLineSegment(pStart, pControl, pEnd, _matline);
				_aCurves.push(cls);
				add3dChild(cls, _container);
				
				addAnchor(pStart, _matsphere);
				
				addAnchor(pControl, _matspherecontrol);
					
				if(i == loop-1)
					addAnchor(pEnd, _matsphere);
			}
			
			add3dChild(_container, _scene);
		}
		
		private function addAnchor(position:Vertex, mat:BitmapMaterial):void
		{
			var sphere:Sphere = new Sphere({material:mat, radius:50, segmentsH:2, segmentsW:2 });
			_aSpheres.push(sphere);
			sphere.x = position.x ;
			sphere.y = position.y ;
			sphere.z = position.z ;
			add3dChild(sphere, _container);
		}

		/**
		 * Defines if the anchors must be displayed in debugmode. if false, only curves are displayed
		 */
		public function set showAnchors(b:Boolean):void
		{
			if(!_container)
				return;
				
			_displayAnchors = b;
			var i:int;
			var loop:int = _aSpheres.length;
			for(i = 0;i<loop;++i)
				_aSpheres[i].visible = b;
		}
		
		public function get showAnchors():Boolean
		{
			return _displayAnchors;
		}
		
		/**
		 * defines if the path data must be visible or not when path debug
		 */
		public function set display(b:Boolean):void
		{
			if(!_container)
				return;
				
			_showPath = b;
			_container.visible = b;
		}
		
		public function get display():Boolean
		{
			return _showPath;
		}
		
		/**
		 * Removes and destroys the path visualisation
		 */
		public function clearDebug(b:Boolean):void
		{
			b;
			if(!_container)
				return;
				
			var i:int;
			var loop:int = _aSpheres.length;
			for(i = 0;i<loop;++i)
				_container.removeChild(_aSpheres[i]);
				_aSpheres[i] = null;
			
			loop = _aCurves.length;
			for(i = 0;i<loop;++i)
				_container.removeChild(_aCurves[i]);
				_aCurves[i] = null;
				
			_scene.removeChild(_container);
			_container = null;
			_aSpheres = new Vector.<Sphere>();
			_aCurves = new Vector.<CurveLineSegment>();
		}
		// to be updated with prefab code...
		public function updateAnchorAt(index:int):void
		{
		}

    }
}
