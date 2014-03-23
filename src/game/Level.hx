package game;

import game.TileTemplate;
import haxe.ds.IntMap.IntMap;

/**
 * ...
 * @author Dimonte
 */
class Level
{
	
	static public inline var LEVEL_WIDTH:Int = 600;
	public var tiles:Array<LevelObjectTemplate>;
	public var enemies:Array<LevelObjectTemplate>;
	private var surroundingTiles:Array<Bool>;
	private var levelHeight:Int;
	private var activeZoneWidth:Int;
	private var activeZoneHeight:Int;
	
	static public var templatePriority:Array<TilePositionTemplate> = 
	{
		[TilePositionTemplate.middle, TilePositionTemplate.slopeUp, TilePositionTemplate.slopeDown, TilePositionTemplate.top ];
		
	}
	
	public function new(activeZoneWidth:Int, activeZoneHeight:Int) 
	{
		this.activeZoneWidth = activeZoneWidth;
		this.activeZoneHeight = activeZoneHeight;
		this.levelHeight = Math.ceil(activeZoneHeight/40);
		surroundingTiles = new Array();
		tiles = new Array();
		enemies = new Array();
		var normalHeight:Int = 2;
		var previousHeight:Int = normalHeight;
		var height:Int = previousHeight;
		var heightChangeSpeed:Int = 0;
		var tileGrid:TileGrid = new TileGrid(LEVEL_WIDTH, levelHeight);
		
		var tileTemplate:TileTemplate;
		for (i in 0...LEVEL_WIDTH) 
		{
			var heightChangeSpeedChange:Int = Std.int(Math.random() * 2) + Std.int(Math.random() * 2) - 1;
			if (height > normalHeight && heightChangeSpeed > 0) {
				heightChangeSpeedChange += Math.round((normalHeight - height) / 1);
			}
			if (height < normalHeight && heightChangeSpeed < 0) {
				heightChangeSpeedChange += Math.round((normalHeight - height) / 1);
			}
			heightChangeSpeed += heightChangeSpeedChange;
			height += heightChangeSpeed;
			
			for (j in 0...height) 
			{
				tileTemplate = new TileTemplate();
				tileTemplate.tileGridX = i;
				tileTemplate.tileGridY = levelHeight - 1 - j;
				tileTemplate.position.x = i * 40 + 20;
				tileTemplate.position.y = Std.int(levelHeight - 1 - j) * 40 + 20;
				tiles.push(tileTemplate);
				tileGrid.addTileAt(i, levelHeight - 1 - j, tileTemplate);
			}
			previousHeight = height;
		}
		
		for (i in 0...tiles.length) 
		{
			tileTemplate = cast(tiles[i], TileTemplate);
			findTemplateForTile(tileTemplate, tileGrid);
		}
		
		for (i in 0...160) 
		{
			
			var diffMod:Float = (160 - i) / 160 - 0.4;
			var minShips:Int = Std.int(i / 40) +1;
			var shipsAdded:Int = 0;
			
			while (Math.random() > diffMod || shipsAdded < minShips) 
			{ 
				diffMod += 0.05;
				var enemyShipTemplate:LevelObjectTemplate = new LevelObjectTemplate();
				enemyShipTemplate.position.x = i * 90 + activeZoneWidth + Math.random()*90;
				enemyShipTemplate.position.y = Math.random() * activeZoneHeight/2 + 40;
				enemies.push(enemyShipTemplate);
				shipsAdded++;
			}
		}
		
		tileGrid = null;
	}
	
