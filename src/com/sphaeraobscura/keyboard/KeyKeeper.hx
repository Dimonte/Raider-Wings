package com.sphaeraobscura.keyboard;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.KeyboardEvent;

/**
 * ...
 * @author Dimonte
 */
class KeyKeeper extends EventDispatcher
{
	private var _stage:Stage;
	private var _keysPressed:Array<Bool>;
	
	public function new(stage:Stage) 
	{
		super();
		_stage = stage;
		initKeeper();
	}
	
	private function initKeeper():Void
	{
		_keysPressed = new Array();
		_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, false);
		_stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler, false);
		_stage.addEventListener(Event.DEACTIVATE, deactivateHandler, false);
	}
	
	private function keyDownHandler(e:KeyboardEvent):Void 
	{
		if (!_keysPressed[e.keyCode]) 
		{
			dispatchEvent(new KeyKeeperEvent(KeyKeeperEvent.KEY_DOWN, e.keyCode));
		}
		_keysPressed[e.keyCode] = true;
	}
	
	private function keyUpHandler(e:KeyboardEvent):Void 
	{
		if (_keysPressed[e.keyCode]) 
		{
			dispatchEvent(new KeyKeeperEvent(KeyKeeperEvent.KEY_UP, e.keyCode));
		}
		_keysPressed[e.keyCode] = false;
	}
	
	private function deactivateHandler(e:Event):Void 
	{
		for (i in 0..._keysPressed.length) 
		{
			if (_keysPressed[i]) 
			{
				dispatchEvent(new KeyKeeperEvent(KeyKeeperEvent.KEY_UP, i));
			}
			_keysPressed[i] = false;
		}
	}
	
	public function isDown(keyCode:Int):Bool
	{
		return _keysPressed[keyCode];
	}
}