package game;

import com.sphaeraobscura.keyboard.KeyKeeper;
import flash.events.EventDispatcher;
//import utils.logger.Logger;
/**
 * ...
 * @author ...
 */
class GameStage extends EventDispatcher
{
	/**
	 * Speed of moving through level in pixels/second.
	 */
	static private inline var ACTIVE_ZONE_SHIFT:Float= 60;
	
	public var gameWorld:GameWorld;
	public var player:PlayerShip;
	public var playerController:PlayerController;
	private var loadedLevel:Level;
	private var gameOver:Bool;
	private var activeZoneWidth:Int;
	private var activeZoneHeight:Int;
	
	
	
	public function new(activeZoneWidth:Int, activeZoneHeight:Int) 
	{
		super();
		this.activeZoneWidth = activeZoneWidth;
		this.activeZoneHeight = activeZoneHeight;
		gameWorld = new GameWorld(activeZoneWidth, activeZoneHeight);
	}
	
	public function initializeStage():Void
	{
		gameWorld.clear();
		player = new PlayerShip(gameWorld);
		player.position.x = 60;
		player.position.y = 100;
		playerController = new PlayerController(player);
		gameWorld.addActiveEntity(player);
		gameWorld.player = player;
		
		loadLevel(new Level(activeZoneWidth, activeZoneHeight));
		
		gameOver = false;
	}
	
	public function loadLevel(level:Level):Void
	{
		loadedLevel = level;
		//Logger.log("level.tiles.length : " + level.tiles.length);
		
		level.tiles.sort(sortEntityOnX);
		
		level.enemies.sort(sortEntityOnX);
	}
	
	private function sortEntityOnX(a:LevelObjectTemplate, b:LevelObjectTemplate):Int
	{
		if (a.position.x < b.position.x) 
		{
			return 1;
		}
		if (a.position.x > b.position.x) 
		{
			return -1;
		}
		if (a.position.x == b.position.x) 
		{
			return 0;
		}
		return 0;
	}
	
	private function spawnTiles():Void 
	{
		while (loadedLevel.tiles.length > 0) 
		{
			var tileTemplate:LevelObjectTemplate = loadedLevel.tiles[loadedLevel.tiles.length-1];
			if (tileTemplate.position.x <= gameWorld.activeZoneStartMarker + activeZoneWidth + 60) 
			{
				var tile:Tile = cast(gameWorld.getReusableEntityByType(EntityType.TILE), Tile);
				tile.position = tileTemplate.position;
				tile.createFromTemplate(cast(tileTemplate, TileTemplate).tileTemplate);
				gameWorld.addTile(tile);
				loadedLevel.tiles.pop();
			} else 
			{
				break;
			}
		}
	}
	
	private function spawnEnemies():Void 
	{
		while (loadedLevel.enemies.length > 0) 
		{
			var enemyTemplate:LevelObjectTemplate = loadedLevel.enemies[loadedLevel.enemies.length-1];
			if (enemyTemplate.position.x <= gameWorld.activeZoneStartMarker + activeZoneWidth + 60) 
			{
				var enemy:GameEntity = gameWorld.getReusableEntityByType(EntityType.ENEMY_SHIP);
				enemy.x = enemyTemplate.position.x;
				enemy.y = enemyTemplate.position.y;
				gameWorld.addEnemy(enemy);
				loadedLevel.enemies.pop();
			} else 
			{
				break;
			}
		}
	}
	
	public function update(dTime:Float):Void
	{
		if (!player.dead) 
		{
			
			gameWorld.activeZoneStartMarker += ACTIVE_ZONE_SHIFT*dTime;
			player.x += 60*dTime;
			
			playerController.update(dTime);		
			
			spawnEnemies();
			
			spawnTiles();
		}
		else 
		{
			if (!gameOver) 
			{
				gameOver = true;
				dispatchEvent(new GameEvent(GameEvent.GAME_OVER));
			}
		}
		
		
		
		gameWorld.update(dTime);
	}
	
}