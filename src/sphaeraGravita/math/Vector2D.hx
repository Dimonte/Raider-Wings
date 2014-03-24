package sphaeraGravita.math;
import sphaeraGravita.math.Vector2D;


/**
 * ...
 * @author Dimonte
 */
class Vector2D 
{
	
	public static function dotProduct(vector1:Vector2D, vector2:Vector2D):Float
	{
		return vector1.x * vector2.x + vector1.y * vector2.y;
	}
	
	public static function project(vector:Vector2D, vectorToProjectOn:Vector2D):Vector2D
	{
		var vectorToProjectOnNormal:Vector2D = vectorToProjectOn.clone().normalize();
		var dp:Float = dotProduct(vector, vectorToProjectOnNormal);
		return new Vector2D(dp * vectorToProjectOnNormal.x, dp * vectorToProjectOnNormal.y);
	}
	
	public var x:Float;
	public var y:Float;
	
	public function new(?x:Float=0, ?y:Float=0) 
	{
		this.x = x;
		this.y = y;
	}
	
	public function getLength():Float
	{
		return Math.sqrt(x * x + y * y);
	}
	
	public function getLengthSquared():Float
	{
		return (x * x + y * y);
	}
	
	public function add(vector:Vector2D):Vector2D
	{
		x += vector.x;
		y += vector.y;
		return this;
	}
	
	public function subtract(vector:Vector2D):Vector2D
	{
		x -= vector.x;
		y -= vector.y;
		return this;
	}
	
	public function multiply(multiplier:Float):Vector2D
	{
		x *= multiplier;
		y *= multiplier;
		return this;
	}
	
	public function getNormalLeft():Vector2D
	{
		return new Vector2D( y, -x );
	}
	
	public function getNormalRight():Vector2D
	{
		return new Vector2D( -y, x );
	}
	
	public function invert():Vector2D
	{
		x = -x;
		y = -y;
		return this;
	}
	
	public function equals(vector:Vector2D):Bool
	{
		return (x == vector.x) && (y == vector.y);
	}
	
	public function clone():Vector2D
	{
		return new Vector2D(x, y);
	}
	
	public function normalize():Vector2D
	{
		var length:Float = this.getLength();
		if ( length == 0 )
		{
			return this;
		} else {
			x /= length;
			y /= length;
		}
		return this;
	}
	
	public function applyXform(xform:RotationMatrix):Vector2D
	{
		var newX:Float = x * xform.cos - y * xform.sin;
		var newY:Float = x * xform.sin + y * xform.cos;
		x = newX;
		y = newY;
		return this;
	}
	
	public function toString():String
	{
		return "(" + x + "," + y + ")";
	}
	
	public function copyFrom(source:Vector2D) 
	{
		x = source.x;
		y = source.y;
	}
	
}