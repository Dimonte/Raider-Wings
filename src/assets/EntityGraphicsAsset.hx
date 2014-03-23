package assets;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import haxe.ds.IntMap.IntMap;
import haxe.ds.StringMap.StringMap;
import haxe.ds.StringMap.StringMap;
import openfl.Assets;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class EntityGraphicsAsset
{
	public var assetID:String;
	public var spriteSheet:BitmapData;
	public var frameRectangles:Array<Rectangle>;
	public var tileSheetRectangles:Array<Rectangle>;
	public var tileSheetFrameID:Array<Int>;
	public var sizeCorrection:Point;
	public var assetFrameByName:StringMap<Int>;
	
	public function new(assetID:String)
	{
		this.assetID = assetID;
		frameRectangles = new Array();
		tileSheetFrameID = new Array();
		tileSheetRectangles = new Array();
		assetFrameByName = new StringMap();
	}
	
	public function initializeFromAssetNames(namesArray:Array<String>):EntityGraphicsAsset
	{
		var sourceAssets:Array<BitmapData> = [];
		var numAssets:Int = namesArray.length;
		var maxWidth:Int = 0;
		var maxHeight:Int = 0;
		for (i in 0...numAssets)
		{
			//trace(namesArray[i]);
			var asset:BitmapData = Assets.getBitmapData(namesArray[i]);
			maxWidth = Std.int(Math.max(maxWidth, asset.width));
			maxHeight = Std.int(Math.max(maxHeight, asset.height));
			sourceAssets.push(asset);
			assetFrameByName.set(namesArray[i], i);
		}
		
		//TODO only for non-flash targets
		#if (!flash)
		maxWidth = Math.ceil(Std.int(Math.max(maxWidth, maxHeight))/2)*2;
		maxHeight = maxWidth;
		#end
		
		sizeCorrection = new Point(-maxWidth / 2, -maxHeight/2);
		
		frameRectangles = new Array();
		
		#if flash
		spriteSheet = new BitmapData(numAssets * maxWidth, numAssets*maxHeight, true, 0x0);
		#else
		spriteSheet = new BitmapData(numAssets * maxWidth, numAssets*maxHeight, true, 0x0);
		#end
		
		for (i in 0...numAssets)
		{
			var destinationRectangle:Rectangle = new Rectangle(i * maxWidth, 0, maxWidth, maxHeight);
			//trace(destinationRectangle);
			frameRectangles.push(destinationRectangle);
			var sourceWidth:Int = sourceAssets[i].width;
			var sourceHeight:Int = sourceAssets[i].height;
			spriteSheet.copyPixels(sourceAssets[i], new Rectangle(0, 0, sourceWidth, sourceHeight), new Point(destinationRectangle.x + Std.int((maxWidth - sourceWidth) / 2), destinationRectangle.y + Std.int((maxHeight - sourceHeight) / 2)));
		}
		
		return this;
	}
	
	public function getFrameByAssetName(assetName:String):Int
	{
		var assetFrame:Null<Int> = assetFrameByName.get(assetName);
		if (assetFrame != null) 
		{
			return assetFrame;
		}
		return 0;
	}
	
	public function clear() 
	{
		spriteSheet.dispose();
	}
	
}