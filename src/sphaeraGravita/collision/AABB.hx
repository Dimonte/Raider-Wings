package sphaeraGravita.collision;
import sphaeraGravita.math.Vector2D;

/**
 * ...
 * @author Dimonte
 */
class AABB
{
	private var bottomRight:Vector2D;
	private var topLeft:Vector2D;
	private var topRight:Vector2D;
	private var bottomLeft:Vector2D;
	public var lowerBound:Vector2D;
	public var upperBound:Vector2D;
	
	public function new() 
	{
		lowerBound = new Vector2D();
		upperBound = new Vector2D();
		topLeft = new Vector2D();
		topRight = new Vector2D();
		bottomRight = new Vector2D();
		bottomLeft = new Vector2D();
	}
	
	public function getWidth():Float
	{
		return upperBound.x - lowerBound.x;
	}
	
	public function getHeight():Float
	{
		return upperBound.y - lowerBound.y;
	}
	
	public function containsPoint(point:Vector2D):Bool
	{
		if (point.x < lowerBound.x)
			return false;
		if (point.x > upperBound.x)
			return false;
		if (point.y < lowerBound.y)
			return false;
		if (point.y > upperBound.y)
			return false;
		return true;
	}
	
	public function getTopLeftCorner():Vector2D
	{
		topLeft.x = lowerBound.x;
		topLeft.y = lowerBound.y;
		return topLeft;
	}
	
	public function getTopRightCorner():Vector2D
	{
		topRight.x = upperBound.x;
		topRight.y = lowerBound.y;
		return topRight;
	}
	
	public function getBottomLeftCorner():Vector2D
	{
		bottomLeft.x = lowerBound.x;
		bottomLeft.y = upperBound.y;
		return bottomLeft;
	}
	
	public function getBottomRightCorner():Vector2D
	{
		
		bottomRight.x = upperBound.x;
		bottomRight.y = upperBound.y;
		return bottomRight;
	}
	
	static public function asMinMax(minX:Float, minY:Float, maxX:Float, maxY:Float):AABB
	{
		var aabb:AABB = new AABB();
		aabb.lowerBound.x = minX;
		aabb.lowerBound.y = minY;
		aabb.upperBound.x = maxX;
		aabb.upperBound.y = maxY;
		return aabb;
	}
	
	public function toString():String
	{
		return "minX: " + lowerBound.x + ", minY: " + lowerBound.y + ", width: " + getWidth() + ", height: " + getHeight();
	}
	
}