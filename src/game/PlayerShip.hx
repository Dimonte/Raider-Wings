package game;
import assets.EntityGraphicsAsset;
import assets.GraphicsLibrary;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.math.Vector2D;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.shapes.CircleShape;
import sphaeraGravita.shapes.Polygon;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class PlayerShip extends GameEntity
{
	private var reload:Int;
	private var bulletAngle:Float;
	private var smokeCounter:Float;
	private var timePassedSinceLastSpeedUpdate:Float;
	private var reloadTime:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		type = EntityType.PLAYER;
		
		reloadTime = 0.02;
		bulletAngle = 0;
		smokeCounter = 0;
		timePassedSinceLastSpeedUpdate = 0;
		
		collisionCategory = CollisionCategory.PLAYER;
		collisionMask = CollisionCategory.ENEMY | CollisionCategory.TILE | CollisionCategory.ENEMY_BULLET | CollisionCategory.PARTICLE;
		graphicsAsset = GraphicsLibrary.getPlayerShip();
		
		bounceFactor = 2;
		
		var poly:Polygon = new Polygon();
		poly.setPoly([new Vector2D( -55, 0), new Vector2D( -55, -10), new Vector2D(0, -15), new Vector2D(50, -10), new Vector2D(50, 10), new Vector2D(20, 22), new Vector2D(0, 22)]);
		addShape(poly);
		var circle:CircleShape = new CircleShape(20, 0, 11);
		addShape(circle);
		init();
		
		healthPoints = 800;
	}
	
	public function accelerateForward():Void
	{
		
	}
	
	public function accelerateBackwards():Void
	{
		
	}
	
	public function accelerateUp():Void
	{
		
	}
	
	public function accelerateDown():Void
	{
		
	}
	
	override public function update(dTime:Float):Void 
	{
		
		//healthPoints -= 10;
		
		if (healthPoints <= 0) 
		{
			unguidedProjectile = true;
			speed.y += 900*dTime;
		}
		
		if (reloadTime > 0) 
		{
			reloadTime-= dTime;
		}
		
		timePassedSinceLastSpeedUpdate += dTime;
		while (timePassedSinceLastSpeedUpdate > 0.02) 
		{
			speed.multiply(0.8);
			timePassedSinceLastSpeedUpdate -= 0.02;
		}
		
		if (!dead && healthPoints <= 0) 
		{
			if (smokeCounter >= 0.05) 
			{
				var smokeParticle:GameEntity = world.getReusableEntityByType(EntityType.SMOKE);
				smokeParticle.position.x = position.x - 20 + Math.random()*50;
				smokeParticle.position.y = position.y - 10 + Math.random()*5;
				world.addParticle(smokeParticle);
				smokeCounter = 0;
			}
			else 
			{
				smokeCounter+=dTime;
			}
		}
	}
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		super.reactToCollision(collidingBody, selfShape, otherShape);
		cast(collidingBody, GameEntity).recieveDamage(10);
		if (Type.getClass(collidingBody) == Tile) 
		{
			if (healthPoints <= 0 )
			{
				dead = true;
				var exp:GameEntity = world.getReusableEntityByType(EntityType.EXPLOSION);
				exp.position = position.clone();
				world.addParticle(exp);
				while (Math.random() > 0.6) 
				{
					var debries:GameEntity = world.getReusableEntityByType(EntityType.DEBRIES);
					debries.position.x = x;
					debries.position.y = y;
					debries.speed.x = Math.random() * 10 - 5;
					debries.speed.y = -Math.random() * 10;
					world.addParticle(debries);
				}
			}
		}
	}
	
	override public function recieveDamage(damageAmount:Int):Void 
	{
		super.recieveDamage(damageAmount);
	}
	
	public function shoot():Void
	{
		if (healthPoints <= 0) 
		{
			return;
		}
		if (reloadTime > 0)
		{
			return;
		}
		reloadTime = 0.02;
		if (reload > 0) 
		{
			reload--;
		} else 
		{
			reload = 1;
		}
		
		bulletAngle += Math.PI / 34;
		
		var i:Int = 4;
		while (i-- > 0) 
		{
			if (i % 2 == reload) 
			{
				continue;
			}
			var bullet:GameEntity = world.getReusableEntityByType(EntityType.PLAYER_BULLET);
			bullet.position.x = this.position.x + 30;
			bullet.position.y = this.position.y;
			bullet.speed.x = 450;
			bullet.speed.y = Math.sin((bulletAngle + i)*(i + 1))*60;
			world.addPlayerBullet(bullet);
		}
		
	}
	
}