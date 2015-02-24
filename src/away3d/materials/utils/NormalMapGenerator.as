﻿package away3d.materials.utils{   	import flash.display.*;	import flash.events.*;	import flash.filters.*;	import flash.geom.*;	import flash.utils.*;		import away3d.arcane;	import away3d.core.base.*;	import away3d.events.*;	import away3d.materials.utils.data.*;	 	use namespace arcane;		/**	 * Dispatched while the class is busy tracing. Note that the source can already be used for a Material	 * 	 * @eventType away3d.events.TraceEvent	 */	[Event(name="tracecomplete",type="away3d.events.TraceEvent")]    	/**	 * Dispatched full trace is done.	 * 	 * @eventType away3d.events.TraceEvent	 */	[Event(name="traceprogress",type="away3d.events.TraceEvent")]	  	public class NormalMapGenerator extends EventUtil{				private var _width:uint;		private var _height:uint;		private var _normalMap:BitmapData;		private var _lines:Array;		private var _bumpMap:BitmapData;		private var _state:int = 0;		private var _step:int = 50;		private var n0:Vector3D = new Vector3D();		private var n1:Vector3D = new Vector3D();		private var n2:Vector3D = new Vector3D();		private var intPt0:Point = new Point();		private var intPt1:Point = new Point();		private var intPt2:Point = new Point();		private var rect:Rectangle = new Rectangle(0,0,1,1);		private var _canceled:Boolean;		 		private function generate(from:int, to:int):void		{			var i:int;			var j:int;						var p0:Point;			var p1:Point;			var p2:Point;			 			var col0r:int;			var col0g:int;			var col0b:int;			var col1r:int;			var col1g:int;			var col1b:int;			var col2r:int;			var col2g:int;			var col2b:int;						var line0:Array;			var line1:Array;			var line2:Array;						var per0:Number;			var per1:Number;			var per2:Number;						var face:Face;			var fn:Vector3D;			var row:int;			var s:int;			var e:int;						 			var colorpt:Point = new Point();						function meet(pt:Point, x1:int,  y1:int, x2:int, y2:int, x3:int, y3:int, x4:int, y4:int):Point			{ 				var d:int = (x1-x2)*(y3-y4) - (y1-y2)*(x3-x4);				if (d == 0)  return null;								pt.x = ((x3-x4)*(x1*y2-y1*x2)-(x1-x2)*(x3*y4-y3*x4))/d;				pt.y = ((y3-y4)*(x1*y2-y1*x2)-(y1-y2)*(x3*y4-y3*x4))/d;								return pt;			} 						function applyColorAt(x:int, y:int):void			{				if(_normalMap.getPixel(x, y) == 0){					colorpt.x = x;					colorpt.y = y;					 					var cross0:Point = meet(intPt0, line1[0].x,line1[0].y, line1[1].x, line1[1].y, p0.x, p0.y, x, y);					var cross1:Point = meet(intPt1, line2[0].x,line2[0].y, line2[1].x, line2[1].y, p1.x, p1.y, x, y);					var cross2:Point = meet(intPt2, line0[0].x,line0[0].y, line0[1].x, line0[1].y, p2.x, p2.y, x, y);					 					per0 = (cross0 == null)? 1 : Point.distance(cross0, colorpt) / Point.distance(p0, cross0 ) ; 					per1 = (cross1 == null)? 1 : Point.distance(cross1, colorpt) / Point.distance(p1, cross1 ) ;					per2 = (cross2 == null)? 1 : Point.distance(cross2, colorpt) / Point.distance(p2, cross2 ) ;										if(per0+per1+per2 < 1.2){						var r:int =  (per0*col0r) + (per1*col1r) + (per2*col2r);						r = (r>255)? 255 : r;						r = invertX? 255-r : r;						var g:int = (per0*col0g) + (per1*col1g) + (per2*col2g);						var b:int = (per0*col0b) + (per1*col1b) + (per2*col2b);												_normalMap.setPixel(x, y,	r << 16 | 																((g>255)? 255 : g)  << 8 | 																((b>255)? 255 : b) );					}				}			}						if(_normalMap != null)				_normalMap.lock();						for(i = from;i<to;++i){								if(_canceled)					break;									face = mesh.faces[i];				fn = face.parent.getFaceNormal(face);				n0 = averageNormals(face.vertices[0], n0, fn);				p0 = new Point( face.uvs[0].u * _width,  (1 - face.uvs[0].v) * _height);				col0r = 255 - ((127*n0.x)+127);			 	col0g = 255 - ((127*n0.y)+127);			 	col0b = (127*n0.z)+127;				 				n1 = averageNormals(face.vertices[1], n1, fn);				p1 = new Point( face.uvs[1].u * _width ,  (1 - face.uvs[1].v) * _height);				col1r = 255 - ((127*n1.x)+127);			 	col1g = 255 - ((127*n1.y)+127);			 	col1b = (127*n1.z)+127;				 				n2 = averageNormals(face.vertices[2], n2, fn);				p2 = new Point( face.uvs[2].u * _width , (1 - face.uvs[2].v) * _height);				col2r = 255 - ((127*n2.x)+127);			 	col2g = 255 - ((127*n2.y)+127);			 	col2b = (127*n2.z)+127;								_lines = [];								p0.x = Math.ceil(p0.x);				p1.x = Math.ceil(p1.x);				p2.x = Math.ceil(p2.x);								p0.y = Math.ceil(p0.y);				p1.y = Math.ceil(p1.y);				p2.y = Math.ceil(p2.y);								setBounds(p0.x, p0.y, p1.x, p1.y, col0r, col0g, col0b, col1r, col1g, col1b, Point.distance(p0, p1));				setBounds(p1.x, p1.y, p2.x, p2.y, col1r, col1g, col1b, col2r, col2g, col2b, Point.distance(p1, p2));				setBounds(p2.x, p2.y, p0.x, p0.y, col2r, col2g, col2b, col0r, col0g, col0b, Point.distance(p2, p0));				 				line0 = [p0, p1];			 	line1 = [p1, p2];				line2 = [p2, p0];				 				_lines.sortOn("y", 16);								row = 0;				rect.x = _lines[0].x;				rect.y = _lines[0].y;				rect.width = 1;								for(j = 0;j < _lines.length; ++j)				{					if(row == _lines[j].y ){						if(s > _lines[j].x){							s = _lines[j].x;							rect.x = s;						} 						if(e < _lines[j].x){							e = _lines[j].x;						}						rect.width = e-s;						 					} else{						//if(rect.width> 1){//2						for(var k:int = rect.x;k<rect.x+rect.width;++k){//k = rect.x+1+1							applyColorAt(k, rect.y);						}						//}						s = _lines[j].x;						e = _lines[j].x;						row = _lines[j].y;						rect.x = _lines[j].x;						rect.y = _lines[j].y;						rect.width =1;					}				}				 				for(j = 0;j< _lines.length; ++j)				{					if(_lines[j].color !=0){						_normalMap.setPixel(_lines[j].x, _lines[j].y, _lines[j].color);						_lines[j] = null;					}				}				  			}									var te:TraceEvent;						if(!_canceled){				_normalMap.unlock();				_state = i;											if(_state == mesh.faces.length){					 					if(growPixels)						grow();					 					if(heightMap != null) 							applyBump(heightMap, _normalMap);												if(blur != 0)						applyBlur(_normalMap);					 					_lines = null;										if(hasEventListener(TraceEvent.TRACE_COMPLETE)){						te = new TraceEvent(TraceEvent.TRACE_COMPLETE);						te.percent = 100;						dispatchEvent(te);					}									} else{										if(hasEventListener(TraceEvent.TRACE_PROGRESS)){						te = new TraceEvent(TraceEvent.TRACE_PROGRESS);						te.percent = (_state / mesh.faces.length) *100;						dispatchEvent(te);					}										setTimeout(generate, 1, _state, (_state+_step>mesh.faces.length )? mesh.faces.length : _state+_step);				}							} else{				trace("XXXXXXX trace normalmap canceled XXXXXXX");			}					}				private function applyBlur(map:BitmapData):void		{				var bf:BlurFilter = new BlurFilter(blur, blur);				var pt:Point = new Point(0,0);				map.applyFilter(map, map.rect, pt ,bf);				bf = null;				pt = null;		}		 		private function averageNormals(v:Vertex, n:Vector3D, fn:Vector3D):Vector3D		{			n.x = 0;			n.y = 0;			n.z = 0;			var m0:int = 0;			var m1:int = 0;			var m2:int = 0;			var f:Face;			var norm:Vector3D;			var v0:Vertex;			var v1:Vertex;			var v2:Vertex;						for(var i:int = 0;i<mesh.faces.length;++i){				f = mesh.faces[i];				v0 = f.vertices[0];				v1 = f.vertices[1];				v2 = f.vertices[2];				if((v0.x == v.x && v0.y == v.y && v0.z == v.z) || (v1.x == v.x && v1.y == v.y && v1.z == v.z )|| (v2.x == v.x && v2.y == v.y && v2.z == v.z)){					norm = f.parent.getFaceNormal(f);										if((Math.max(fn.x, norm.x) - Math.min(fn.x, norm.x) < .8)){						n.x += norm.x;						m0++;					}										if((Math.max(fn.y, norm.y) - Math.min(fn.y, norm.y) < .8)){						n.y += norm.y;						m1++;					}										if(normalMapType == NormalMapType.OBJECT_SPACE) {						if((Math.max(fn.z, norm.z) - Math.min(fn.z, norm.z) < .8)){							n.z += norm.z;							m2++;						}					} else{						n.z ++;						m2++;					}				}			}			 			n.x /= m0;			n.y /= m1;			n.z /= m2;						n.normalize();			 			return n;		}		 		private function setBounds(x1:int,y1:int,x2:int,y2:int, r0:Number, g0:Number, b0:Number, r1:Number, g1:Number, b1:Number, dist:Number):void		{			var line:Array = [x1, y1];			var dist2:Number;			var scale:Number;			var invscl:Number = 1-scale;						var r:Number;			var g:Number;			var b:Number;				 			_lines[_lines.length] = new LScan(x1, y1,  r0 << 16| g0 << 8| b0);			_lines[_lines.length] = new LScan(x2, y2,  r1 << 16| g1 << 8| b1);						var error:int;			var dx:int;			var dy:int;			if (x1 > x2) {				var tmp:int = x1;				x1 = x2;				x2 = tmp;				tmp = y1;				y1 = y2;				y2 = tmp;			}			dx = x2 - x1;			dy = y2 - y1;			var yi:int = 1;			if (dx < dy) {				x1 ^= x2;				x2 ^= x1;				x1 ^= x2;				y1 ^= y2;				y2 ^= y1;				y1 ^= y2;			}			if (dy < 0) {				dy = -dy;				yi = -yi;			}			if (dy > dx) {				error = -(dy >> 1);				for (; y2 < y1; ++y2) {					dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));					scale = dist2/dist;					r =  (r1*scale)+(r0*invscl);					g =  (g1*scale)+(g0*invscl);					b =  (b1*scale)+(b0*invscl);					_lines[_lines.length] = new LScan(x2, y2,  r << 16| g << 8| b);					error += dx;					if (error > 0) {						x2 += yi;						dist2 = Math.sqrt((x2 - line[0]) * (x2 - line[0]) + (y2 - line[1]) * (y2 - line[1]));						scale = dist2/dist;						r =  (r1*scale)+(r0*invscl);						g =  (g1*scale)+(g0*invscl);						b =  (b1*scale)+(b0*invscl);						_lines[_lines.length] = new LScan(x2, y2,  r << 16| g << 8| b);						error -= dy;					}				}			} else {				error = -(dx >> 1);				for (; x1 < x2; ++x1) {					dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));					scale = dist2/dist;					r =  (r1*scale)+(r0*invscl);					g =  (g1*scale)+(g0*invscl);					b =  (b1*scale)+(b0*invscl);					_lines[_lines.length] = new LScan(x1, y1,  r << 16| g << 8| b);					error += dy;					if (error > 0) {						y1 += yi;						dist2 = Math.sqrt((x1 - line[0]) * (x1 - line[0]) + (y1 - line[1]) * (y1 - line[1]));						scale = dist2/dist;						r =  (r1*scale)+(r0*invscl);						g =  (g1*scale)+(g0*invscl);						b =  (b1*scale)+(b0*invscl);						_lines[_lines.length] = new LScan(x1, y1,  r << 16| g << 8| b);						error -= dx;					}				}			}		}				private function grow():void		{			_normalMap = Grow.apply(_normalMap, 10);		}				/**		* Applys a bump to a given normal map. If you do not generate the map from a mesh, just pass null in the constructor.		*		* @param	bm						BitmapData. The source bumpmap.		* @param	nm						BitmapData. The source normalmap.		*		*@ return BitmapData. The source normalmap with the bump applied to it		*/		public function applyBump(bm:BitmapData, nm:BitmapData):BitmapData        {				if(nm.width != bm.width || nm.height != bm.height){					var gs:BitmapData = bm.clone();					var sclmat:Matrix = new Matrix();					var Wscl:Number = nm.width/gs.width;					var Hscl:Number = nm.height/gs.height;					sclmat.scale(Wscl, Hscl);					_bumpMap = new BitmapData(gs.width * Wscl, gs.height * Hscl, false, 0);					_bumpMap.draw(gs, sclmat, null, "normal", _bumpMap.rect, true);									} else{					_bumpMap = new BitmapData(bm.width, bm.height, false, 0x000000);					_bumpMap.copyPixels(bm, bm.rect, new Point(0,0));				}								var zero:Point = new Point(0,0);								var ct:ColorMatrixFilter = new ColorMatrixFilter([0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0,0.33,0.33,0.33,0,0]);				_bumpMap.applyFilter(_bumpMap, nm.rect, zero, ct);            	var cf:ConvolutionFilter = new ConvolutionFilter(3, 6, null, 1, 127);            	            	var dumX:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);            	cf.matrix = [0,0,0,-1,0,1,0,0,0];            	dumX.applyFilter(_bumpMap, nm.rect, zero, cf);            	_bumpMap.copyChannel(dumX, nm.rect, zero, 1, 1);            	            	var dumY:BitmapData = new BitmapData(nm.width, nm.height, false, 0x000000);            	cf.matrix = new Array(0,-1,0,0,0,0,0,1,0);            	dumY.applyFilter(_bumpMap, nm.rect, zero, cf);            	_bumpMap.copyChannel(dumY, nm.rect, zero, 2, 2);								dumX.dispose();				dumY.dispose();								var dp:DisplacementMapFilter = new DisplacementMapFilter();						dp.mapBitmap = _bumpMap;						dp.mapPoint = zero;						dp.componentX = 1;						dp.componentY = 2;						dp.scaleX =  -127;						dp.scaleY =  -127;						dp.mode = "wrap";						dp.color = 0;						dp.alpha = 0;				 				nm.applyFilter(nm, _bumpMap.rect, zero, dp);								return nm;        }				/**		 * The <code>Mesh</code> object to be traced.		 */		public var mesh:Mesh;				/**		 * An optional height map used with the normal map calculations		 */		public var heightMap:BitmapData;				/**		 * Defines the blur value applied to the normal map generated. Default is 0;		 */		public var blur:uint;				/**		 * Adds pixels at the edges of the trace to avoid artifacts cause by the pixel trace.		 */		public var growPixels:Boolean;				/**		 * The maximum amount of faces processed in a frame. To avoid that the Flash Player generating a timeout error, the class handles the trace of faces stepwize. Default is 50 faces.		 */		public var maxFaces:uint;				/**		 * Defines the type of normal map generated. Can be either object space or tangent space. Defaults to object space.		 * 		 * @see away3d.materials.utils.NormalMapType		 */		public var normalMapType:String;						/**		 * Set to true if the mesh was created using a righthanded system, inverting the x (red) information in the normal map.		 * 		 */		public var invertX:Boolean;				/**		 * The width of the generated normalmap. Default is 512.		 */		public function get width():uint		{			return _width;		}				public function set width(val:uint):void		{			_width = val;			_step = maxFaces * (1-(1/(2800/Math.max(_width, _height))));		}				/**		 * The height of the generated normalmap. Default is 512.		 */		public function get height():uint		{			return _height;		}				public function set height(val:uint):void		{			_height = val;			_step = maxFaces * (1-(1/(2800/Math.max(_width, _height))));		}				/**		 * Returns the normalMap generated by the class		 */		public function get normalMap():BitmapData		{			return _normalMap;		}				/**		 * Returns the generated bump source for a displacementfilter generated by the class		 */		public function get bumpMap():BitmapData		{			return _bumpMap;		}				/**		* Class NormalMapGenerator generates a normalmap from a given Mesh object and merge an additionl bump information to it.		*		* @param	mesh			[optional] The <code>Mesh</code> object to be traced.		* @param	width			[optional] The width of the generated normal map. Default is 512.		* @param	height			[optional] The height of the generated normal map. Default is 512.		* @param	heightMap		[optional] The source <code>BitmapData</code> for additional bump information. Default is null;		* @param	blur			[optional] int. Blur value if applyed, the surface of the object becomes smoother. Default is 0;		* @param	growpixels		[optional] Boolean. To avoid some artefacts cause by the pixel trace. adds pixels at the edges of the trace.		* @param	maxfaces		[optional] int. To avoid that the player generates a timeout error, the class handles the trace of faces stepwize. Default is 50 faces.		* @param	type			[optional] String. If the map is of type objectspace or tangent. Default = objectspace;		*		* It is a good practice to render the map with great size and eventually reduce after its rendered, since Flash doesn't allow to draw smaller than a pixel while the uv information might ask a smaller draw.		* The mesh MUST have a unique mapping. Any overlapping face area will result in artefacts.		*/		public function NormalMapGenerator(mesh:Mesh = null, width:int = 512, height:int = 512, heightMap:BitmapData = null, blur:int = 0, growPixels:Boolean = false, maxFaces:int = 50, normalMapType:String = null, invertX:Boolean = false)        {			this.mesh = mesh;			_width = width;			_height = height;			this.maxFaces = maxFaces;			this.heightMap = heightMap;			this.blur = blur;			this.growPixels = growPixels;			this.normalMapType = normalMapType || NormalMapType.OBJECT_SPACE;			this.invertX = invertX;						_state = 0;			_step = maxFaces * (1-(1/(2800/Math.max(_width, _height))));		}				/**		 * Starts the rendering of the normal map if a mesh object has been defined		 */		public function execute():void		{			_canceled = false;			if(mesh != null && (mesh as Mesh).vertices != null){								if(_normalMap != null)					_normalMap.dispose();									_normalMap = new BitmapData(_width, _height, false, 0x000000);				generate(0, (_step > mesh.faces.length)? mesh.faces.length : _step);							} else{								throw new Error("--> No valid Mesh set yet: NormalMapGenerator.mesh = MeshObject");			}		}						/**		 * Cancels the trace		 */		public function cancel():void        {			_canceled = true;			if(heightMap != null){				heightMap.dispose();				heightMap = null;			}        }        		/**		 * Default method for adding a traceprogress event listener		 * 		 * @param	listener		The listener function		 */		public function addOnTraceProgress(listener:Function):void        {			addListener(this, TraceEvent.TRACE_PROGRESS, listener, false, 0, false);        }				/**		 * Default method for removing a traceprogress event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnTraceProgress(listener:Function):void        {            removeListener(TraceEvent.TRACE_PROGRESS, listener, false);        }		/**		 * Default method for adding a tracecomplete event listener		 * 		 * @param	listener		The listener function		 */		public function addOnTraceComplete(listener:Function):void        {			addListener(this, TraceEvent.TRACE_COMPLETE, listener, false, 0, false);        }				/**		 * Default method for removing a tracecomplete event listener		 * 		 * @param	listener		The listener function		 */		public function removeOnTraceComplete(listener:Function):void        {            removeListener(TraceEvent.TRACE_COMPLETE, listener, false);        }			}}