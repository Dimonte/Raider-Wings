package game.behaviours;

import game.CollisionCategory;
import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class BaloonBehaviour extends BasicBehaviour
{
	
	public function new(subject:EnemyShip) 
	{
		super(subject);
	}
	
	override public function init(dTime:Float):Void 
	{
		updateFunction = oscillateDown;
	}
	
	private function oscillateDown(dTime:Float):Void
	{
		if (subject.speed.y < 50) 
		{
			subject.speed.y += 30*dTime;
		} else 
		{
			updateFunction = oscillateUp;
		}
	}
	
	private function oscillateUp(dTime:Float):Void
	{
		if (subject.speed.y > -50) 
		{
			subject.speed.y -= 30*dTime;
		} else 
		{
			updateFunction = oscillateDown;
		}
	}
	
	override public function checkCommonConditions():Void 
	{
		if (subject.healthPoints <= 0 && !subject.shotDown)
		{
			subject.world.score += 1500;
			subject.shotDown = true;
			subject.unguidedProjectile = true;
			subject.collisionCategory = CollisionCategory.PARTICLE;
			subject.collisionMask = CollisionCategory.TILE;
			updateFunction = goDownInFlames;
		}
	}
	
	private function goDownInFlames(dTime:Float):Void
	{
		if (subject.shotDown && subject.speed.y < 300) 
		{
			subject.speed.y += 200*dTime;
		}
	}
	
	override public function respondToDamage():Void 
	{
		super.respondToDamage();
	}
	
}