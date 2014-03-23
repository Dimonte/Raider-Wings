package sphaeraGravita.shapes;

import flash.errors.IllegalOperationError;
import game.CollisionCategory;
import sphaeraGravita.collision.AABB;
import sphaeraGravita.collision.CollidingEntity;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.math.Vector2D;
/**
 * ...
 * @author Dimonte
 */
class BaseShape extends CollidingEntity
{
	public var body:PhysicalBody;
	public var previous:BaseShape;
	public var next:BaseShape;
	public var sensor:Bool;
	public var name:String;
	public var type:String;
	
	public function new(type:String) 
	{
		this.type = type;
	}
	
	public function getBoundingAABB():AABB
	{
		throw new IllegalOperationError("Function must be overridden");
		return new AABB();
	}
	
}