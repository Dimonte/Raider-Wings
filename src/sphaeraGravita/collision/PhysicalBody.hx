package sphaeraGravita.collision;


import dataStructures.DLL;
import dataStructures.DLLNode;
import sphaeraGravita.math.RotationMatrix;
import sphaeraGravita.math.Vector2D;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.spacePartitioning.GridCell;
//import sphaeraGravita.shapes.BaseShape;

/**
 * ...
 * @author Dimonte
 */
class PhysicalBody extends CollidingEntity
{
	
	public var boundingAABB:AABB;
	public var xformedBoundingAABB:AABB;
	public var worldAABB:AABB;
	public var shapeList:BaseShape;
	public var colliding:Bool;
	public var gridBound:Bool;
	public var overlappingCells:Array<GridCell>;
	public var fixed:Bool;
	public var dead:Bool;
	
	public var position:Vector2D;
	public var xform:RotationMatrix;
	public var speed:Vector2D;
	
	public var bounceFactor:Float;
	public var frictionFactor:Float;
	
	public var x(get,set):Float;
	public var y(get,set):Float;
	public var rotation(get,set):Float;
	
	public function new() 
	{
		bounceFactor = 1;
		frictionFactor = 1;
		position = new Vector2D();
		speed = new Vector2D();
		xform = new RotationMatrix();
	}
	
	public function clearShapes():Void
	{
		shapeList = null;
	}
	
	public function addShape(shape:BaseShape):Void
	{
		shape.parent = shape.body = this;
		
		if (shapeList != null) {
			var shapeNode:BaseShape = shapeList;
			while (shapeNode.next != null) {
				shapeNode = shapeNode.next;
			}
			shapeNode.next = shape;
		} else {
			shapeList = shape;
		}
	}
	
	public function init():Void
	{
		var minX:Float = Math.POSITIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		
		var shape:BaseShape = shapeList;
		
		// if there's no shapes inside, zeroes abound!
		if (shape == null) 
		{
			minX = minY = maxX = maxY = 0;
		}
		
		while (shape != null)
		{
			minX = Math.min(minX, shape.getBoundingAABB().lowerBound.x);
			minY = Math.min(minY, shape.getBoundingAABB().lowerBound.y);
			maxX = Math.max(maxX, shape.getBoundingAABB().upperBound.x);
			maxY = Math.max(maxY, shape.getBoundingAABB().upperBound.y);
			shape = shape.next;
		}
		boundingAABB = AABB.asMinMax(minX, minY, maxX, maxY);
		xformedBoundingAABB = AABB.asMinMax(minX, minY, maxX, maxY);
		worldAABB = AABB.asMinMax(minX, minY, maxX, maxY);
	}
	
	public function updateWorldCache():Void
	{
		if (worldAABB == null) 
		{
			//trace(this);
			return;
		}
		worldAABB.lowerBound.x = xformedBoundingAABB.lowerBound.x + position.x;
		worldAABB.lowerBound.y = xformedBoundingAABB.lowerBound.y + position.y;
		worldAABB.upperBound.x = xformedBoundingAABB.upperBound.x + position.x;
		worldAABB.upperBound.y = xformedBoundingAABB.upperBound.y + position.y;
	}
	
	private function recalculateXformedAABB():Void
	{
		var tl:Vector2D = boundingAABB.getTopLeftCorner().applyXform(xform);
		var tr:Vector2D = boundingAABB.getTopRightCorner().applyXform(xform);
		var bl:Vector2D = boundingAABB.getBottomLeftCorner().applyXform(xform);
		var br:Vector2D = boundingAABB.getBottomRightCorner().applyXform(xform);
		var minX:Float = Math.min(Math.min(tl.x, tr.x), Math.min(bl.x, br.x));
		var minY:Float = Math.min(Math.min(tl.y, tr.y), Math.min(bl.y, br.y));
		var maxX:Float = Math.max(Math.max(tl.x, tr.x), Math.max(bl.x, br.x));
		var maxY:Float = Math.max(Math.max(tl.y, tr.y), Math.max(bl.y, br.y));
		xformedBoundingAABB.lowerBound.x = minX;
		xformedBoundingAABB.lowerBound.y = minY;
		xformedBoundingAABB.upperBound.x = maxX;
		xformedBoundingAABB.upperBound.y = maxY;
	}
	
	public function set_x(value:Float):Float
	{
		position.x = value;
		return position.x;
	}
	
	public function get_x():Float
	{
		return position.x;
	}
	
	public function get_y():Float 
	{ 
		return position.y; 
	}
	
	public function set_y(value:Float):Float 
	{
		position.y = value;
		return position.y;
	}
	
	/**
	 * Gets and sets rotation angle in radians
	 */
	public function get_rotation():Float
	{
		return xform.angle;
	}
	
	public function set_rotation(value:Float):Float
	{
		xform.setAngle(value);
		recalculateXformedAABB();
		return xform.angle;
	}
	
	/**
	 * Does not modify localPoint
	 * @param	localPoint point in local coordinates
	 * @return	point in world coordinates
	 */
	public function localToWorld(localPoint:Vector2D, t:Bool = false):Vector2D
	{
		return localPoint.clone().applyXform(xform).add(position);
	}
	
	/**
	 * Checks if body is in specified bounds
	 * @param	x
	 * @param	y
	 * @param	width
	 * @param	heigth
	 * @return
	 */
	public function inBounds(x:Float, y:Float, width:Float, heigth:Float):Bool
	{
		if (worldAABB.upperBound.x < x) 
		{
			return false;
		}
		if (worldAABB.upperBound.y < y) 
		{
			return false;
		}
		if (worldAABB.lowerBound.x > x + width) 
		{
			return false;
		}
		if (worldAABB.lowerBound.y > y +heigth)
		{
			return false;
		}
		return true;
	}
	
	public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void
	{
		
	}
	
}