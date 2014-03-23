import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;

class FPS extends TextField
{
   var times:Array<Float>;

   public function new(inX:Float=10.0, inY:Float=10.0, inCol:Int = 0x000000)
   {
      super();
      x = inX;
      y = inY;
      selectable = false;
	  embedFonts = true;
      defaultTextFormat = new TextFormat(FontManager.mainFont.fontName, 16, 0, true);
      text = "FPS:";
      textColor = inCol;
      times = [];
      addEventListener(Event.ENTER_FRAME, enterFrame);
   }
   
   private function enterFrame(e:Event):Void 
   {
		var now = Lib.getTimer () / 1000;
      times.push(now);
      while(times[0]<now-1)
         times.shift();
      if (visible)
      {
         text = "FPS:\n" + times.length + "/" + Lib.current.stage.frameRate;
      }
   }
   
   

}