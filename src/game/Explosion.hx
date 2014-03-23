package game;

//import assets.GraphicsLibrary;
import assets.GraphicsLibrary;
import sphaeraGravita.shapes.CircleShape;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class Explosion extends GameEntity
{
	private var counter:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		type = EntityType.EXPLOSION;
		graphicsAsset = GraphicsLibrary.getExplosion1();
		gridBound = true;
		unguidedProjectile = true;
		init();
		counter = 0;
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
		frameRectNum = Std.int(counter*5*1.25);
		if (counter >= 0.8) 
		{
			dead = true;
		}
	}
	
}