package game;
import assets.GraphicsLibrary;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class SmokeParticle extends GameEntity
{
	private var counter:Float;

	public function new(world:GameWorld) 
	{
		super(world);
		counter = 0;
		type = EntityType.SMOKE;
		graphicsAsset = GraphicsLibrary.getSmoke();
		gridBound = true;
		unguidedProjectile = true;
		speed.y = -1;
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
		frameRectNum = Std.int(counter * 5);
		if (counter >= 1) 
		{
			dead = true;
		}
	}
	
}