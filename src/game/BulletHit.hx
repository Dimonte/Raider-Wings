package game;
import assets.GraphicsLibrary;

//import assets.GraphicsLibrary;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class BulletHit extends GameEntity
{
	private var counter:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		counter = 0;
		type = EntityType.BULLET_HIT;
		graphicsAsset = GraphicsLibrary.getBulletHit();
		gridBound = true;
		unguidedProjectile = true;
		init();
	}
	
	override public function reset():Void 
	{
		super.reset();
		counter = 0;
	}
	
	override public function update(dTime:Float):Void 
	{
		super.update(dTime);
		counter+=dTime;
		if (counter > 0.2) 
		{
			dead = true;
		}
	}
	
}