package game;

import assets.GraphicsLibrary;
import game.behaviours.BaloonBehaviour;
import game.behaviours.BasicBehaviour;
import game.behaviours.IBehaviour;
import game.behaviours.KamikazeBaloonBehaviour;
import game.behaviours.TeslaBehaviourFrontalAssault;
import game.behaviours.TeslaBehaviourRam;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.shapes.BaseShape;
import game.GameEntity;
import sphaeraGravita.shapes.CircleShape;
import sphaeraGravita.shapes.Polygon;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class EnemyShip extends GameEntity
{
	public static inline var TESLA:String = "tesla";
	public static inline var BALOON:String = "baloon";
	
	public var shipType:String;
	public var shotDown:Bool;
	private var counter:Float;
	public var behaviour:IBehaviour;
	
	private var smokeCounter:Float;
	
	public function new(world:GameWorld) 
	{
		super(world);
		
		type = EntityType.ENEMY_SHIP;
		
		collisionCategory = CollisionCategory.ENEMY;
		collisionMask = CollisionCategory.PLAYER_BULLET | CollisionCategory.PLAYER;
		
		shipType = Math.random() > 0.6 ? TESLA : BALOON;
		
		if (shipType == TESLA) 
		{
			createAsTesla();
		} 
		else 
		{
			createAsBalloon();
		}
		
		counter = 0;
		smokeCounter = 0;
		
		init();
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		clearShapes();
		rotation = 0;
		speed.x = 0;
		speed.y = 0;
		counter = 0;
		smokeCounter = 0;
		
		collisionCategory = CollisionCategory.ENEMY;
		collisionMask = CollisionCategory.PLAYER_BULLET | CollisionCategory.PLAYER;
		
		shotDown = false;
		unguidedProjectile = false;
		
		shipType = Math.random() > 0.6 ? TESLA : BALOON;
		
		if (shipType == TESLA) 
		{
			createAsTesla();
		} 
		else 
		{
			createAsBalloon();
		}
		
		init();
	}
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		cast(collidingBody, GameEntity).recieveDamage(5);
		if (shotDown) 
		{
			if (Type.getClass(collidingBody) == Tile) 
			{
				die();
			}
		}
	}
	
	public function die():Void
	{
		dead = true;
		var exp:GameEntity = world.getReusableEntityByType(EntityType.EXPLOSION);
		exp.position = position.clone();
		world.addParticle(exp);
		
		var debriesChance:Float = shipType == TESLA ? 0.8 : 0.6;
		var maxNumber:Int = shipType == TESLA ? 6 : 2;
		var minNumber:Int = shipType == TESLA ? 3 : 1;
		
		
		while (Math.random() < debriesChance || minNumber > 0) 
		{
			var debries:GameEntity = world.getReusableEntityByType(EntityType.DEBRIES);
			debries.position.x = x;
			debries.position.y = y;
			debries.speed.x = (Math.random() * 10 - 5)*30;
			debries.speed.y = (-Math.random() * 5 - 5)*30;
			world.addParticle(debries);
			minNumber--;
			if (--maxNumber < 1) 
			{
				break;
			}
		}
		
	}
	
	override public function update(dTime:Float):Void 
	{
		super.update(dTime);
		if (behaviour != null) 
		{
			behaviour.update(dTime);
		}
		if (x < world.activeZoneStartMarker - 60) 
		{
			dead = true;
		}
		
		if (!dead && shotDown) 
		{
			if (smokeCounter > 0.125) 
			{
				var smokeParticle:GameEntity = world.getReusableEntityByType(EntityType.SMOKE);
				smokeParticle.position.x = position.x + 5;
				smokeParticle.position.y = position.y - 5;
				world.addParticle(smokeParticle);
				smokeCounter = 0;
			}
			else 
			{
				smokeCounter+=dTime;
			}
		}
		
	}
	
	public function shootAtPlayer():Void
	{
		var player:GameEntity = world.player;
		var dx:Int = Std.int(player.x - x);
		dx = Std.int(dx* 0.9);
		var dy:Int = Std.int(player.y - y);
		var angle:Float = Math.atan2(dy, dx);
		var bullet:GameEntity = world.getReusableEntityByType(EntityType.ENEMY_BULLET);
		bullet.position.x = x;
		bullet.position.y = y;
		bullet.speed.x = 360*Math.cos(angle);
		bullet.speed.y = 360*Math.sin(angle); 
		world.addEnemyBullet(bullet);
	}
	
	public function shoot(angle:Float, speed:Float):Void
	{
		var bullet:GameEntity = world.getReusableEntityByType(EntityType.ENEMY_BULLET);
		bullet.position.y = y;
		bullet.speed.x = speed*Math.cos(angle);
		bullet.speed.y = speed * Math.sin(angle);
		if (shipType == TESLA) 
		{
			bullet.frameRectNum = 0;
			bullet.position.x = x - 26;
			cast(bullet, EnemyBullet).bulletDamage = 15;
		}
		else 
		{
			bullet.position.x = x;
			bullet.frameRectNum = 1;
			cast(bullet, EnemyBullet).bulletDamage = 30;
		}
		world.addEnemyBullet(bullet);
	}
	
	override public function recieveDamage(damageAmount:Int):Void 
	{
		super.recieveDamage(damageAmount);
		if (Type.getClass(behaviour) == BasicBehaviour) 
		{
			cast(behaviour, BasicBehaviour).respondToDamage();
		}
		if (shipType == TESLA) 
		{
			if (healthPoints < 0) 
			{
				frameRectNum = 2;
			} else if (healthPoints < 100) 
			{
				frameRectNum = 1;
			}
		}
	}
	
	private function createAsBalloon():Void 
	{
		graphicsAsset = GraphicsLibrary.getBaloon();
		var circle:CircleShape= new CircleShape(-10,0,12);
		circle.sensor = true;
		addShape(circle);
		healthPoints = 100;
		speed.x = Std.int(Math.random() * -2 - 1) *10;
		if (Math.random() > 0.5) 
		{
			behaviour = new BaloonBehaviour(this);
		} else 
		{
			behaviour = new KamikazeBaloonBehaviour(this);
		}
	}
	
	private function createAsTesla():Void 
	{
		graphicsAsset = GraphicsLibrary.getTeslaFlyer();
		var shape:Polygon = new Polygon();
		shape.sensor = true;
		shape.setAsBox(50, 12);
		addShape(shape);
		healthPoints = 200;
		if (Math.random() > 0.7) 
		{
			speed.x = Std.int(Math.random() * -4 - 4)*40;
			behaviour = new TeslaBehaviourRam(this);
		} else 
		{
			speed.x = Std.int(Math.random() * -6 - 1)*40;
			behaviour = new TeslaBehaviourFrontalAssault(this);
		}
	}
	
}