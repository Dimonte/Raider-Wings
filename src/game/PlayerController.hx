package game;
import game.PlayerShip;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class PlayerController 
{
	private var horizontalAccelerationMax:Float;
	private var verticalAccelerationMax:Float;
	
	private var player:PlayerShip;
	
	private var horizontalAcceleration:Float;
	private var verticalAcceleration:Float;
	private var shootOnUpdate:Bool;

	public function new(player:PlayerShip) 
	{
		this.player = player;
		horizontalAccelerationMax = 3000;
		verticalAccelerationMax = 3000;
		horizontalAcceleration = 0;
		verticalAcceleration = 0;
	}
	
	public function accelerateRight(?magnitude:Float = 1.0):Void
	{
		horizontalAcceleration += magnitude;
	}
	
	public function accelerateLeft(?magnitude:Float = 1.0):Void
	{
		horizontalAcceleration -= magnitude;
	}
	
	public function accelrateDown(?magnitude:Float = 1.0):Void
	{
		verticalAcceleration += magnitude;
	}
	
	public function accelrateUp(?magnitude:Float = 1.0):Void
	{
		verticalAcceleration -= magnitude;
	}
	
	public function setHorizontalAcceleration(magnitude:Float):Void
	{
		horizontalAcceleration = magnitude;
	}
	
	public function setVerticalAcceleration(magnitude:Float):Void
	{
		verticalAcceleration = magnitude;
	}
	
	public function update(dTime:Float):Void
	{
		if (player == null) 
		{
			return;
		}
		if (player.dead || player.healthPoints < 0) 
		{
			return;
		}
		horizontalAcceleration = Math.max(Math.min(horizontalAcceleration, 1), -1);
		verticalAcceleration = Math.max(Math.min(verticalAcceleration, 1), -1);
		player.speed.x += horizontalAcceleration * horizontalAccelerationMax * dTime;
		player.speed.y += verticalAcceleration * verticalAccelerationMax * dTime;
		if (shootOnUpdate) 
		{
			player.shoot();
		}
		horizontalAcceleration = 0;
		verticalAcceleration = 0;
		shootOnUpdate = false;
	}
	
	public function shoot():Void
	{
		shootOnUpdate = true;
	}
	
}