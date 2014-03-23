package game;

import dataStructures.DLL;
import dataStructures.DLLNode;
import flash.errors.Error;
import game.CollisionCategory;
import game.GameEntity;
import haxe.ds.GenericStack;
import haxe.ds.StringMap;
import sphaeraGravita.collision.CollisionEngine;
import sphaeraGravita.spacePartitioning.GridCell;
import sphaeraGravita.spacePartitioning.UniformGrid;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class GameWorld
{
	public var activeZoneStartMarker:Float;
	
	public var collisionEngine:CollisionEngine;
	
	public var grid:UniformGrid;
	
	public var player:PlayerShip;
	public var players:DLL;
	public var tiles:DLL;
	//public var stationaryObjects:DLL;
	public var particles:DLL;
	public var enemies:DLL;
	public var playerBullets:DLL;
	public var enemyBullets:DLL;
	
	public var score:Int;
	
	private var reuseLists:StringMap<GenericStack<GameEntity>>;
	
	private var activeZoneWidth:Int;
	private var activeZoneHeight:Int;
	
	public function new(activeZoneWidth:Int, activeZoneHeight:Int) 
	{
		this.activeZoneWidth = activeZoneWidth;
		this.activeZoneHeight = activeZoneHeight;
		
		activeZoneStartMarker = 0;
		reuseLists = new StringMap();
		collisionEngine = new CollisionEngine();
		players = new DLL();
		playerBullets = new DLL();
		enemyBullets = new DLL();
		tiles = new DLL();
		enemies = new DLL();
		particles = new DLL();
		grid = new UniformGrid();
		grid.initialize(Level.LEVEL_WIDTH, Math.ceil(activeZoneHeight/40), 4);
	}
	
	public function clear():Void
	{
		player = null;
		players.clear();
		tiles.clear();
		//stationaryObjects.clear();
		particles.clear();
		enemies.clear();
		playerBullets.clear();
		enemyBullets.clear();
		
		grid.initialize(Level.LEVEL_WIDTH, Math.ceil(activeZoneHeight/40), 4);
		score = 0;
		activeZoneStartMarker = 0;
	}
	
	private function initializeFixedEntities():Void
	{
		
	}
	
	public function addActiveEntity(gameEntity:GameEntity):Void
	{
		players.append(gameEntity);
	}
	
	public function addEnemy(enemy:GameEntity):Void
	{
		enemies.append(enemy);
	}
	
	public function addPlayerBullet(gameEntity:GameEntity):Void
	{
		playerBullets.append(gameEntity);
	}
	
	public function addEnemyBullet(gameEntity:GameEntity):Void
	{
		enemyBullets.append(gameEntity);
	}
	
	public function addFixedEntiry(gameEntity:GameEntity):Void
	{
		tiles.append(gameEntity);
		gameEntity.updateWorldCache();
	}
	
	public function addTile(tile:Tile):Void
	{
		tiles.append(tile);
		tile.updateWorldCache();
		grid.placeTile(tile);
	}
	
	public function addParticle(particle:GameEntity):Void
	{
		particle.updateWorldCache();
		grid.placeActiveObject(particle);
		particles.append(particle);
	}
	
	public function update(dTime:Float):Void
	{
		grid.clean();
		
		//trace(playerBullets.length);
		
		updatePositionsInList(players, dTime);
		if (player.worldAABB.lowerBound.x < activeZoneStartMarker)
		{
			player.position.x += activeZoneStartMarker - player.worldAABB.lowerBound.x;
			player.updateWorldCache();
		}
		
		if (player.worldAABB.upperBound.x > activeZoneStartMarker+activeZoneWidth)
		{
			player.position.x += activeZoneStartMarker + activeZoneWidth - player.worldAABB.upperBound.x;
			player.updateWorldCache();
		}
		
		if (player.worldAABB.lowerBound.y < 0)
		{
			player.position.y += 0 - player.worldAABB.lowerBound.y;
			player.updateWorldCache();
		}
		
		if (player.worldAABB.upperBound.y > activeZoneHeight && player.healthPoints > 0)
		{
			player.position.y += activeZoneHeight - player.worldAABB.upperBound.y;
			player.updateWorldCache();
		}
		
		updateTiles();
		
		updatePositionsInList(playerBullets, dTime);
		updatePositionsInList(enemyBullets, dTime);
		updatePositionsInList(enemies, dTime);
		updatePositionsInList(particles, dTime);
		
		collideObjectWithGrid(player);
		collideListWithList(players, enemies);
		collideListWithList(players, particles);
		collideListWithGrid(enemies, grid);
		collideListWithGrid(playerBullets, grid);
		collideListWithGrid(enemyBullets, grid);
		collideListWithGrid(particles, grid);
		
		updateLogicInList(players, dTime);
		updateLogicInList(playerBullets, dTime);
		updateLogicInList(enemies, dTime);
		updateLogicInList(particles, dTime);
	}
	
	private function updateTiles() 
	{
		var activeBodyNode:DLLNode = tiles._head;
		var activeBody:GameEntity;
		while (activeBodyNode != null) 
		{
			activeBody = cast(activeBodyNode.val, GameEntity);
			if (activeBody.worldAABB.upperBound.x < activeZoneStartMarker) 
			{
				tiles.remove(activeBodyNode);
				placeEntityForReuse(activeBody);
			}
			
			activeBodyNode = activeBodyNode.next;
		}
	}
	
	public function updatePositionsInList(list:DLL, dTime:Float):Void
	{
		var activeBodyNode:DLLNode = list._head;
		var activeBody:GameEntity;
		while (activeBodyNode != null) 
		{
			activeBody = cast(activeBodyNode.val, GameEntity);
			if (activeBody.dead) 
			{
				list.remove(activeBodyNode); //TODO transfer to logic update?
				placeEntityForReuse(activeBody);
			} else {
				activeBody.position.x += activeBody.speed.x*dTime;
				activeBody.position.y += activeBody.speed.y*dTime;
				activeBody.updateWorldCache();
				if (activeBody.gridBound) 
				{
					grid.placeActiveObject(activeBody);
				}
				if (activeBody.unguidedProjectile) 
				{
					if (!activeBody.inBounds(activeZoneStartMarker, 0, activeZoneWidth, activeZoneHeight)) 
					{
						activeBody.dead = true;
					}
				}
			}
			
			activeBodyNode = activeBodyNode.next;
		}
	}
	
	public function placeEntityForReuse(activeBody:GameEntity) 
	{
		if (activeBody.type == EntityType.UNKNOWN) 
		{
			throw new Error("Unknown type of reusable asset");
			return;
		}
		var reuseList:GenericStack<GameEntity> = reuseLists.get(activeBody.type);
		if (reuseList == null) 
		{
			reuseList = new GenericStack<GameEntity>();
			reuseLists.set(activeBody.type, reuseList);
		}
		reuseList.add(activeBody);
	}
	
	public function getReusableEntityByType(type:String):GameEntity
	{
		var newEntity:GameEntity = null;
		
		var reuseList:GenericStack<GameEntity> = reuseLists.get(type);
		if (reuseList != null) 
		{
			if (reuseList.head != null) 
			{
				newEntity = reuseList.pop();
				newEntity.reset();
				return newEntity;
			}
		}
		
		switch (type) 
		{
			case EntityType.BULLET_HIT:
				newEntity = new BulletHit(this);
			case EntityType.ENEMY_BULLET:
				newEntity = new EnemyBullet(this);
			case EntityType.PLAYER:
				newEntity = new PlayerShip(this);
			case EntityType.PLAYER_BULLET:
				newEntity = new Bullet(this);
			case EntityType.RAILGUN_TRAIL:
				newEntity = new RailgunTrail(this);
			case EntityType.ENEMY_SHIP:
				newEntity = new EnemyShip(this);
			case EntityType.DEBRIES:
				newEntity = new Debries(this);
			case EntityType.EXPLOSION:
				newEntity = new Explosion(this);
			case EntityType.TILE:
				newEntity = new Tile(this);
			case EntityType.SMOKE:
				newEntity = new SmokeParticle(this);
			default:
				newEntity = new GameEntity(this);
		}
		
		return newEntity;
	}
	
	public function updateLogicInList(list:DLL, dTime:Float):Void
	{
		var activeBodyNode:DLLNode = list._head;
		var activeBody:GameEntity;
		while (activeBodyNode != null) 
		{
			
			activeBody = cast(activeBodyNode.val, GameEntity);
			activeBodyNode = activeBodyNode.next;
			activeBody.update(dTime);
			
		}
	}
	
	public function collideListWithList(listOne:DLL, listTwo:DLL):Void
	{
		var listOneNode:DLLNode = listOne._head;
		var listOneEntity:GameEntity;
		while (listOneNode != null) 
		{
			listOneEntity = cast(listOneNode.val, GameEntity);
			var listTwoNode:DLLNode = listTwo._head;
			var listTwoEntity:GameEntity;
			while (listTwoNode != null)
			{
				listTwoEntity = cast(listTwoNode.val, GameEntity);
				collisionEngine.collideBodies(listOneEntity, listTwoEntity);
				listTwoNode = listTwoNode.next;
			}
			listOneNode = listOneNode.next;
		}
	}
	
	public function collideObjectWithGrid(object:GameEntity):Void
	{
		if (object.collisionCategory == CollisionCategory.IGNORE)
			return;
		
		var coveredCells:Array<GridCell>;
		if (object.gridBound) 
		{
			coveredCells = object.overlappingCells;
		} else 
		{
			coveredCells = grid.getCellsBetweenPoints(object.worldAABB.lowerBound, object.worldAABB.upperBound); 
		}
		var cellListNode:DLLNode;
		var cellObject:GameEntity;
		//trace("coveredCells.length: " + coveredCells.length);
		for (i in 0...coveredCells.length) 
		{
			cellListNode = coveredCells[i].fixedObjectList._head;
			while (cellListNode != null)
			{
				cellObject = cast(cellListNode.val, GameEntity);
				
				if (cellObject != object)
					collisionEngine.collideBodies(object, cellObject);
				
				cellListNode = cellListNode.next;
			}
			cellListNode = coveredCells[i].activeObjectList._head;
			while (cellListNode != null)
			{
				cellObject = cast(cellListNode.val, GameEntity);
				
				if (cellObject != object)
					collisionEngine.collideBodies(object, cellObject);
				
				cellListNode = cellListNode.next;
			}
		}
	}
	
	public function collideListWithGrid(list:DLL, grid:UniformGrid):Void
	{
		var listNode:DLLNode = list._head;
		while (listNode != null) 
		{
			collideObjectWithGrid(cast(listNode.val, GameEntity));
			listNode = listNode.next;
		}
	}
	
}