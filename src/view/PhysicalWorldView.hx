package view;

import assets.GraphicsLibrary;
import dataStructures.DLL;
import dataStructures.DLLNode;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
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
class PhysicalWorldView extends WorldView
{
	public var debugDraw:Bool;
	
	private var _world:GameWorld;
	private var _canvas:Bitmap;
	private var _skyBD:BitmapData;
	private var _worldDrawMarker:Int;
	private var screenWidth:Int;
	private var screenHeight:Int;
	
	public function new(gameStage:GameStage, screenWidth:Int, screenHeight:Int) 
	{
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		
		super(gameStage);
		
		_skyBD = Assets.getBitmapData("assets/general/sky.png");
		var skyBitmap:Bitmap = new Bitmap(_skyBD);
		skyBitmap.scaleX = screenWidth / skyBitmap.width;
		skyBitmap.scaleY = screenHeight / skyBitmap.height;
		addChild(skyBitmap);
		
		_world = gameStage.gameWorld;
		_canvas = new Bitmap(new BitmapData(screenWidth, screenHeight));
		
		//_canvas.alpha = 0.5;
		addChild(_canvas);
		
		createScoreDisplay();
	}
	
	override public function update():Void
	{
		super.update();
		
		drawStuff();
	}
	
	public function drawStuff():Void
	{
		_worldDrawMarker = Std.int(_world.activeZoneStartMarker);
		_canvas.bitmapData.lock();
		
		_canvas.bitmapData.fillRect(new Rectangle(0, 0, screenWidth, screenHeight), 0x0);
		
		drawEntityList(_world.tiles);
		drawEntityList(_world.playerBullets);
		if (!_world.player.dead) 
		{
			drawEntity(_world.player, true);
		}
		drawEntityList(_world.enemies);
		drawEntityList(_world.particles);
		drawEntityList(_world.enemyBullets);
		
		_canvas.bitmapData.fillRect(new Rectangle(0, 0, _world.player.healthPoints * (screenWidth/800), 10), 0xFFFF0000);
		
		_canvas.bitmapData.unlock();
	}
	
	private function drawEntityList(list:DLL):Void
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
			if (entity.worldAABB.upperBound.x - _worldDrawMarker < 0) 
			{
				continue;
			}
			if (entity.worldAABB.lowerBound.x - _worldDrawMarker > screenWidth) 
			{
				continue;
			}
			
			drawEntity(entity);
			
		}
	}
	
	private function drawEntity(ge:GameEntity, ?debug:Bool = false):Void
	{
		
		if (ge == null) 
		{
			//SOSLog.sosTrace( "ge : " + ge );
			return;
		}
		
		if (ge.graphicsAsset == null) 
		{
			//SOSLog.sosTrace( "ge.graphicsAsset : " + ge.graphicsAsset );
			return;
		}
		
		var sr:Rectangle = ge.graphicsAsset.frameRectangles[ge.frameRectNum];
		var dp:Point = new Point(ge.x - _worldDrawMarker, ge.y).add(ge.graphicsAsset.sizeCorrection);
		var source:BitmapData = ge.graphicsAsset.spriteSheet;
		if (ge.rotation != 0) 
		{
			var sourceClip:BitmapData = new BitmapData(Std.int(sr.width), Std.int(sr.height), true, 0x0);
			sourceClip.copyPixels(source, sr, new Point(0,0));
			var m:Matrix = new Matrix();
			m.createBox(1, 1, ge.rotation, dp.x, dp.y);
			_canvas.bitmapData.draw(sourceClip, m);
		} else
		{
			_canvas.bitmapData.copyPixels(source, sr, dp, null, null, true);
		}
		
	}
	
}