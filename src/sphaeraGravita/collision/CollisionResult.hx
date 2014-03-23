package sphaeraGravita.collision;

import sphaeraGravita.math.Vector2D;
/**
 * ...
 * @author Dimonte
 */
class CollisionResult
{
	public var collision:Bool;
	public var mtdAmount:Float;
	public var mtdAxis:Vector2D;
	public var mtdVector:Vector2D;
	
	public function new ()
	{
		
	}
	
	public function calculateMTDVector():Vector2D
	{
		mtdVector = mtdAxis.clone().multiply(mtdAmount);
		return mtdVector;
	}
	
}