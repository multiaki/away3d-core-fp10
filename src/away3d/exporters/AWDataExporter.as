﻿package away3d.exporters{	import away3d.arcane;	import away3d.containers.*;	import away3d.core.base.*;	import away3d.events.*;		import flash.events.*;	import flash.geom.*;	import flash.utils.*;		use namespace arcane;		public class AWDataExporter extends EventUtil{				private var useMesh:Boolean;		private var asString:String;		private var containerString:String;		private var materialString:String;		private var geoString:String;		private var meshString:String;		private var gcount:int;		private var mcount:int;		private var objcount:int;		private var geocount:int;		private var geonums:Dictionary;		private var facenums:Dictionary;		private var indV:int;		private var indVt:int;		private var indF:int;		private var geos:Array;				private var p1:RegExp = new RegExp("/0.0000/","g");						private  function reset():void		{			containerString = "";			materialString = "";			geoString = "";			meshString = "";			indV = indVt = indF = gcount = mcount = objcount = geocount = 0;			geonums = new Dictionary(true);			facenums = new Dictionary(true);			geos= [];				}			private  function write(object3d:Object3D, containerid:int = -1):void		{			var nameinsert:String = (object3d.name == null)? "" : object3d.name;			useMesh = true;			var aF:Array = [];			var MaV:Array = [];			var MaVt:Array = [];			 			meshString += objcount+","+object3d.transform.rawData[0]+","+object3d.transform.rawData[4]+","+object3d.transform.rawData[8]+","+object3d.transform.rawData[12]+",";			meshString += object3d.transform.rawData[1]+","+object3d.transform.rawData[5]+","+object3d.transform.rawData[9]+","+object3d.transform.rawData[13]+",";			meshString += object3d.transform.rawData[2]+","+object3d.transform.rawData[6]+","+object3d.transform.rawData[10]+","+object3d.transform.rawData[14]+"\n";			meshString += nameinsert+","+object3d.pivotPoint.x+","+object3d.pivotPoint.y+","+object3d.pivotPoint.z+",";			meshString += containerid+","+(object3d as Mesh).bothsides+","+(object3d as Mesh).ownCanvas+","+(object3d as Mesh).pushfront+","+(object3d as Mesh).pushback+",";			meshString += object3d.x+","+object3d.y+","+object3d.z+"\n";						var aFaces:Vector.<Face> = (object3d as Mesh).faces;			var geometry:Geometry = (object3d as Mesh).geometry;			var va:int;			var vb:int;			var vc:int;			var vta:int;			var vtb:int;			var vtc:int;			var tmp:Vector3D = new Vector3D();			var i:int;			var j:int;			var aRef:Array = [vc, vb, va];						//var animated:Boolean = (object3d as Mesh).geometry.frames != null;						var face:Face;			var geoIndex:int;						if ((geoIndex = checkGeometry(geometry)) == -1) {				geoIndex = geos.length;				geos.push(geometry);								for(i = 0; i<aFaces.length ; ++i)				{					face = aFaces[i];					geonums[face] = geoIndex;					facenums[face] = i;										for(j=0;j<3;++j){						tmp.x =  face.vertices[j].x;						tmp.y =  face.vertices[j].y;						tmp.z =  face.vertices[j].z;						aRef[j] = checkDoubles( MaV, (tmp.x.toFixed(4)+"/"+tmp.y.toFixed(4)+"/"+tmp.z.toFixed(4)) );					}										vta = checkDoubles( MaVt, face.uvs[0].u +"/"+ face.uvs[0].v);					vtb = checkDoubles( MaVt, face.uvs[1].u +"/"+ face.uvs[1].v);					vtc = checkDoubles( MaVt, face.uvs[2].u +"/"+ face.uvs[2].v);										aF.push( aRef[0].toString(16)+","+aRef[1].toString(16)+","+aRef[2].toString(16)+","+vta.toString(16)+","+vtb.toString(16)+","+vtc.toString(16));				}								geoString += "v:"+encode( MaV.toString() )+"\n";				geoString += "u:"+encode( MaVt.toString() )+"\n";				geoString += "f:"+aF.toString()+"\n";				 			}			 			objcount ++;		}				private function encode(str:String):String		{			var start:int= 0;			var chunk:String;			var encstr:String = "";			var charcount:int = str.length;			for(var i:int = 0;i<charcount;++i){				if (str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && str.charCodeAt(i)!= 48 ){					start = i;					chunk = "";					while(str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && i<=charcount){						i++;					}					chunk = Number(str.substring(start, i)).toString(16);					encstr+= chunk;					i--;				} else{					encstr+= str.substring(i, i+1);				}			}			return encstr.replace(p1,"/0/");		}				private function checkDoubles(arr:Array, string:String):int		{			for(var i:int = 0;i<arr.length;++i)				if(arr[i] == string) return i;			 			arr.push(string);			return arr.length-1;		}				private function checkGeometry(geometry:Geometry):int		{			for (var i:String in geos)				if (geos[i] == geometry)					return Number(i);						return -1;		}				private  function parse(object3d:Object3D, containerid:int = -1):void		{			if(object3d is ObjectContainer3D){				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);								var id:int = gcount;				containerString += "\n"+id+","+obj.transform.rawData[0]+","+obj.transform.rawData[4]+","+obj.transform.rawData[8]+","+obj.transform.rawData[12]+","+obj.transform.rawData[1]+","+obj.transform.rawData[5]+","+obj.transform.rawData[9]+","+obj.transform.rawData[13]+","+obj.transform.rawData[2]+","+obj.transform.rawData[6]+","+obj.transform.rawData[10]+","+obj.transform.rawData[14]+",";				containerString += obj.name+","+obj.pivotPoint.x+","+obj.pivotPoint.y+","+obj.pivotPoint.z;				gcount++;								for(var i:int =0;i<obj.children.length;i++){					if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i], id);					} else{						write( obj.children[i], id);					}				}							} else {				write( object3d, -1);			}		}				/**		* Class generates a string in the Actionscript3 format representing an abstraction of the object3D(s). The AWDataParser will be required for reserialisation.		*/				function AWDataExporter(){}				/**		* Generates a string in the awd format (away3d data). String represents the object3D(s).		* The event onComplete, returns in event.data the generated class string.		* This class is ideal for runtime load of geometry and allows storage/read from database making it ideal for games levels.		* The Away3D version exports only the geometry, PreFab3D or AWDataExporterAIR class supports material		* The AWData in Away3D loaders supports both types.		*		* @param	object3d				Object3D. The Object3D to be exported to the awd format (away3d data). 		*/		public function export(object3d:Object3D):void		{						if(hasEventListener(ExporterEvent.COMPLETE)){				reset();				parse(object3d);				asString = "//AWDataExporter version 1.0, Away3D Flash 10, generated by Away3D: http://www.away3d.com\n";				asString += "#v:1.0\n";				asString += "#f:1\n";				asString += "#t:"+((!gcount)? "mesh\n": "object3d\n");				asString += "#o\n"+meshString;				asString += "#d\n"+geoString;				asString += "#c"+containerString;				asString += "\n#end of file";								var EE:ExporterEvent = new ExporterEvent(ExporterEvent.COMPLETE);				EE.data = asString;				dispatchEvent(EE);							} else {				trace("AWDataExporter Error:\nNo ExporterEvent.COMPLETE event set.\nUse the method addOnExportComplete(myfunction) before use export();\n");			}		}				/**		 * Default method for adding a complete event listener		 * The event.data holds the generated string from the wavefront class		 * 		 * @param	listener		The listener function		 */		public function addOnExportComplete(listener:Function):void        {			addListener(this, ExporterEvent.COMPLETE, listener, false, 0, false);        }		/**		 * Default method for removing a complete event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnExportComplete(listener:Function):void        {            removeListener(ExporterEvent.COMPLETE, listener, false);        }		/**		 * Returns the last generated awd string file async from events.		 */		public function get file():String		{			return asString;		}			}}