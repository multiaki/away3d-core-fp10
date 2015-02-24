﻿package away3d.tools{
	
	import away3d.core.base.Mesh;
	import away3d.core.base.Vertex;
	import away3d.core.base.Face;
	import away3d.core.base.UV;
	import away3d.core.base.Object3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.materials.Material;
	import away3d.arcane;
	
	use namespace arcane;
	
	/**
	 * Class Explode corrects all the faces of an object3d with unic vertexes.<code>Explode</code>
	 * Each faces can then be moved independently without influence for the surrounding faces. 
	 */
	public class Explode{
		private var _unicmeshes:Boolean;
		private var _recenter:Boolean;
		private var _container:ObjectContainer3D;
		 
		private function parse(object3d:Object3D):void
		{
			 
			if(object3d is ObjectContainer3D){
			
				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);
			
				for(var i:uint =0;i<obj.children.length;++i){
					
					if(obj.children[i] is ObjectContainer3D){
						parse(obj.children[i]);
					} else if(obj.children[i] is Mesh){
						explode(obj.children[i] as Mesh);
					}
				}
				
			}else if(object3d is Mesh){
				explode( object3d as Mesh);
			}
			 
		}
		 
		private function explode(obj:Mesh):void
		{
				var i:int = 0;
				var loop:int = obj.faces.length;
				var face:Face;
				var va: Vertex;
				var vb: Vertex;
				var vc :Vertex;
				var v0:Vertex;
				var v1:Vertex;
				var v2:Vertex;
				var uv0:UV;
				var uv1:UV;
				var uv2:UV;
				
				if(_unicmeshes){
					
					var mesh:Mesh;
					var uva: UV;
					var uvb: UV;
					var uvc :UV;
				
					for(i=0;i<loop;++i){
						
						face = obj.faces[i];
						uv0 = face.uvs[0];
						uv1 = face.uvs[1];
						uv2 = face.uvs[2];
						v0 = face.vertices[0];
						v1 = face.vertices[1];
						v2 = face.vertices[2];
						
						mesh = new Mesh();
						
						va = new Vertex(v0.x, v0.y, v0.z);
						vb = new Vertex(v1.x, v1.y, v1.z);
						vc = new Vertex(v2.x, v2.y, v2.z);
						uva = new UV(uv0.u, uv0.v);
						uvb = new UV(uv1.u, uv1.v);
						uvc = new UV(uv2.u, uv2.v);
						
						mesh.addFace(new Face(va, vb, vc, obj.material as Material, uva, uvb, uvc));
						add3dChild(mesh, _container);
						
						if(_recenter)
							mesh.applyPosition( (mesh.minX+mesh.maxX)*.5,  (mesh.minY+mesh.maxY)*.5, (mesh.minZ+mesh.maxZ)*.5);
					}
					
				} else{
					
					
					var index:int = 0;
					var v:Array = [];
				
					for(i=0;i<loop;++i){
						face = obj.faces[i];
						uv0 = face.uvs[0];
						uv1 = face.uvs[1];
						uv2 = face.uvs[2];
						v0 = face.vertices[0];
						v1 = face.vertices[1];
						v2 = face.vertices[2];
						va = new Vertex(v0.x, v0.y, v0.z);
						vb = new Vertex(v1.x, v1.y, v1.z);
						vc = new Vertex(v2.x, v2.y, v2.z);
						v.push(va, vb, vc);
					}
					 
					for(i=0;i<loop;++i){
						face = obj.faces[i];
						face.addVertexAt(0, v[index], "M");
						face.addVertexAt(1, v[index+1], "L");
						face.addVertexAt(2, v[index+2], "L");
						index+=3;
					}

					v = null;
				}
		}
		 
		/**
		*  Class Explode corrects all the faces of an object3d with unic vertexes. <code>Explode</code>
		* Each faces can then be moved independently without influence for the surrounding faces.
		*
		* @param	 unicmeshes			[optional] Boolean. Defines if an isolated face becomes a unic Mesh objects or not. Default = false;
		* @param	 recenter				[optional] Boolean. Defines if unicmeshes is true, if the unic meshes are recentered or not. Default = false;
		*/
		 
		function Explode(unicmeshes:Boolean = false, recenter:Boolean = false):void {
			_unicmeshes = unicmeshes;
			_recenter = recenter;
		}
		
		/**
		* Apply the explode code to a given object3D
		* 
		* @param	 object3d		Object3D. The target Object3d object.
		*
		* @return	 Object3D		if unicmeshes, returns an ObjectContainer3D with all the unic meshes in it, or the original object3d affected by the explode code.
		*/
		public function apply(object3d:Object3D):Object3D
		{
			if(_unicmeshes)
				_container = new ObjectContainer3D();
				
			parse(object3d);
			
			if(_unicmeshes)
				return _container;
			else
				return object3d;
		}
		
		/**
		* Defines if an isolated face becomes a unic Mesh objects or not. Class default = false;
		*/
		public function set unicmeshes(b:Boolean):void
		{
			_unicmeshes = b;
		}
		public function get unicmeshes():Boolean
		{
			return _unicmeshes;
		}
		
		/**
		* if unicmeshes is true, defines if the unic meshes are recentered or not. Default = false;
		*/
		public function set recenter(b:Boolean):void
		{
			_recenter = b;
		}
		public function get recenter():Boolean
		{
			return _recenter;
		}
		 
	}
}