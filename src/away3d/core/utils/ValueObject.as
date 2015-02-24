package away3d.core.utils
{
    
    import away3d.core.base.Element;
    import away3d.core.base.Geometry;
    
    import satprof.EventUtil;
    
    public class ValueObject extends EventUtil
    {
        public var parents:Vector.<Element> = new Vector.<Element>();
        
        public var geometry:Geometry;
    }
}