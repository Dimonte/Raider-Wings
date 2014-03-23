package game.behaviours;

import game.CollisionCategory;
import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class TeslaBehaviourRetreat implements IBehaviour
{
	private var subject:EnemyShip;
	private var counter:Float;
	private var shootCounter:Int;
	
	public function new(subject:EnemyShip) 
	{
		this.subject = subject;
		counter = 0;
	}
	
	public function update(dTime:Float):Void
	{
		counter+=dTime;
		if (counter > shootCounter*2) 
		{
			subject.shootAtPlayer();
			shootCounter++;
		}
		
		if (subject.speed.y > -1200) 
		{
			subject.speed.y -= 300*dTime;
			subject.rotation += Math.PI / 10*dTime;
		}
		if (subject.healthPoints < 0) 
		{
			subject.shotDown = true;
			subject.unguidedProjectile = true;
			subject.collisionCategory = CollisionCategory.PARTICLE;
			subject.collisionMask = CollisionCategory.TILE;
			subject.behaviour = new TeslaBehaviourGoDownInFlames(subject);
			subject.world.score += 5000;
		}
	}
	
}