	private function findTemplateForTile(tileTemplate:TileTemplate, tileGrid:TileGrid):Void
	{
		//To match templates, reading in column/row
		for (j in 0...3)
		{
			for (i in 0...3) 
			{
				surroundingTiles[i+j*3] = tileGrid.isTileAt(i + tileTemplate.tileGridX - 1, j + tileTemplate.tileGridY - 1);
			}
		}
		
		var matchFound:Bool = false;
		var tilePositionTemplate:TilePositionTemplate = null;
		var positionTemplate:Array<Int>;
		for (i in 0...templatePriority.length)
		{
			tilePositionTemplate = templatePriority[i];
			positionTemplate = tilePositionTemplate.template;
			matchFound = true;
			for (j in 0...positionTemplate.length)
			{
				if (positionTemplate[j] == -1) 
				{
					continue;
				}
				if (positionTemplate[j] == 0) 
				{
					if (surroundingTiles[j]) 
					{
						matchFound = false;
						break;
					}
				}
				if (positionTemplate[j] == 1) 
				{
					if (!surroundingTiles[j]) 
					{
						matchFound = false;
						break;
					}
				}
			}
			if (matchFound) 
			{
				break;
			}
		}
		
		if (!matchFound) 
		{
			tilePositionTemplate = TilePositionTemplate.top;
		}
		
		tileTemplate.tileTemplate = tilePositionTemplate.code;
		
	}
	
}

class TileGrid
{
	private var standInTile:TileTemplate;
	private var tileHash:IntMap<IntMap<TileTemplate>>;
	private var width:Int;
	private var height:Int;
	
	public function new(width:Int, height:Int)
	{
		standInTile = new TileTemplate();
		this.width = width;
		this.height = height;
		tileHash = new IntMap();
		var tileColumnHash:IntMap<TileTemplate>;
		for (i in 0...width) 
		{
			tileColumnHash = new IntMap();
			tileHash.set(i, tileColumnHash);
		}
	}
	
	public function addTileAt(x:Int, y:Int, tileTemplate:TileTemplate):Void
	{
		tileHash.get(x).set(y, tileTemplate);
	}
	
	public function getTileAt(x:Int, y:Int):Null<TileTemplate>
	{
		if (x < 0) 
		{
			return null;
		}
		if (x >= width) 
		{
			return null;
		}
		if (y < 0) 
		{
			return null;
		}
		if (y >= height) 
		{
			return standInTile;
		}
		return tileHash.get(x).get(y);
	}
	
	public function isTileAt(x:Int, y:Int):Bool
	{
		if (x < 0) 
		{
			return false;
		}
		if (x >= width) 
		{
			return false;
		}
		if (y < 0) 
		{
			return false;
		}
		if (y >= height) 
		{
			return true;
		}
		return tileHash.get(x).get(y) != null;
	}
}

class TilePositionTemplate
{
	
	static public var slopeUp:TilePositionTemplate = 
	{
		var tilePosTemp:TilePositionTemplate = new TilePositionTemplate();
		tilePosTemp.template = 
		[ -1,  0, -1,
		   0,  1,  1,
		  -1,  1,  1]
		;
		
		/*tilePosTemp.template = 
		[ -1, -1, -1,
		  -1, -1, -1,
		  -1, -1, -1]
		;*/
		
		tilePosTemp.code = Tile.SLOPE_UP;
		tilePosTemp;
	}
	
	static public var slopeDown:TilePositionTemplate = 
	{
		var tilePosTemp:TilePositionTemplate = new TilePositionTemplate();
		tilePosTemp.template = 
		[ -1,  0, -1,
		   1,  1,  0,
		   1,  1, -1]
		;
		tilePosTemp.code = Tile.SLOPE_DOWN;
		tilePosTemp;
	}
	
	static public var middle:TilePositionTemplate = 
	{
		var tilePosTemp:TilePositionTemplate = new TilePositionTemplate();
		tilePosTemp.template = 
		[ -1,  1, -1,
		  -1,  1, -1,
		  -1,  1, -1]
		;
		tilePosTemp.code = Tile.MIDDLE;
		tilePosTemp;
	}
	
	static public var top:TilePositionTemplate = 
	{
		var tilePosTemp:TilePositionTemplate = new TilePositionTemplate();
		tilePosTemp.template = 
		[ -1,  0, -1,
		  -1,  1, -1,
		  -1,  1, -1]
		;
		tilePosTemp.code = Tile.TOP;
		tilePosTemp;
	}
	
	
	public var template:Array<Int>;
	public var code:String;
	
	public function new()
	{
		
	}
}