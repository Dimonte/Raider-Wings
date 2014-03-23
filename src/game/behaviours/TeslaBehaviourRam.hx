package game.behaviours;

import game.EnemyShip;
import game.PlayerShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class TeslaBehaviourRam implements IBehaviour
{
	private var subject:EnemyShip;
	private var target:PlayerShip;
	private var counter:Float;
	private var shootCounter:Int;
	
	public function new(subject:EnemyShip) 
	{
		this.subject = subject;
		counter = 0;
	}
	
	public function update(dTime:Float):Void
	{
		if (target == null) 
		{
			target = subject.world.player;
		}
		
		counter+=dTime;
		if (counter > shootCounter) 
		{
			subject.shoot(Math.PI, 400);
			shootCounter++;
		}
		
		if (target.y > subject.y + subject.speed.y / 5) 
		{
			subject.speed.y += 180*dTime;
		} else 
		{
			subject.speed.y -= 180*dTime;
		}
		
		if (subject.healthPoints < 100) 
		{
			subject.behaviour = new TeslaBehaviourRetreat(subject);
		}
	}
	
}