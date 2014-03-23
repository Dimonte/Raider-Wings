package game;
import assets.GraphicsLibrary;

//import assets.GraphicsLibrary;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class RailgunTrail extends GameEntity
{
	private var counter:Float;
	private var timePassedSinceLastUpdate:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		type = EntityType.RAILGUN_TRAIL;
		collisionCategory = CollisionCategory.IGNORE;
		counter = 0;
		graphicsAsset = GraphicsLibrary.getRailgunTrail();
		gridBound = true;
		unguidedProjectile = true;
		timePassedSinceLastUpdate = 0;
		init();
	}
	
	override public function reset():Void 
	{
		super.reset();
		counter = 0;
		timePassedSinceLastUpdate = 0;
	}
	
	override public function update(dTime:Float):Void 
	{
		super.update(dTime);
		timePassedSinceLastUpdate += dTime;
		while(timePassedSinceLastUpdate > 0.02)
		{
			speed.multiply(0.8);
			timePassedSinceLastUpdate -= 0.02;
		}
		counter+=dTime;
		if (counter > 0.4) 
		{
			dead = true;
		}
	}
	
}