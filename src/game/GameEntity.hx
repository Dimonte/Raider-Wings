package game;

import assets.EntityGraphicsAsset;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.shapes.BaseShape;
/**
 * ...
 * @author Dimonte
 */
class GameEntity extends PhysicalBody
{
	public var world:GameWorld;
	public var healthPoints:Int;
	public var unguidedProjectile:Bool;
	public var graphicsAsset:EntityGraphicsAsset;
	public var frameRectNum:Int;
	public var type:String;
	
	public function new(world:GameWorld) 
	{
		this.world = world;
		type = EntityType.UNKNOWN;
		super();
	}
	
	public function reset():Void
	{
		dead = false;
		frameRectNum = 0;
	}
	
	public function destroy():Void
	{
		dead = true;
	}
	
	public function update(dTime:Float):Void
	{
		
	}
	
	public function doDamage():Void
	{
		
	}
	
	public function recieveDamage(damageAmount:Int):Void
	{
		healthPoints -= damageAmount;
	}
	
}