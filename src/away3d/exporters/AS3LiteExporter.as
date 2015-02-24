﻿package away3d.exporters{	import away3d.arcane;	import away3d.containers.*;	import away3d.core.base.*;	import away3d.events.*;	import away3d.materials.*;	import away3d.primitives.*;		import flash.events.*;	import flash.geom.*;	import flash.utils.*;		use namespace arcane;		public class AS3LiteExporter extends EventUtil{				private var useMesh:Boolean;		private var asString:String;		private var containerString:String = "";		private var materialString:String = "";		private var geoString:String = "";		private var meshString:String = "";		private var gcount:int = 0;		private var mcount:int = 0;		private var objcount:int = 0;		private var geocount:int = 0;		private var geonums:Dictionary = new Dictionary(true);		private var facenums:Dictionary = new Dictionary(true);		private var indV:int = 0;		private var indVt:int = 0;		private var indF:int = 0;		private var geos:Array = [];				private var p1:RegExp = new RegExp("/0.0000/","g");				private var aTypes:Array =  [Plane, Sphere, Cube, Cone, Cylinder, RegularPolygon, Torus, GeodesicSphere, Skybox, Skybox6, LineSegment, GridPlane, WireTorus, WireRegularPolygon, WireCone, WireCube, WireCylinder, WirePlane, WireSphere]; 		 		private  function reset():void		{			containerString = "";			materialString = "";			geoString = "";			meshString = "";			indV = indVt = indF = gcount = mcount = objcount = geocount = 0;			geonums = new Dictionary(true);			facenums = new Dictionary(true);			geos= [];				}				private  function write(object3d:Object3D, containerid:int = -1):void		{			var mat:String = "null"; 			var nameinsert:String = (object3d.name == null)? "name:\"\", " : "name:\""+object3d.name+"\", ";			var bothsidesinsert:String = ((object3d as Mesh).bothsides)? "bothsides:true, " : "";			var type:String = "";						for( var i:int = 0; i<aTypes.length ; ++i)			{				if(object3d is aTypes[i]){					type = (""+aTypes[i]);					type = type.substring(7, type.length-1);					if(i>9){						var linemat:WireframeMaterial = ((object3d as Mesh).material  as WireframeMaterial);						var wirematinsert:String = " material: new WireframeMaterial(0x"+linemat.wireColor.toString(16).toUpperCase()+", {thickness:"+linemat.thickness+"*_scale})";					}					break;				}			}			//override for now until lite primitives are supported			type = "";			//end override 			var xpos:String = (object3d.x == 0)? "0" : object3d.x+"*_scale";			var ypos:String = (object3d.y == 0)? "0" : object3d.y+"*_scale";			var zpos:String = (object3d.z == 0)? "0" : object3d.z+"*_scale";						if(type != ""){					var objname:String = ""+type.toLowerCase()+objcount;					var constructinsert:String = "\n\t\t\tvar "+objname+":"+type+" = new "+type+"(";										switch(type){						case "Sphere":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", segmentsH:"+(object3d as aTypes[i]).segmentsH+", segmentsW:"+(object3d as aTypes[i]).segmentsW+", radius:"+(object3d as aTypes[i]).radius+"*_scale });";							break;						case "Plane":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", segmentsH:"+(object3d as aTypes[i]).segmentsH+", segmentsW:"+(object3d as aTypes[i]).segmentsW+", width:"+(object3d as aTypes[i]).width+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale });";							break;						case "Cone":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", segmentsH:"+(object3d as aTypes[i]).segmentsH+", segmentsW:"+(object3d as aTypes[i]).segmentsW+", radius:"+(object3d as aTypes[i]).radius+"*_scale, height:"+(object3d as aTypes[i]).height+", openEnded:"+(object3d as aTypes[i]).openEnded+" });";							break;						case "Cube":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", height:"+(object3d as aTypes[i]).height+"*_scale, depth:"+(object3d as aTypes[i]).depth+"*_scale, width:"+(object3d as aTypes[i]).width+"*_scale });";							break;						case "Cylinder":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", segmentsH:"+(object3d as aTypes[i]).segmentsH+", segmentsW:"+(object3d as aTypes[i]).segmentsW+", radius:"+(object3d as aTypes[i]).radius+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale, openEnded:"+(object3d as aTypes[i]).openEnded+" });";							break;						case "RegularPolygon":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", radius:"+(object3d as aTypes[i]).radius+"*_scale, sides:"+(object3d as aTypes[i]).sides+" });";							break;						case "Torus":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", segmentsR:"+(object3d as aTypes[i]).segmentsR+", segmentsT:"+(object3d as aTypes[i]).segmentsT+", radius:"+(object3d as aTypes[i]).radius+"*_scale, tube:"+(object3d as aTypes[i]).tube+"*_scale });";							break;						case "LineSegment":							var v0:Vertex = (object3d as aTypes[i]).start;							var v1:Vertex = (object3d as aTypes[i]).end;							meshString += constructinsert+"{"+nameinsert+wirematinsert+"});\n\t\t\t"+objname+".start = new Vertex("+v0.x+"*_scale,"+v0.y+"*_scale,"+v0.z+"*_scale);\n\t\t\t"+objname+".end = new Vertex("+v1.x+"*_scale,"+v1.y+"*_scale,"+v1.z+"*_scale);";							break;						case "WireTorus":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", radius:"+(object3d as aTypes[i]).radius+"*_scale, tube:"+(object3d as aTypes[i]).tube+", segmentsR:"+(object3d as aTypes[i]).segmentsR+", segmentsT:"+(object3d as aTypes[i]).segmentsT+" });";							break;						case "WireRegularPolygon":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", radius:"+(object3d as aTypes[i]).radius+"*_scale, sides:"+(object3d as aTypes[i]).sides+" });";							break;						case "WireCone":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", radius:"+(object3d as aTypes[i]).radius+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale, segmentsW:"+(object3d as aTypes[i]).segmentsW+", segmentsH:"+(object3d as aTypes[i]).segmentsH+" });";							break;						case "WireCube":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", width:"+(object3d as aTypes[i]).width+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale, depth:"+(object3d as aTypes[i]).depth+"*_scale});";							break;						case "WireCylinder":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", radius:"+(object3d as aTypes[i]).radius+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale, segmentsW:"+(object3d as aTypes[i]).segmentsW+", segmentsH:"+(object3d as aTypes[i]).segmentsH+" });";							break;						case "WirePlane":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", width:"+(object3d as aTypes[i]).width+"*_scale, height:"+(object3d as aTypes[i]).height+"*_scale, segmentsW:"+(object3d as aTypes[i]).segmentsW+", segmentsH:"+(object3d as aTypes[i]).segmentsH+" });";							break;						case "WireSphere":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", radius:"+(object3d as aTypes[i]).radius+"*_scale, segmentsW:"+(object3d as aTypes[i]).segmentsW+", segmentsH:"+(object3d as aTypes[i]).segmentsH+" });";							break;							 						case "GeodesicSphere":							meshString += constructinsert+"{"+nameinsert+bothsidesinsert+"material:"+mat+", radius:"+(object3d as aTypes[i]).radius+"*_scale, fractures:"+(object3d as aTypes[i]).fractures+"});";							break;													case "GridPlane":							meshString += constructinsert+"{"+nameinsert+wirematinsert+", width:"+(object3d as aTypes[i]).width+"*_scale, height:"+(object3d as aTypes[i]).height+", segmentsW:"+(object3d as aTypes[i]).segmentsW+", segmentsH:"+(object3d as aTypes[i]).segmentsH+" });";							break;													case "Skybox":							meshString += constructinsert+"null,null,null,null,null,null);";							break;													case "Skybox6":							meshString += constructinsert+"null);";							break;					}										meshString += "\n\t\t\t"+objname+".position= new Vector3D("+xpos+","+ypos+","+zpos+");";					meshString += "\n\t\t\toList.push("+objname+");";										if(containerid != -1){						meshString += "\n\t\t\taC["+containerid+"].addChild("+objname+");\n";					} else{						meshString += "\n\t\t\taddChild("+objname+");\n";					}								} else {					useMesh = true;					var aF:Array = [];					var MaV:Array = [];					var MaVt:Array = [];										meshString +="\t\t\tvar m"+objcount+":Matrix3D = new Matrix3D(new Vector.<Number>([";					 					meshString += object3d.transform.rawData[0]+","+object3d.transform.rawData[1]+","+object3d.transform.rawData[2]+",0,";					meshString += object3d.transform.rawData[4]+","+object3d.transform.rawData[5]+","+object3d.transform.rawData[6]+",0,";					meshString += object3d.transform.rawData[8]+","+object3d.transform.rawData[9]+","+object3d.transform.rawData[10]+",0";					meshString += ",("+object3d.transform.rawData[12]+"*_scale),("+object3d.transform.rawData[13]+"*_scale),("+object3d.transform.rawData[14]+"*_scale),1]));\n";					meshString += "\t\t\tm"+objcount+".position = new Vector3D("+object3d.x+","+(-object3d.y)+","+object3d.z+");\n";										/*if(object3d.rotationX != 0 || object3d.rotationY != 0 || object3d.rotationZ != 0){						meshString += "\t\t\tm"+objcount+".rotation = new Vector3D("+(-object3d.rotationX)+","+(-object3d.rotationY)+","+(-object3d.rotationZ)+");\n";					}*/					var sortType:String = ((object3d as Mesh).pushfront)? "FRONT": ((object3d as Mesh).pushback)? "BACK":"CENTER";					meshString += "\t\t\tobjs.obj"+objcount+" = {"+nameinsert+" transform:m"+objcount+",  container:"+containerid+", bothsides:"+(object3d as Mesh).bothsides+", material:"+mat+", sortType:SortType."+sortType+"};\n";										var aFaces:Vector.<Face> = (object3d as Mesh).faces;					var geometry:Geometry = (object3d as Mesh).geometry;					var va:int;					var vb:int;					var vc:int;					var vta:int;					var vtb:int;					var vtc:int;					var tmp:Vector3D = new Vector3D();					var j:int;					var aRef:Array = [vc, vb, va];					//var animated:Boolean = ((object3d as Mesh).geometry.frames != null)? true : false;					var face:Face;					var geoIndex:int;										if ((geoIndex = checkGeometry(geometry)) != -1) {						meshString +="\n\t\t\tobjs.obj"+objcount+".geo=geos["+geoIndex+"];\n";					} else {												geoIndex = geos.length;						geos.push(geometry);												for(i = 0; i<aFaces.length ; ++i)						{							face = aFaces[i];							geonums[face] = geoIndex;							facenums[face] = i;														for(j=0;j<3;++j){								tmp.x =  face.vertices[j].x;								tmp.y =  face.vertices[j].y;								tmp.z =  face.vertices[j].z;								aRef[j] = checkDoubles( MaV, (tmp.x.toFixed(4)+"/"+tmp.y.toFixed(4)+"/"+tmp.z.toFixed(4)) );							}														vta = checkDoubles( MaVt, face.uvs[0].u +"/"+ face.uvs[0].v);							vtb = checkDoubles( MaVt, face.uvs[1].u +"/"+ face.uvs[1].v);							vtc = checkDoubles( MaVt, face.uvs[2].u +"/"+ face.uvs[2].v);														aF.push( aRef[0].toString(16)+","+aRef[1].toString(16)+","+aRef[2].toString(16)+","+vta.toString(16)+","+vtb.toString(16)+","+vtc.toString(16));							}												geoString += "\t\t\tvar geo"+geoIndex+":Object = {};\n";						geoString += "\t\t\tgeo"+geoIndex+".aVstr=\""+encode( MaV.toString() )+"\";\n";						geoString += "\t\t\tgeo"+geoIndex+".aUstr=\""+encode( MaVt.toString() )+"\";\n";						geoString += "\t\t\tgeo"+geoIndex+".aV= read(geo"+geoIndex+".aVstr).split(\",\");\n";						geoString += "\t\t\tgeo"+geoIndex+".aU= read(geo"+geoIndex+".aUstr).split(\",\");\n";						geoString += "\t\t\tgeo"+geoIndex+".f=\""+aF.toString()+"\";\n";						geoString += "\t\t\tgeos.push(geo"+geoIndex+");\n";												meshString +="\n\t\t\tobjs.obj"+objcount+".geo=geos["+geoIndex+"];\n";						 						//desabled for now						/*if(animated) {							readVertexAnimation((object3d as Mesh), "objs.obj"+objcount);						}*/					}			}			objcount ++;		}				private function encode(str:String):String		{			var start:int= 0;			var chunk:String;			var encstr:String = "";			var charcount:int = str.length;			for(var i:int = 0;i<charcount;++i){				if (str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && str.charCodeAt(i)!= 48 ){					start = i;					chunk = "";					while(str.charCodeAt(i)>=48 && str.charCodeAt(i)<= 57 && i<=charcount){						i++;					}					chunk = Number(str.substring(start, i)).toString(16);					encstr+= chunk;					i--;				} else{					encstr+= str.substring(i, i+1);				}			}			return encstr.replace(p1,"/0/");		}		/*		private function readVertexAnimation(obj:Mesh, id:String):void		{			isAnim = true;			meshString +="\n\t\t\tobjs.obj"+objcount+".meshanimated=true;\n";						var tmpnames:Array = [];			var i:int = 0;			var j:int = 0;			var fr:Frame;			var avp:Array;			var afn:Array = [];			//reset names in logical sequence			for (var framename:String in obj.geometry.framenames){				tmpnames.push(framename);			}			tmpnames.sort(); 			var myPattern:RegExp = new RegExp(" ","g");						for (i = 0;i<tmpnames.length;++i){				avp = [];				fr = obj.geometry.frames[obj.geometry.framenames[tmpnames[i]]];				if(tmpnames[i].indexOf(" ") != -1) tmpnames[i] = tmpnames[i].replace(myPattern,"");				afn.push("\""+tmpnames[i]+"\"");				meshString += "\n\t\t\t"+id+".fr"+tmpnames[i]+"=[";								for(j = 0; j<fr.vertexpositions.length ;++j){						avp.push(fr.vertexpositions[j].x.toFixed(1));						avp.push(fr.vertexpositions[j].y.toFixed(1));						avp.push(fr.vertexpositions[j].z.toFixed(1)); 				}				meshString += avp.toString()+"];\n";			}			//restore right sequence voor non sync md2 files			fr = obj.geometry.frames[obj.geometry.framenames[tmpnames[0]]];			var verticesorder:Array = fr.getIndexes(obj.vertices);			var indexes:Array = [];			var face:Face;			var ox:Number;			var oy:Number;			var oz:Number;			var ind:int = 0;			var k:int;			var tmpval:Number = -1234567890;			for(i = 0; i<obj.faces.length ; ++i)			{				face = obj.faces[i];				for(j=2;j>-1;--j){					ox = face["v"+j].x;					oy = face["v"+j].y;					oz = face["v"+j].z;					ind = 0;					face["v"+j].x = tmpval;					face["v"+j].y = tmpval;					face["v"+j].z = tmpval;					for(k= 0;k<obj.vertices.length;++k){						if( obj.vertices[k].x == tmpval && obj.vertices[k].y == tmpval && obj.vertices[k].z == tmpval){ 							ind = k;							break;						}					}					face["v"+j].x = ox;					face["v"+j].y = oy;					face["v"+j].z = oz;					indexes.push(ind);				}			}						meshString += "\n\t\t\t"+id+".indexes=["+indexes.toString()+"];\n";			meshString += "\n\t\t\t"+id+".fnarr = ["+afn.toString()+"];\n";		}				private function checkUnicV(arr:Array, v:Vertex, mesh:Mesh):int		{			for(var i:int = 0;i<arr.length;++i){				if(v === arr[i].vertex){					return arr[i].index;				}			}			var id:int;			for(i = 0;i<mesh.vertices.length;++i){				if(v == mesh.vertices[i]){					id = i;					break;				}			}			arr.push({vertex:v, index:id});			 			return id;		}		//to be replaced by the checkdouble code		private function checkUnicUV(arr:Array, uv:UV, mesh:Mesh):int		{			for(var i:int = 0;i<arr.length;++i){				if(uv === arr[i]) return i;			}			arr.push(uv);			return int(arr.length-1);		}		*/		private function checkDoubles(arr:Array, string:String):int		{			for(var i:int = 0;i<arr.length;++i)				if(arr[i] == string) return i;			 			arr.push(string);			return arr.length-1;		}				private function checkGeometry(geometry:Geometry):int		{			for (var i:String in geos)				if (geos[i] == geometry)					return Number(i);						return -1;		}				private  function parse(object3d:Object3D, containerid:int = -1):void		{			if(object3d is ObjectContainer3D){				var obj:ObjectContainer3D = (object3d as ObjectContainer3D);								var id:int = gcount;								if(containerid != -1){					containerString +="\n\t\t\tvar cont"+id+":ObjectContainer3D = new ObjectContainer3D();\n";					containerString +="\t\t\taC.push(cont"+id+");\n";					if (containerid == 0)						containerString +="\t\t\taddChild(cont"+id+");\n";					else						containerString +="\t\t\tcont"+containerid+".addChild(cont"+id+");\n";										containerString +="\t\t\tvar m"+id+":Matrix3D = new Matrix3D(new Vector.<Number>([";					containerString += obj.transform.rawData[0]+","+obj.transform.rawData[1]+","+obj.transform.rawData[2]+",0,";					containerString += obj.transform.rawData[4]+","+obj.transform.rawData[5]+","+obj.transform.rawData[6]+",0,";					containerString += obj.transform.rawData[8]+","+obj.transform.rawData[9]+","+obj.transform.rawData[10]+",0";					containerString += ",("+obj.transform.rawData[12]+"*_scale),("+obj.transform.rawData[13]+"*_scale),("+obj.transform.rawData[14]+"*_scale),1]));\n";					containerString +="\t\t\tm"+id+".position = new Vector3D("+obj.x+","+(-obj.y)+","+obj.z+");\n";					if(obj.rotationX != 0 || obj.rotationY != 0 || obj.rotationZ != 0){						containerString += "\t\t\tm"+id+".rotation = new Vector3D("+(-obj.rotationX)+","+(-obj.rotationY)+","+(-obj.rotationZ)+");\n";					}					containerString +="\t\t\tcont"+id+".transform.matrix3D = m"+id+";\n";					 					if(obj.name != null) containerString +="\t\t\tcont"+id+".name = \""+obj.name+"\";\n";									}else{					containerString +="\t\t\taC.push(this);\n";					containerString +="\t\t\tvar m"+id+":Matrix3D = new Matrix3D(new Vector.<Number>([";					containerString += obj.transform.rawData[0]+","+obj.transform.rawData[1]+","+obj.transform.rawData[2]+",0,";					containerString += obj.transform.rawData[4]+","+obj.transform.rawData[5]+","+obj.transform.rawData[6]+",0,";					containerString += obj.transform.rawData[8]+","+obj.transform.rawData[9]+","+obj.transform.rawData[10]+",0";					containerString += ",("+obj.transform.rawData[12]+"*_scale),("+obj.transform.rawData[13]+"*_scale),("+obj.transform.rawData[14]+"*_scale),1]));\n";					containerString +="\t\t\tm"+id+".position = new Vector3D("+obj.x+","+(-obj.y)+","+obj.z+");\n";					if(obj.rotationX != 0 || obj.rotationY != 0 || obj.rotationZ != 0){						containerString += "\t\t\tm"+id+".rotation = new Vector3D("+(-obj.rotationX)+","+(-obj.rotationY)+","+(-obj.rotationZ)+");\n";					}					containerString +="\t\t\ttransform.matrix3D = m"+id+";\n";					 					if (obj.name != null) containerString +="\t\t\tname = \""+obj.name+"\";\n";					}								gcount++;								for(var i:int =0;i<obj.children.length;i++){					if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i], id);					} else{												if(object3d.name != null)							object3d.name = object3d.name.toLowerCase();						write( obj.children[i], id);					}				}								/*if (containerid != -1) {									} else {										if (obj.materialLibrary != null) {						materialString +="\t\t\tmaterialLibrary = new MaterialLibrary();\n";						for each (var materialData:MaterialData in obj.materialLibrary) {							materialString +="\t\t\tvar mData_"+mcount+":MaterialData = materialLibrary.addMaterial(\""+materialData.name+"\");\n";							materialString +="\t\t\tmData_"+mcount+".materialType = \""+materialData.materialType+"\";\n";							materialString +="\t\t\tmData_"+mcount+".ambientColor = "+materialData.ambientColor+";\n";							materialString +="\t\t\tmData_"+mcount+".diffuseColor = "+materialData.diffuseColor+";\n";							materialString +="\t\t\tmData_"+mcount+".shininess = "+materialData.shininess+";\n";							materialString +="\t\t\tmData_"+mcount+".specularColor = "+materialData.specularColor+";\n";							materialString +="\t\t\tmData_"+mcount+".textureFileName = \""+materialData.textureFileName+"\";\n";							materialString +="\t\t\tvar mElements_"+mcount+":Array = mData_"+mcount+".elements;\n";							for each (var element:Element in materialData.elements) {								if (geonums[element] != null && facenums[element] != null)									materialString +="\t\t\tmElements_"+mcount+".push(geos["+geonums[element]+"].geometry.faces["+facenums[element]+"]);\n";							}							materialString +="\t\t\t\n";							mcount++;						}					}				}*/				 			} else {				if(object3d.name != null)					object3d.name = object3d.name.toLowerCase();				write( object3d, -1);			}		}				/**		* Class generates a string in the Actionscript3 format for Away3DLite, representing the object3D(s).		*/				function AS3LiteExporter(){}				/**		* Generates a string in the Actionscript3 format for Away3DLite, representing the object3D(s).		* The event onComplete, returns in event.data the generated class string.		*		* @param	object3d				Object3D. The Object3D to be exported to the AS3 format.		* @param	classname				Defines the class name used in the output string. 		* @param	packagename			[optional] Defines the package name used in the output string. Defaults to no package.		* 		* Generated class example of use:		* Example: var myClass:ClassName = new ClassName();		* view.scene.addChild(myClass as Object3D); or casted as Mesh if the generated class extends Mesh in case of single meshes		* 		* To access the objects stored into the class:		* - ClassName.containers, a getter returns the ObjectContainers3D Array.		* - ClassName.meshes, a getter returns the Mesh Array.		* 		*   To access a mesh in the meshes array to change a material		*   (ClassName.meshes[0] as Mesh).material = myNewMat;		*/				public function export(object3d:Object3D, classname:String, packagename:String = ""):void		{						if(hasEventListener(ExporterEvent.COMPLETE)){				reset();								asString = "//AS3LiteExporter version 1.1, Flash 10 Away3DLite, generated by Away3D: http://www.away3d.com\n";			 				asString += "package "+packagename+"\n{\n\timport away3dlite.arcane;\n\timport away3dlite.containers.*;\n\timport away3dlite.materials.*;\n\timport away3dlite.core.base.*;\n\timport away3dlite.primitives.*;\n\timport flash.geom.Matrix3D;\n\timport flash.geom.Vector3D;\n\n\tuse namespace arcane;\n\n";				parse(object3d);								if (!gcount)					asString += "\tpublic class "+classname+" extends Mesh\n\t{\n";				else 					asString += "\tpublic class "+classname+" extends ObjectContainer3D\n\t{\n";				 				asString += "\t\tprivate var objs:Object = {};\n\t\tprivate var geos:Array = [];\n\t\tprivate var oList:Array =[];\n\t\tprivate var aC:Array;\n\t\tprivate var aV:Array;\n\t\tprivate var aU:Array;\n\t\tprivate var _scale:Number;\n\n";				asString += "\t\tpublic function "+classname+"(scaling:Number = 1)\n\t\t{\n\t\t\t_scale = scaling;\n\t\t\tsetSource();\n\t\t\taddContainers();\n\t\t\tbuildMeshes();\n\t\t\tbuildMaterials();\n\t\t\tcleanUp();\n\t\t}\n\n";				asString += "\t\tprivate function buildMeshes():void\n\t\t{\n";				asString += meshString;								if(useMesh){					asString += "\n\t\t\tvar ref:Object;";					asString += "\n\t\t\tvar mesh:Mesh;";					asString += "\n\t\t\tvar j:int;";					asString += "\n\t\t\tvar av:Array;";					asString += "\n\t\t\tvar au:Array;";					asString += "\n\t\t\tvar aRef:Array;";					/*asString += "\n\t\t\tvar vertices:Vector.<Number>;";					asString += "\n\t\t\tvar uvtData:Vector.<Number>;";					asString += "\n\t\t\tvar indices:Vector.<int>;";*/					asString += "\n\t\t\tvar index:int;\n";										var keymesh:String = (containerString != "")? "mesh." : "";					 					asString += "\n\t\t\tfor(var i:int = 0;i<"+objcount+";++i){";					asString += "\n\t\t\t\tref = objs[\"obj\"+i];";					asString += "\n\t\t\t\tindex = 0;";					asString += "\n\t\t\t\tif(ref != null){";										if(containerString != "")						asString += "\n\t\t\t\t\tmesh = new Mesh();";										asString += "\n\t\t\t\t\t"+keymesh+"type = \"AS3LiteExport\"";					asString += "\n\t\t\t\t\t"+keymesh+"bothsides = ref.bothsides;";					asString += "\n\t\t\t\t\t"+keymesh+"sortType = ref.sortType;";					asString += "\n\t\t\t\t\t"+keymesh+"name = ref.name;";					asString += "\n\t\t\t\t\t"+keymesh+"transform.matrix3D = ref.transform;\n";					asString += "\n\t\t\t\t\tif(ref.material != null)";					asString += "\n\t\t\t\t\t\t"+keymesh+"material = ref.material;\n";										if(containerString != ""){						asString += "\n\t\t\t\t\tif(ref.container != -1)";						asString += "\n\t\t\t\t\t\taC[ref.container].addChild(mesh);\n";					}							asString += "\n\t\t\t\t\toList.push(mesh);\n";							 					/*asString += "\n\t\t\t\t\tvertices= new Vector.<Number>();";					asString += "\n\t\t\t\t\tuvtData = new Vector.<Number>();";					asString += "\n\t\t\t\t\tindices = new Vector.<int>();\n";*/							 					asString += "\n\t\t\t\t\taRef = ref.geo.f.split(\",\");\n";												asString += "\n\t\t\t\t\tfor(j = 0;j<aRef.length;j+=6){";					asString += "\n\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j], 16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_vertices.push(Number(parseFloat(av[0]))*_scale, -Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);";					asString += "\n\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j+1],16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_vertices.push(Number(parseFloat(av[0]))*_scale, -Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);";					asString += "\n\t\t\t\t\t\tav = ref.geo.aV[parseInt(aRef[j+2],16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_vertices.push(Number(parseFloat(av[0]))*_scale, -Number(parseFloat(av[1]))*_scale, Number(parseFloat(av[2]))*_scale);\n";					asString += "\n\t\t\t\t\t\t"+keymesh+"_indices.push(index, index+1, index+2);";					asString += "\n\t\t\t\t\t\t"+keymesh+"_faceLengths.push(3);";					asString += "\n\t\t\t\t\t\tindex+=3;\n";					asString += "\n\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+3],16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_uvtData.push(parseFloat(au[0]), 1-parseFloat(au[1]), 0);";					asString += "\n\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+4],16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_uvtData.push(parseFloat(au[0]), 1-parseFloat(au[1]), 0);";					asString += "\n\t\t\t\t\t\tau = ref.geo.aU[parseInt(aRef[j+5],16)].split(\"/\");";					asString += "\n\t\t\t\t\t\t"+keymesh+"_uvtData.push(parseFloat(au[0]), 1-parseFloat(au[1]), 0);";					asString += "\n\t\t\t\t\t}\n";					asString += "\n\t\t\t\t\t"+keymesh+"buildFaces();\n";					asString += "\n\t\t\t\t}";					asString += "\n\t\t\t}";					asString += "\n\t\t}\n";	 					asString += "\n\n\t\tprivate function setSource():void\n\t\t{\n";					asString += geoString;					asString += "\t\t}";				} else{					asString += "\t\t}";					asString += "\n\n\t\tprivate function setSource():void\n\t\t{}\n";				}				asString += "\n\n\t\tprivate function buildMaterials():void\n\t\t{";				asString += materialString;				asString += "\n\t\t}";				asString += "\n\t\tprivate function cleanUp():void\n\t\t{";				asString += "\n\t\t\tfor(var i:int = 0;i<"+objcount+";++i){\n\t\t\t\tobjs[\"obj\"+i] == null;\n\t\t\t}\n\t\t\taV = null;\n\t\t\taU = null;\n\t\t}";								/*if(isAnim){					asString += "\n\n\t\tprivate function setMeshAnim(mesh:Mesh, obj:Object, id:int):void\n\t\t{\n";					asString += "\n\t\t\ttrace(\"\\nAnimation frames prefixes for : this.meshes[\"+id+\"]\");";					asString += "\n\t\t\tmesh.geometry.frames = new Dictionary();";					asString += "\n\t\t\tmesh.geometry.framenames = new Dictionary();";					asString += "\n\t\t\tvar y:int;\n";					asString += "\t\t\tvar z:int;\n";					asString += "\t\t\tvar frame:Frame;\n";					asString += "\t\t\tvar vp:VertexPosition;\n";					asString += "\t\t\tfor(var i:int = 0;i<obj.fnarr.length; ++i){\n";					asString += "\t\t\t\ttrace(\"[ \"+obj.fnarr[i]+\" ]\");\n";					asString += "\t\t\t\tframe = new Frame();\n";					asString += "\t\t\t\tmesh.geometry.framenames[obj.fnarr[i]] = i;\n";					asString += "\t\t\t\tmesh.geometry.frames[i] = frame;\n";					asString += "\t\t\t\tz=0;\n";					asString += "\t\t\t\tfor (y = 0; y < obj[\"fr\"+obj.fnarr[i]].length; y+=3){\n";					asString += "\t\t\t\t\tvp = new VertexPosition(mesh.vertices[z]);\n";					asString += "\t\t\t\t\tz++;\n";					asString += "\t\t\t\t\tvp.x = obj[\"fr\"+obj.fnarr[i]][y]*_scale;\n";					asString += "\t\t\t\t\tvp.y = obj[\"fr\"+obj.fnarr[i]][y+1]*_scale;\n";					asString += "\t\t\t\t\tvp.z = obj[\"fr\"+obj.fnarr[i]][y+2]*_scale;\n";					asString += "\t\t\t\t\tframe.vertexpositions.push(vp);\n";					asString += "\t\t\t\t}\n";					asString += "\t\t\t\tif (i == 0)\n";					asString += "\t\t\t\t\tframe.adjust();\n";					asString += "\t\t\t}\n";					asString += "\t\t}";				}*/												if(containerString != ""){					asString += "\n\n\t\tprivate function addContainers():void\n\t\t{\n";					asString += "\t\t\taC = [];\n";					asString += containerString;					asString += "\t\t}";					asString += "\n\n\t\tpublic function get containers():Array\n\t\t{\n";					asString += "\t\t\treturn aC;\n";					asString += "\t\t}\n";									} else{					 asString += "\n\n\t\tprivate function addContainers():void\n\t\t{}\n";				}								asString += "\n\n\t\tpublic function get meshes():Array\n\t\t{\n";				asString += "\t\t\treturn oList;\n\t\t}\n";								asString += "\n\n\t\tprivate function read(str:String):String\n\t\t{\n";				asString += "\t\t\tvar start:int= 0;\n";				asString += "\t\t\tvar chunk:String;\n";				asString += "\t\t\tvar end:int= 0;\n";				asString += "\t\t\tvar dec:String = \"\";\n";				asString += "\t\t\tvar charcount:int = str.length;\n";				asString += "\t\t\tfor(var i:int = 0;i<charcount;++i){\n";				asString += "\t\t\t\tif (str.charCodeAt(i)>=44 && str.charCodeAt(i)<= 48 ){";				asString += "\n\t\t\t\t\tdec+= str.substring(i, i+1);";				asString += "\n\t\t\t\t}else{";				asString += "\n\t\t\t\t\tstart = i;";				asString += "\n\t\t\t\t\tchunk = \"\";";				asString += "\n\t\t\t\t\twhile(str.charCodeAt(i)!=44 && str.charCodeAt(i)!= 45 && str.charCodeAt(i)!= 46 && str.charCodeAt(i)!= 47 && i<=charcount){";				asString += "\n\t\t\t\t\t\ti++;";				asString += "\n\t\t\t\t\t}";				asString += "\n\t\t\t\t\tchunk = \"\"+parseInt(\"0x\"+str.substring(start, i), 16 );";				asString += "\n\t\t\t\t\tdec+= chunk;";				asString += "\n\t\t\t\t\ti--;";				asString += "\n\t\t\t\t}\n";				asString += "\t\t\t}\n";				asString += "\t\t\treturn dec;";				asString += "\n\t\t}\n";				asString += "\n\t}\n}";								var EE:ExporterEvent = new ExporterEvent(ExporterEvent.COMPLETE);				EE.data = asString;				dispatchEvent(EE);							} else {				trace("AS3LiteExporter Error:\nNo ExporterEvent.COMPLETE event set.\nUse the method addOnExportComplete(myfunction) before use export();\n");			}		}				/**		 * Default method for adding a complete event listener		 * The event.data holds the generated string from the wavefront class		 * 		 * @param	listener		The listener function		 */		public function addOnExportComplete(listener:Function):void        {			addListener(this, ExporterEvent.COMPLETE, listener, false, 0, false);        }		/**		 * Default method for removing a complete event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnExportComplete(listener:Function):void        {            removeListener(ExporterEvent.COMPLETE, listener, false);        }		/**		 * Returns the last generated as3 file async from events.		 */		public function get as3File():String		{			return asString;		}			}}