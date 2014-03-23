package sphaeraGravita.shapes;

import sphaeraGravita.collision.AABB;
import sphaeraGravita.math.Vector2D;
/**
 * ...
 * @author Dimonte
 */
class Polygon extends BaseShape
{
	public var vertices:Array<Vector2D>;
	public var normals:Array<Vector2D>;
	private var _worldVerticesCache:Array<Vector2D>;
	public var cacheUpdateRequired:Bool;
	
	public function new() 
	{
		super(ShapeType.POLYGON_SHAPE);
		vertices = new Array();
		normals = new Array();
		_worldVerticesCache = new Array();
	}
	
	public function setPoly(vertices:Array<Vector2D>):Void
	{
		this.vertices = vertices;
		initialize();
	}
	
	public function initialize():Void
	{
		normals.splice(0, normals.length);
		for (i in 0...vertices.length - 1) 
		{
			var edge:Vector2D = vertices[i + 1].clone().subtract(vertices[i]);
			normals[i] = edge.getNormalLeft().normalize();
			//trace("vertex " + i, vertices[i]);
			//_worldVerticesCache[i] = vertices[i].clone().add(position);
		}
		normals[vertices.length - 1] = vertices[0].clone().subtract(vertices[vertices.length - 1]).getNormalLeft().normalize();
	}
	
	public function getWorldVertex(vertexNum:Int):Vector2D
	{
		if (cacheUpdateRequired)
		{
			updateWorldVerticesCache();
		}
		return _worldVerticesCache[vertexNum];
	}
	
	private function updateWorldVerticesCache():Void
	{
		for (i in 0...vertices.length) 
		{
			_worldVerticesCache[i] = body.localToWorld(vertices[i]);
		}
	}
	
	public function getNumVertices():Int
	{
		return vertices.length;
	}
	
	override public function getBoundingAABB():AABB 
	{ 
		var minX:Float = Math.POSITIVE_INFINITY;
		var minY:Float = Math.POSITIVE_INFINITY;
		var maxX:Float = Math.NEGATIVE_INFINITY;
		var maxY:Float = Math.NEGATIVE_INFINITY;
		var vertice:Vector2D;
		for (i in 0...vertices.length) 
		{
			vertice = vertices[i];
			minX = Math.min(minX, vertice.x);
			minY = Math.min(minY, vertice.y);
			maxX = Math.max(maxX, vertice.x);
			maxY = Math.max(maxY, vertice.y);
		}
		
		var boundingAABB:AABB = AABB.asMinMax(minX, minY, maxX, maxY);
		//trace(boundingAABB);
		return boundingAABB;
	}
	
	public function setAsBox(halfWidth:Float, halfHeight:Float):Void 
	{
		vertices[0] = new Vector2D( -halfWidth, -halfHeight);
		vertices[1] = new Vector2D( halfWidth, -halfHeight);
		vertices[2] = new Vector2D( halfWidth, halfHeight);
		vertices[3] = new Vector2D( -halfWidth, halfHeight);
		initialize();
	}
	
}