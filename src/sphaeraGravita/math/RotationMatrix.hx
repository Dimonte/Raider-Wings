package sphaeraGravita.math;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class RotationMatrix
{
	
	public var sin:Float;
	public var cos:Float;
	
	/**
	 * Use this variable to read angle information ONLY! Use setAngle to set angle.
	 */
	public var angle:Float;
	
	public function new():Void
	{
		setAngle(0);
	}
	
	public function setAngle(angle:Float):Void
	{
		this.angle = angle;
		sin = Math.sin(angle);
		cos = Math.cos(angle);
	}
	
	
	
}