package assets;

import flash.display.Bitmap;
import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import openfl.Assets;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class GraphicsLibrary
{
	private static var explosionAsset:EntityGraphicsAsset;
	
	private static var playerAsset:EntityGraphicsAsset;
	
	private static var tilesAsset:EntityGraphicsAsset;
	
	private static var bulletAsset:EntityGraphicsAsset;
	
	private static var enemyBulletAsset:EntityGraphicsAsset;
	
	private static var teslaFlyerAsset:EntityGraphicsAsset;
	
	static private var bulletHitAsset:EntityGraphicsAsset;
	
	static private var debriesAsset:EntityGraphicsAsset;
	
	static private var baloonAsset:EntityGraphicsAsset;
	
	static private var railgunTrailAsset:EntityGraphicsAsset;
	
	static private var smokeAsset:EntityGraphicsAsset;
	
	static public var tilesheet:Tilesheet;
	
	public function GraphicsLibrary() 
	{
		
	}
	
	public static function initialize():Void
	{
		explosionAsset = new EntityGraphicsAsset("explosion").initializeFromAssetNames(["assets/effects/explosion1/1.png", "assets/effects/explosion1/2.png", "assets/effects/explosion1/3.png", "assets/effects/explosion1/4.png", "assets/effects/explosion1/5.png"]);
		playerAsset = new EntityGraphicsAsset("player").initializeFromAssetNames(["assets/objects/player/plane01.png"]);
		tilesAsset = new EntityGraphicsAsset("tile").initializeFromAssetNames(["assets/tiles/top.png", "assets/tiles/middle.png", "assets/tiles/slopeUp.png", "assets/tiles/slopeDown.png", "assets/tiles/middle2.png", "assets/tiles/top2.png"]);
		
		bulletAsset = new EntityGraphicsAsset("bullet").initializeFromAssetNames(["assets/effects/projectiles/beam02.png"]);
		enemyBulletAsset = new EntityGraphicsAsset("enemyBullet").initializeFromAssetNames(["assets/effects/projectiles/beam01.png","assets/effects/projectiles/enemyBalloonBullet.png"]);
		bulletHitAsset = new EntityGraphicsAsset("bulletHit").initializeFromAssetNames(["assets/effects/bulletHit/bulletHit.png"]);
		teslaFlyerAsset = new EntityGraphicsAsset("teslaFlyer").initializeFromAssetNames(["assets/objects/enemies/tesla1.png", "assets/objects/enemies/tesla2.png", "assets/objects/enemies/tesla3.png"]);
		baloonAsset = new EntityGraphicsAsset("baloon").initializeFromAssetNames(["assets/objects/enemies/foe02.png"]);
		smokeAsset = new EntityGraphicsAsset("smoke").initializeFromAssetNames(["assets/effects/smoke/smoke01.png", "assets/effects/smoke/smoke02.png", "assets/effects/smoke/smoke03.png", "assets/effects/smoke/smoke04.png", "assets/effects/smoke/smoke05.png"]);
		debriesAsset = new EntityGraphicsAsset("debries").initializeFromAssetNames(["assets/effects/debries/debries1.png", "assets/effects/debries/debries2.png", "assets/effects/debries/debries3.png"]);
		
		#if (!android && !iphone)
		railgunTrailAsset = new EntityGraphicsAsset("railgunTrail").initializeFromAssetNames(["assets/effects/projectiles/railgunTrail.png"]);
		#end
		
		#if (android || iphone)
		createTilesheet([explosionAsset, playerAsset, tilesAsset, bulletAsset, enemyBulletAsset, bulletHitAsset, teslaFlyerAsset, baloonAsset, smokeAsset, debriesAsset]);
		#elseif cpp
		createTilesheet([explosionAsset, playerAsset, tilesAsset, debriesAsset, bulletAsset, enemyBulletAsset, bulletHitAsset, teslaFlyerAsset, baloonAsset, railgunTrailAsset, smokeAsset]);
		#end
	}
	
	static private function createTilesheet(assetArray:Array<EntityGraphicsAsset>):Void
	{
		var maxHeight:Float = 0;
		var totalWidth:Float = 0;
		var assetFrameID:Int = 0;
		for (i in 0...assetArray.length)
		{
			var asset:EntityGraphicsAsset = assetArray[i];
			
			for (j in 0...asset.frameRectangles.length) 
			{
				asset.tileSheetFrameID.push(assetFrameID);
				var tilesheetRect:Rectangle = asset.frameRectangles[j].clone();
				tilesheetRect.x += totalWidth;
				asset.tileSheetRectangles.push(tilesheetRect);
				assetFrameID++;
			}
			maxHeight = Math.max(maxHeight, asset.spriteSheet.height);
			totalWidth += asset.spriteSheet.width;
		}
		
		var bitmapData:BitmapData = new BitmapData(Std.int(totalWidth), Std.int(maxHeight), true, 0);
		
		var currentX:Int = 0;
		for (i in 0...assetArray.length)
		{
			var asset:EntityGraphicsAsset = assetArray[i];
			bitmapData.copyPixels(asset.spriteSheet, new Rectangle(0, 0, asset.spriteSheet.width, asset.spriteSheet.height), new Point(currentX, 0));
			currentX += asset.spriteSheet.width;
			asset.clear();
		}
		
		tilesheet = new Tilesheet(bitmapData);
		for (i in 0...assetArray.length)
		{
			var asset:EntityGraphicsAsset = assetArray[i];
			for (j in 0...asset.tileSheetRectangles.length) 
			{
				tilesheet.addTileRect(asset.tileSheetRectangles[j]);
			}
		}
	}
	
	public static function getExplosion1():EntityGraphicsAsset
	{
		return explosionAsset;
	}
	
	public static function getPlayerShip():EntityGraphicsAsset
	{
		return playerAsset;
		
		/*if (playerAsset != null) 
		{
			return playerAsset;
		}
		
		var bd:BitmapData = new BitmapData(120, 50, true, 0x00000000);
		var playerBitmap:BitmapData = Assets.getBitmapData("assets/objects/player/plane01.png");
		bd.copyPixels(playerBitmap, new Rectangle(0, 0, 120, 50), new Point(0, 0));
		
		playerAsset = new EntityGraphicsAsset();
		playerAsset.spriteSheet = bd;
		playerAsset.frameRectangles = [new Rectangle(0, 0, 120, 50)];
		playerAsset.sizeCorrection = new Point( -60, -25);
		return playerAsset;*/
	}
	
	public static function getTiles():EntityGraphicsAsset
	{
		return tilesAsset;
	}
	
	public static function getDebries():EntityGraphicsAsset
	{
		return debriesAsset;
	}
	
	public static function getBullet():EntityGraphicsAsset
	{
		return bulletAsset;
	}
	
	public static function getEnemyBullet():EntityGraphicsAsset
	{
		return enemyBulletAsset;
	}
	
	public static function getBulletHit():EntityGraphicsAsset
	{
		return bulletHitAsset;
	}
	
	public static function getTeslaFlyer():EntityGraphicsAsset
	{
		return teslaFlyerAsset;
	}
	
	public static function getBaloon():EntityGraphicsAsset
	{
		return baloonAsset;
	}
	
	public static function getRailgunTrail():EntityGraphicsAsset
	{
		return railgunTrailAsset;
	}
	
	static public function getSmoke() 
	{
		return smokeAsset;
	}
	
}