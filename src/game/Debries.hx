package game;

//import assets.GraphicsLibrary;
import assets.GraphicsLibrary;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.shapes.BaseShape;
import game.GameEntity;
import sphaeraGravita.shapes.CircleShape;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class Debries extends GameEntity
{
	private var score:Int;
	
	public function new(world:GameWorld) 
	{
		super(world);
		
		type = EntityType.DEBRIES;
		
		graphicsAsset = GraphicsLibrary.getDebries();
		
		collisionCategory = CollisionCategory.PARTICLE;
		
		gridBound = true;
		unguidedProjectile = true;
		
		bounceFactor = 0.5;
		frictionFactor = 1;
		
		selectGraphicsAndScore();
		
		var shape:CircleShape = new CircleShape(0, 0, 6);
		shape.collisionMask = CollisionCategory.TILE;
		addShape(shape);
		
		var sensorShape:CircleShape = new CircleShape(0, 0, 6);
		sensorShape.sensor = true;
		sensorShape.collisionMask = CollisionCategory.PLAYER;
		addShape(sensorShape);
		init();
	}
	
	override public function reset():Void 
	{
		super.reset();
		collisionMask = CollisionCategory.TILE | CollisionCategory.PLAYER;
		selectGraphicsAndScore();
	}
	
	override public function update(dTime:Float):Void 
	{
		speed.y += 400*dTime;
	}
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		super.reactToCollision(collidingBody, selfShape, otherShape);
		
		if (collidingBody.collisionCategory == CollisionCategory.PLAYER)
		{
			world.score += score;
			dead = true;
			return;
		}
		
		speed.x *= 0.2;
		if (speed.y <= 0) 
		{
			speed.y = Math.min(speed.y, -5);
		}
		collisionMask = CollisionCategory.PLAYER;
	}
	
	private function selectGraphicsAndScore():Void 
	{
		if (Math.random() > 0.3) 
		{
			frameRectNum = 2;
			score = 100;
		}
		else if (Math.random() > 0.3) 
		{
			frameRectNum = 0;
			score = 75;
		}
		else 
		{
			frameRectNum = 1;
			score = 50;
		}
	}
	
}