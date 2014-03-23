package sphaeraGravita.shapes;

import sphaeraGravita.collision.AABB;
import sphaeraGravita.math.Vector2D;

/**
 * ...
 * @author Dimonte
 */
class CircleShape extends BaseShape
{
	public var radius:Float;
	public var position:Vector2D;
	
	public function new(x:Float, y:Float, radius:Float) 
	{
		super(ShapeType.CIRCLE_SHAPE);
		position = new Vector2D(x, y);
		this.radius = radius;
	}
	
	override public function getBoundingAABB():AABB 
	{ 
		var boundingAABB:AABB = AABB.asMinMax(position.x - radius, position.y - radius, position.x + radius, position.y + radius);
		return boundingAABB;
	}
	
}