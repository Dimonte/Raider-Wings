package view;

import assets.GraphicsLibrary;
import dataStructures.DLL;
import dataStructures.DLLNode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import game.Bullet;
import game.BulletHit;
import game.Debries;
import game.EnemyShip;
import game.Explosion;
import game.GameEntity;
import game.GameStage;
import game.GameWorld;
import game.PlayerShip;
import game.Tile;
import openfl.Assets;
import sphaeraGravita.collision.AABB;
import sphaeraGravita.collision.CollisionResult;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.math.Vector2D;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.shapes.CircleShape;
import sphaeraGravita.shapes.Polygon;
import sphaeraGravita.shapes.ShapeType;
import sphaeraGravita.spacePartitioning.GridCell;
import sphaeraGravita.spacePartitioning.UniformGrid;
/**
 * ...
 * @author Dimonte
 */
class TilesView extends WorldView
{
	public var debugDraw:Bool;
	
	private var _world:GameWorld;
	private var _skyBD:BitmapData;
	private var _worldDrawMarker:Int;
	private var tilesCanvas:Sprite;
	private var toDraw:Array<Float>;
	private var healthBitmap:Bitmap;
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	public function new(gameStage:GameStage, screenWidth:Int, screenHeight:Int) 
	{
		super(gameStage);
		
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		
		_world = gameStage.gameWorld;
		
		_skyBD = Assets.getBitmapData("assets/general/sky.png");
		var skyBitmap:Bitmap = new Bitmap(_skyBD);
		skyBitmap.scaleX = screenWidth / skyBitmap.width;
		skyBitmap.scaleY = screenHeight / skyBitmap.height;
		addChild(skyBitmap);
		
		tilesCanvas = new Sprite();
		addChild(tilesCanvas);
		
		healthBitmap = new Bitmap(new BitmapData(1, 1, false, 0xFFFF0000));
		healthBitmap.scaleY = 10;
		addChild(healthBitmap);
		
		toDraw = new Array();
		
		createScoreDisplay();
	}
	
	override public function update():Void
	{
		super.update();
		tilesCanvas.graphics.clear();
		drawStuff();
	}
	
	public function drawStuff():Void
	{
		_worldDrawMarker = Std.int(_world.activeZoneStartMarker);
		
		
		var toDrawLength:Int = 0;
		
		toDrawLength = addEntityListTiles(_world.tiles, toDraw, toDrawLength);
		toDrawLength = addEntityListTiles(_world.playerBullets, toDraw, toDrawLength);
		if (!_world.player.dead) 
		{
			toDrawLength = drawEntity(_world.player, toDraw, toDrawLength);
		}
		toDrawLength = addEntityListTiles(_world.enemies, toDraw, toDrawLength);
		toDrawLength = addEntityListTiles(_world.particles, toDraw, toDrawLength);
		toDrawLength = addEntityListTiles(_world.enemyBullets, toDraw, toDrawLength);
		
		while (toDraw.length > toDrawLength) 
		{
			toDraw.pop();
		}
		
		
		tilesCanvas.graphics.drawTiles(GraphicsLibrary.tilesheet, toDraw);
		
		//trace( "toDraw : " + toDraw );
		
		if (healthBitmap.scaleX != _world.player.healthPoints * (screenWidth/800))
		{
			healthBitmap.scaleX = _world.player.healthPoints * (screenWidth/800);
		}
	}
	
	private function addEntityListTiles(list:DLL, toDraw:Array<Float>, toDrawLength:Int):Int
	{
		var node:DLLNode = list._head;
		var entity:GameEntity;
		while (node != null) 
		{
			entity = cast(node.val, GameEntity);
			node = node.next;
			if (entity.dead) 
			{
				continue;
			}
			/*if (entity.worldAABB.upperBound.x - _worldDrawMarker < 0) 
			{
				continue;
			}
			if (entity.worldAABB.lowerBound.x - _worldDrawMarker > 800) 
			{
				continue;
			}*/
			
			toDrawLength = drawEntity(entity, toDraw, toDrawLength);
		}
		return toDrawLength;
	}
	
	private function drawEntity(ge:GameEntity, drawList:Array<Float>, toDrawLength:Int):Int
	{
		drawList[toDrawLength] = Std.int(ge.x - _worldDrawMarker + ge.graphicsAsset.sizeCorrection.x);
		toDrawLength++;
		drawList[toDrawLength] = Std.int(ge.y + ge.graphicsAsset.sizeCorrection.y);
		toDrawLength++;
		drawList[toDrawLength] = ge.graphicsAsset.tileSheetFrameID[ge.frameRectNum];
		toDrawLength++;
		return toDrawLength;
	}
	
}