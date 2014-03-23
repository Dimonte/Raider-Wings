package sphaeraGravita.spacePartitioning;

import game.GameEntity;
import game.Tile;
import sphaeraGravita.math.Vector2D;
/**
 * ...
 * @author Dmitry Barabanschikov
 */
class UniformGrid
{
	public static inline var CELL_SIZE:Int = 40; //TODO change to 40, make literal
	
	public var cells:Array<GridCell>;
	public var dummy:GridCell;
	public var dirtyCells:Array<GridCell>;
	public var height:Int;
	public var width:Int;
	public var padding:Int;
	public var minX:Int;
	public var maxX:Int;
	public var paddedWidth:Int;
	public var minY:Int;
	public var maxY:Int;
	public var paddedHeight:Int;
	
	private var correctedX:Int;
	private var correctedY:Int;
	
	public function new() 
	{
		dummy = new GridCell();
		cells = new Array();
		dirtyCells = new Array();
	}
	
	/**
	 * Initializes uniform grid
	 * @param	width
	 * @param	height
	 * @param	padding
	 */
	public function initialize(width:Int, height:Int, padding:Int):Void
	{
		dummy = new GridCell();
		dirtyCells = [];
		
		this.width = width;
		this.height = height;
		this.padding = padding;
		
		minX = - padding;
		maxX = width + padding;
		paddedWidth = width + padding * 2;
		minY = - padding;
		maxY = height + padding;
		paddedHeight = height + padding * 2;
		
		var totalNumberOfCells:Int = paddedWidth*paddedHeight;
		
		
		for (i in 0...totalNumberOfCells) 
		{
			if (cells[i] == null)
			{
				cells[i] = new GridCell();
			}
			var cell:GridCell = cells[i];
			cell.activeObjectList.clear();
			cell.fixedObjectList.clear();
			cell.x = Std.int(i / paddedHeight) - padding;
			cell.y = Std.int(i % paddedHeight) - padding;
		}
		
		while (cells.length > totalNumberOfCells) 
		{
			cells.pop();
		}
	}
	
	/**
	 * Cleans all cells containing active objects
	 */
	public function clean():Void
	{
		for (i in 0...dirtyCells.length) 
		{
			dirtyCells[i].activeObjectList.clear();
			dirtyCells[i].dirty = false;
		}
		while (dirtyCells.length > 0) 
		{
			dirtyCells.pop();
		}
		
		dummy.activeObjectList.clear();
	}
	
	/**
	 * Returns cell at (x,y), if out of bounds, returns dummy cell (still usable)
	 * @param	x
	 * @param	y
	 */
	public function getCellAt(x:Int, y:Int):GridCell
	{
		if (x < minX) { return dummy; }
		if (x >= maxX) { return dummy; }
		if (y >= maxY) { return dummy; }
		if (y < minY) { return dummy; }
		correctedX = x + padding;
		correctedY = y + padding;
		return cells[correctedX * paddedHeight + correctedY];
	}
	
	public function placeTile(tile:Tile):Void
	{
		//getCellAt(Int(tile.position.x / CELL_SIZE), Int(tile.position.y / CELL_SIZE)).fixedObjectList.append(tile);
		placeFixedObject(tile);
	}
	
	public function placeFixedObject(object:GameEntity):Void
	{
		var overlappingCells:Array<GridCell> = getCellsBetweenPoints(object.worldAABB.lowerBound, object.worldAABB.upperBound);
		object.overlappingCells = overlappingCells;
		for (i in 0...overlappingCells.length) 
		{
			overlappingCells[i].fixedObjectList.append(object);
		}
	}
	
	public function placeActiveObject(activeObject:GameEntity):Void
	{
		var overlappingCells:Array<GridCell> = getCellsBetweenPoints(activeObject.worldAABB.lowerBound, activeObject.worldAABB.upperBound);
		activeObject.overlappingCells = overlappingCells;
		for (i in 0...overlappingCells.length) 
		{
			overlappingCells[i].activeObjectList.append(activeObject);
			if (overlappingCells[i].dirty) 
			{
				continue;
			} else 
			{
				dirtyCells.push(overlappingCells[i]);
			}
		}
	}
	
	public function getCellsBetweenPoints(pointOne:Vector2D, pointTwo:Vector2D):Array<GridCell>
	{
		var startX:Int = Std.int(pointOne.x / CELL_SIZE);
		var startY:Int = Std.int(pointOne.y / CELL_SIZE);
		var endX:Int = Std.int(pointTwo.x / CELL_SIZE) + 1;
		var endY:Int = Std.int(pointTwo.y / CELL_SIZE) + 1;
		var cellArray:Array<GridCell> = [];
		for (i in startX...endX)
		{
			for (j in  startY...endY) 
			{
				cellArray.push(getCellAt(i, j));
			}
		}
		return cellArray;
	}
	
}