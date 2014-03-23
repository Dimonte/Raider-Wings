package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import openfl.Assets;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class ScreenPad extends Sprite
{
	static public inline var WIDTH:Int = 128;
	static public inline var HEIGHT:Int = 128;
	static public inline var SIDE_PAD:Int = 16;
	
	public var xMagnitude:Float;
	public var yMagnitude:Float;
	private var headBitmap:Bitmap;
	private var mouseDown:Bool;
	private var headContainer:Sprite;

	public function new() 
	{
		super();
		var backgroundBitmapData:BitmapData = new BitmapData(WIDTH,HEIGHT, true, 0);
		var backgroundSource:Sprite = new Sprite();
		backgroundSource.graphics.lineStyle(2, 0, 0.6, true);
		backgroundSource.graphics.beginFill(0, 0.2);
		backgroundSource.graphics.drawRoundRect(1, 1, WIDTH-2, HEIGHT-2, WIDTH/4, HEIGHT/4);
		backgroundSource.graphics.endFill();
		backgroundBitmapData.draw(backgroundSource);
		addChild(new Bitmap(backgroundBitmapData));
		
		headContainer = new Sprite();
		headContainer.x = WIDTH / 2;
		headContainer.y = HEIGHT / 2;
		addChild(headContainer);
		
		headBitmap = new Bitmap(Assets.getBitmapData("assets/ui/joystickHead.png"));
		headBitmap.x = -headBitmap.width / 2;
		headBitmap.y = -headBitmap.height/ 2;
		headContainer.addChild(headBitmap);
		
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		//TODO cleanup routine on removed from stage
	}
	
	private function addedToStageHandler(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
	}
	
	private function mouseDownHandler(e:MouseEvent):Void 
	{
		mouseDown = true;
	}
	
	private function stage_mouseUpHandler(e:MouseEvent):Void 
	{
		mouseDown = false;
	}
	
	public function update(dTime:Float):Void
	{
		if (mouseDown) 
		{
			headContainer.x = Math.min(Math.max(mouseX, SIDE_PAD), WIDTH - SIDE_PAD);
			headContainer.y = Math.min(Math.max(mouseY, SIDE_PAD), HEIGHT - SIDE_PAD);
			xMagnitude = (mouseX - WIDTH / 2) / ((WIDTH - SIDE_PAD * 2 - 2) / 2);
			yMagnitude = (mouseY - HEIGHT/ 2) / ((HEIGHT- SIDE_PAD * 2 - 2) / 2);
		}
		else 
		{
			headContainer.x += (WIDTH / 2 - headContainer.x) * dTime * 10;
			headContainer.y += (HEIGHT / 2 - headContainer.y) * dTime * 10;
			xMagnitude = 0;
			yMagnitude = 0;
		}
		
	}
	
}