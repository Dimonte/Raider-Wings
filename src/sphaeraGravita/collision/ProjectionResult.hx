package sphaeraGravita.collision; 

/**
 * ...
 * @author Dimonte
 */
class ProjectionResult
{
	public var min:Float;
	public var max:Float;
	
	public function new (min:Float = 0, max:Float = 0)
	{
		this.min = min;
		this.max = max;
	}
}