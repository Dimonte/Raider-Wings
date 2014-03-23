package game.behaviours;

import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class BasicBehaviour implements IBehaviour
{
	public var updateFunction: Float -> Void;
	public var subject:EnemyShip;
	
	public function new(subject:EnemyShip) 
	{
		this.subject = subject;
		updateFunction = init;
	}
	
	public function update(dTime:Float):Void
	{
		checkCommonConditions();
		if (updateFunction != null) 
		{
			updateFunction(dTime);
		}
	}
	
	public function checkCommonConditions():Void
	{
		
	}
	
	public function init(dTime:Float):Void
	{
		
	}
	
	public function respondToDamage():Void
	{
		
	}
	
}