package game.behaviours;

import game.EnemyShip;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class TeslaBehaviourGoDownInFlames implements IBehaviour
{
	private var subject:EnemyShip;
	
	public function new(subject:EnemyShip) 
	{
		this.subject = subject;
	}
	
	public function update(dTime:Float):Void
	{
		if (subject.speed.y < 400) 
		{
			subject.speed.y += 450*dTime;
		}
		if (subject.rotation > -Math.PI / 4) 
		{
			subject.rotation -= Math.PI / 5*dTime;
		}
	}
		
}