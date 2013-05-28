package engine.framework.simpler
{
    import flash.display.Stage;
    import flash.geom.Point;
    
    import engine.framework.time.TickedComponent;
    
    public class MouseFollowComponent extends TickedComponent
    {
        [PBInject]
        public var stage:Stage;
        
        public var targetProperty:String;
        
        public override function onTick():void
        {
            owner.setProperty(targetProperty, new Point(stage.mouseX, stage.mouseY));
        }
    }
}