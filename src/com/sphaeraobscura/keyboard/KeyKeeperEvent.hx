package com.sphaeraobscura.keyboard;
import flash.events.Event;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class KeyKeeperEvent extends Event
{
	
	static public inline var KEY_DOWN:String = "keyDown";
	static public inline var KEY_UP:String = "keyUp";
	
	public var keyCode:Int;

	public function new(type:String, keyCode:Int, bubbles:Bool = false, cancelable:Bool = false) 
	{
		this.keyCode = keyCode;
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event 
	{
		return new KeyKeeperEvent(type, keyCode, bubbles, cancelable);
	}
	
}