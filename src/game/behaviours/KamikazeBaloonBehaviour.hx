package game.behaviours;

import game.CollisionCategory;
import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class KamikazeBaloonBehaviour extends BasicBehaviour
{
	private var counter:Float;
	
	public function new(subject:EnemyShip) 
	{
		super(subject);
		counter = 0;
	}
	
	override public function init(dTime:Float):Void 
	{
		counter = 4 + Std.int(Math.random() * 8);
		updateFunction = waitToExplode;
	}
	
	private function waitToExplode(dTime:Float):Void
	{
		counter -= dTime;
		if (counter <= 0) 
		{
			updateFunction = explode;
		}
	}
	
	private function explode(dTime:Float):Void
	{
		for (i in 0...12) 
		{
			subject.shoot(i * Math.PI * 2 / 12, 150);
		}
		subject.die();
		updateFunction = null;
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
			subject.die();
		}
	}
	
}