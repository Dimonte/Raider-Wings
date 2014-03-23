package game.behaviours; 

import game.EnemyBullet;
import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class TeslaBehaviourFrontalAssault implements IBehaviour
{
	private var subject:EnemyShip;
	private var counter:Float;
	private var shootCounter:Int;
	
	public function new(subject:EnemyShip) 
	{
		this.subject = subject;
		counter = 0;
		shootCounter = 1;
	}
	
	public function update(dTime:Float):Void
	{
		counter+=dTime;
		if (counter > shootCounter*1.1) 
		{
			subject.shootAtPlayer();
			shootCounter++;
		}
		if (counter > 3) 
		{
			subject.behaviour = new TeslaBehaviourRetreat(subject);
		}
		
		if (subject.healthPoints < 100) 
		{
			subject.behaviour = new TeslaBehaviourRetreat(subject);
		}
	}
	
}