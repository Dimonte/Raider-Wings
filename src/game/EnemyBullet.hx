package game;

import assets.GraphicsLibrary;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.shapes.CircleShape;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class EnemyBullet extends GameEntity
{
	public var bulletDamage:Int;
	
	public function new(world:GameWorld) 
	{
		bulletDamage = 20;
		
		super(world);
		
		type = EntityType.ENEMY_BULLET;
		
		graphicsAsset = GraphicsLibrary.getEnemyBullet();
		
		collisionCategory = CollisionCategory.ENEMY_BULLET;
		collisionMask = CollisionCategory.TILE | CollisionCategory.PLAYER;
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
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		cast(collidingBody, GameEntity).recieveDamage(bulletDamage);
		var bh:GameEntity = world.getReusableEntityByType(EntityType.BULLET_HIT);
		bh.x = x;
		bh.y = y;
		world.addParticle(bh);
		dead = true;
	}
	
	override public function update(dTime:Float):Void 
	{
		super.update(dTime);
	}
	
}