package game;

import assets.GraphicsLibrary;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.shapes.BaseShape;
import game.GameEntity;
import sphaeraGravita.shapes.CircleShape;
import sphaeraGravita.shapes.Polygon;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class Bullet extends GameEntity
{
	private var timePassedSinceLastUpdate:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		
		type = EntityType.PLAYER_BULLET;
		
		graphicsAsset = GraphicsLibrary.getBullet();
		
		collisionCategory = CollisionCategory.PLAYER_BULLET;
		collisionMask = CollisionCategory.TILE | CollisionCategory.ENEMY;
		unguidedProjectile = true;
		gridBound = true;
		/*
		var s:Polygon = new Polygon();
		s.setAsBox(1, 1);
		/*/
		var s:CircleShape = new CircleShape(0,0,6);
		//*/
		s.sensor = true;
		addShape(s);
		init();
	}
	
	override public function reset():Void 
	{
		super.reset();
	}
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		cast(collidingBody, GameEntity).recieveDamage(12);
		
		var bh:GameEntity = world.getReusableEntityByType(EntityType.BULLET_HIT);
		bh.reset();
		bh.x = x;
		bh.y = y;
		world.addParticle(bh);
		
		dead = true;
	}
	
	override public function update(dTime:Float):Void 
	{
		super.update(dTime);
		timePassedSinceLastUpdate += dTime;
		while (timePassedSinceLastUpdate > 0.035) 
		{
			timePassedSinceLastUpdate-= 0.035;
			speed.y *= 0.98;
		}
		
		#if (!android && !iphone)
		if (Math.random() < 6*dTime) 
		{
			var trail:GameEntity = world.getReusableEntityByType(EntityType.RAILGUN_TRAIL);
			trail.reset();
			trail.position = position.clone();
			trail.speed = speed.clone();
			world.addParticle(trail);
		}
		#end
	}
	
}