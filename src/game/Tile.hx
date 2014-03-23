package game;

import assets.GraphicsLibrary;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.math.Vector2D;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.shapes.Polygon;

/**
 * ...
 * @author Dimonte
 */
class Tile extends GameEntity
{
	public static inline var MIDDLE:String = "middle";
	public static inline var TOP:String = "top";
	public static inline var SLOPE_UP:String = "slopeUp";
	public static inline var SLOPE_DOWN:String = "slopeDown";
	
	public var template:String;
	
	public function new(world:GameWorld) 
	{
		super(world);
		type = EntityType.TILE;
		collisionCategory = CollisionCategory.TILE;
		graphicsAsset = GraphicsLibrary.getTiles();
	}
	
	public function createFromTemplate(template:String):Void
	{
		clearShapes();
		var shape:Polygon;
		shape = new Polygon();
		this.template = template;
		switch (template) 
		{
			case MIDDLE:
				shape.setAsBox(20, 20);
				frameRectNum = Math.random() > 0.2 ? graphicsAsset.getFrameByAssetName("assets/tiles/middle.png") : graphicsAsset.getFrameByAssetName("assets/tiles/middle2.png");
			case SLOPE_UP:
				shape.setPoly([new Vector2D( -20, 20), new Vector2D( 20, -20), new Vector2D( 20, 20)]);
				frameRectNum = 2;
			case SLOPE_DOWN:
				shape.setPoly([new Vector2D( -20, -20), new Vector2D( 20, 20), new Vector2D( -20, 20)]);
				frameRectNum = 3;
			case TOP:
				shape.setAsBox(20, 20);
				frameRectNum = Math.random() > 0.2 ? graphicsAsset.getFrameByAssetName("assets/tiles/top2.png") : graphicsAsset.getFrameByAssetName("assets/tiles/top.png");
			default:
				shape.setAsBox(20, 20);
		}
		addShape(shape);
		init();
	}
	
	override public function reactToCollision(collidingBody:PhysicalBody, selfShape:BaseShape, otherShape:BaseShape):Void 
	{
		super.reactToCollision(collidingBody, selfShape, otherShape);
		cast(collidingBody, GameEntity).recieveDamage(10);
	}
	
}