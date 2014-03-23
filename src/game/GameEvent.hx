package game;
import flash.events.Event;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class GameEvent extends Event
{
	static public inline var GAME_OVER:String = "gameOver";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event 
	{
		return new GameEvent(type, bubbles, cancelable);
	}
	
}