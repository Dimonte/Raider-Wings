package sphaeraGravita.collision;

import dataStructures.DLLNode;
import game.CollisionCategory;
import game.GameEntity;
import sphaeraGravita.collision.PhysicalBody;
import sphaeraGravita.math.Vector2D;
import sphaeraGravita.shapes.BaseShape;
import sphaeraGravita.shapes.CircleShape;
import sphaeraGravita.shapes.Polygon;
import sphaeraGravita.shapes.ShapeType;

/**
 * ...
 * @author Dimonte
 */
class CollisionEngine
{
	/**
	 * WARNING! Gets overwritten every time project<...> functions are called.
	 */
	private var projectionResult:ProjectionResult;
	
	private var intervalOne:Float;
	private var intervalTwo:Float;
	private var min:Float;
	private var max:Float;
	private var projectionPoint:Float;
	private var verticeNum:Int;
	private var i:Int;
	
	public function new() 
	{
		projectionResult = new ProjectionResult();
	}
	
	public function collideBodies(entityOne:PhysicalBody, entityTwo:PhysicalBody):Void
	{
		
		//trace("collideBodies > " + entityOne + " - " + entityTwo);
		
		if (entityOne.dead || entityTwo.dead) 
		{
			return;
		}
		if(!matchCollisionCategories(entityOne, entityTwo))
		{
			return;
		}
		if (!queryBoundsIntersection(entityOne, entityTwo)) 
		{
			return;
		}
		//trace("full cd");
		var collisionResult:CollisionResult;
		var bodyOneShape:BaseShape = entityOne.shapeList;
		while (bodyOneShape != null) 
		{
			var bodyTwoShape:BaseShape;
			bodyTwoShape = entityTwo.shapeList;
			while (bodyTwoShape != null) 
			{
				if (bodyOneShape.collisionMask != 0 || bodyOneShape.collisionCategory != CollisionCategory.INHERIT || bodyTwoShape.collisionMask != 0 || bodyTwoShape.collisionCategory != CollisionCategory.INHERIT)
				{
					if (!matchCollisionCategories(bodyOneShape, bodyTwoShape))
					{
						bodyTwoShape = bodyTwoShape.next;
						continue;
					}
				}
				
				//trace("bodyTwoShape : " + bodyTwoShape);
				if (bodyOneShape.sensor || bodyTwoShape.sensor) 
				{
					//trace("huh?");
					if (queryShapes(bodyOneShape, bodyTwoShape)) 
					{
						entityOne.reactToCollision(entityTwo, bodyOneShape, bodyTwoShape);
						entityTwo.reactToCollision(entityOne, bodyTwoShape, bodyOneShape);
					}
				}
				else 
				{
					collisionResult = collideShapes(bodyOneShape, bodyTwoShape);
					if (collisionResult != null)
					{
						if (collisionResult.collision) 
						{
							collisionResult.calculateMTDVector();
							var bounceCoefficient:Float = entityOne.bounceFactor * entityTwo.bounceFactor;
							entityOne.position.x += collisionResult.mtdVector.x * bounceCoefficient;
							entityOne.position.y += collisionResult.mtdVector.y * bounceCoefficient;
							var frictionCoefficient:Float = entityOne.frictionFactor * entityTwo.frictionFactor;
							var firstReflectingComponent:Vector2D = Vector2D.project(entityOne.speed, collisionResult.mtdAxis).invert().multiply(bounceCoefficient);
							var firstFrictionComponent:Vector2D = Vector2D.project(entityOne.speed, collisionResult.mtdAxis.getNormalRight()).multiply(frictionCoefficient);
							var speedProjection:Vector2D = Vector2D.project(entityOne.speed, collisionResult.mtdAxis);
							if (Vector2D.dotProduct(entityOne.speed, collisionResult.mtdVector) < 0)
							{
								entityOne.speed = (firstReflectingComponent.add(firstFrictionComponent));
							}
							
							//TODO entityTwo speed after collision
							
							entityOne.reactToCollision(entityTwo, bodyOneShape, bodyTwoShape);
							entityTwo.reactToCollision(entityOne, bodyTwoShape, bodyOneShape);
						}
					}
				}
				bodyTwoShape = bodyTwoShape.next;
			}
			bodyOneShape = bodyOneShape.next;
		}
	}
	
	public function matchCollisionCategories(entityOne:CollidingEntity, entityTwo:CollidingEntity):Bool
	{
		//trace("matchCollisionCategories > " + entityOne + " - " + entityTwo);
		
		//trace("entityOne.collisionMask " + entityOne.collisionMask);
		//trace("entityTwo.collisionCategory " + entityTwo.collisionCategory);
		
		if (entityOne.collisionMask != 0 && (entityOne.collisionMask & entityTwo.collisionCategory == 0))
			return false;
		
		//trace("entityTwo.collisionMask " + entityTwo.collisionMask);
		//trace("entityOne.collisionCategory " + entityOne.collisionCategory);
		
		if (entityTwo.collisionMask != 0 && (entityTwo.collisionMask & entityOne.collisionCategory == 0))
			return false;
		
		return true;
	}
	
	public function collideShapes(shapeOne:BaseShape, shapeTwo:BaseShape):CollisionResult
	{
		var shapeCollisionResult:CollisionResult = null;
		var tempCollisionResult:CollisionResult = null;
		if (shapeOne.type == ShapeType.POLYGON_SHAPE)
		{
			if (shapeTwo.type == ShapeType.POLYGON_SHAPE)
			{
				shapeCollisionResult = detectPolygons(cast(shapeOne,Polygon), cast(shapeTwo,Polygon));
			}
			else if (shapeTwo.type == ShapeType.CIRCLE_SHAPE)
			{
				shapeCollisionResult = detectPolyCircle(cast(shapeTwo, CircleShape), cast(shapeOne, Polygon));
				if (shapeCollisionResult != null) 
				{
					shapeCollisionResult.mtdAmount = -shapeCollisionResult.mtdAmount;
				}
			}
		} 
		else if (shapeOne.type == ShapeType.CIRCLE_SHAPE)
		{
			if (shapeTwo.type == ShapeType.CIRCLE_SHAPE)
			{
				shapeCollisionResult = detectCircleCircle(cast(shapeOne,CircleShape), cast(shapeTwo,CircleShape));
			}
			else if (shapeTwo.type == ShapeType.POLYGON_SHAPE) 
			{
				shapeCollisionResult = detectPolyCircle(cast(shapeOne,CircleShape), cast(shapeTwo,Polygon));
			}
		}
		return shapeCollisionResult;
	}
	
	public function queryShapes(shapeOne:BaseShape, shapeTwo:BaseShape):Bool
	{
		var tempCollisionResult:CollisionResult = null;
		if (shapeOne.type == ShapeType.POLYGON_SHAPE)
		{
			if (shapeTwo.type == ShapeType.POLYGON_SHAPE)
			{
				tempCollisionResult = detectPolygons(cast(shapeOne,Polygon), cast(shapeTwo,Polygon));
			}
			else if (shapeTwo.type == ShapeType.CIRCLE_SHAPE)
			{
				tempCollisionResult = detectPolyCircle(cast(shapeTwo,CircleShape), cast(shapeOne,Polygon));
			}
		} 
		else if (shapeOne.type == ShapeType.CIRCLE_SHAPE)
		{
			if (shapeTwo.type == ShapeType.CIRCLE_SHAPE)
			{
				tempCollisionResult = detectCircleCircle(cast(shapeOne,CircleShape), cast(shapeTwo,CircleShape));
			}
			else if (shapeTwo.type == ShapeType.POLYGON_SHAPE) 
			{
				tempCollisionResult = detectPolyCircle(cast(shapeOne,CircleShape), cast(shapeTwo,Polygon));
			}
		}
		if (tempCollisionResult != null) 
		{
			if (tempCollisionResult.collision) 
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * 
	 * @param	bodyOne
	 * @param	bodyTwo
	 * @return collision result, mtd is for the FIRST body
	 */
	public function collide(bodyOne:PhysicalBody, bodyTwo:PhysicalBody):CollisionResult
	{
		var collisionResult:CollisionResult = new CollisionResult();
		collisionResult.mtdAmount = Math.POSITIVE_INFINITY;
		var tempCollisionResult:CollisionResult = collisionResult;
		var bodyOneShape:BaseShape;
		var bodyTwoShape:BaseShape;
		if (queryBoundsIntersection(bodyOne, bodyTwo))
		{
			bodyOneShape = bodyOne.shapeList;
			while (bodyOneShape != null)
			{
				bodyTwoShape = bodyTwo.shapeList;
				while (bodyTwoShape != null)
				{
					if (bodyOneShape.type == ShapeType.POLYGON_SHAPE)
					{
						if (bodyTwoShape.type == ShapeType.POLYGON_SHAPE)
						{
							tempCollisionResult = detectPolygons(cast(bodyOneShape,Polygon), cast(bodyTwoShape,Polygon));
						}
						else if (bodyTwoShape.type == ShapeType.CIRCLE_SHAPE)
						{
							tempCollisionResult = detectPolyCircle(cast(bodyTwoShape,CircleShape), cast(bodyOneShape,Polygon));
							tempCollisionResult.mtdAmount = -tempCollisionResult.mtdAmount;
						}
					} 
					else if (bodyOneShape.type == ShapeType.CIRCLE_SHAPE)
					{
						if (bodyTwoShape.type == ShapeType.CIRCLE_SHAPE)
						{
							tempCollisionResult = detectCircleCircle(cast(bodyOneShape,CircleShape), cast(bodyTwoShape,CircleShape));
						}
						else if (bodyTwoShape.type == ShapeType.POLYGON_SHAPE) 
						{
							tempCollisionResult = detectPolyCircle(cast(bodyOneShape, CircleShape), cast(bodyTwoShape,Polygon));
						}
					}
					if(tempCollisionResult.collision)
					{
						if (!collisionResult.collision)
						{
							collisionResult = tempCollisionResult;
							collisionResult.calculateMTDVector();
						} else {
							collisionResult.mtdVector.add(tempCollisionResult.calculateMTDVector());
						}
					}
					bodyTwoShape = bodyTwoShape.next;
				}
				bodyOneShape = bodyOneShape.next;
			}
		}
		// TODO sensor shapes
		// TODO immidiate vs delayed logic response
		/*var bodyOneShapeOne:BaseShape = bodyOne.shapeList.head().val as BaseShape;
		var bodyTwoShapeOne:BaseShape = bodyTwo.shapeList.head().val as BaseShape;
		if ((bodyTwoShapeOne.type == ShapeType.AABB_SHAPE) && (bodyOneShapeOne.type == ShapeType.AABB_SHAPE))
		{
			collisionResult = collideAABBToAABB(bodyOneShapeOne as AABB, bodyTwoShapeOne as AABB);
			if (collisionResult.collision)
			{
				//trace("Collision! " + collisionResult.mtdVector.toString());
				bodyOne.position.x += collisionResult.mtdVector.x;
				bodyOne.position.y += collisionResult.mtdVector.y;
				var firstReflectingComponent:Vector2D = Vector2D.project(bodyOne.speed.clone().invert(), collisionResult.mtdAxis).multiply(0.9);
				var firstFrictionComponent:Vector2D = Vector2D.project(bodyOne.speed, collisionResult.mtdAxis.getNormalRight()).multiply(0.8);
				bodyOne.speed = (firstReflectingComponent.add(firstFrictionComponent));
			}
		}*/
		return collisionResult;
	}
	
	public function queryBoundsIntersection(bodyOne:PhysicalBody, bodyTwo:PhysicalBody):Bool
	{
		var bodyOneLowerBound:Vector2D = bodyOne.worldAABB.lowerBound;
		var bodyOneUpperBound:Vector2D = bodyOne.worldAABB.upperBound;
		var bodyTwoLowerBound:Vector2D = bodyTwo.worldAABB.lowerBound;
		var bodyTwoUpperBound:Vector2D = bodyTwo.worldAABB.upperBound;
		
		if (bodyOneLowerBound.x >= bodyTwoUpperBound.x)
		{
			return false;
		}
		if (bodyOneLowerBound.y >= bodyTwoUpperBound.y)
		{
			return false;
		}
		if (bodyOneUpperBound.x <= bodyTwoLowerBound.x)
		{
			return false;
		}
		if (bodyOneUpperBound.y <= bodyTwoLowerBound.y)
		{
			return false;
		}
		return true;
	}
	
	private function detectPolygons(firstPoly:Polygon, secondPoly:Polygon):Null<CollisionResult>
	{
		var resultMTD:Float = Math.POSITIVE_INFINITY;
		var mtdAxis:Vector2D = null;
		
		var testAxisList:Array<Vector2D> = new Array();
		
		var firstPolyVertexNum:Int = firstPoly.getNumVertices();
		var secondPolyVertexNum:Int = secondPoly.getNumVertices();
		var totalVerges:Int = firstPolyVertexNum + secondPolyVertexNum;
		var firstVerticeSet:Array<Vector2D> = [];
		var body:PhysicalBody = firstPoly.body;
		for (i in 0...firstPoly.getNumVertices()) 
		{
			firstVerticeSet[i] = body.localToWorld(firstPoly.vertices[i]);
			testAxisList.push(firstPoly.normals[i].clone().applyXform(body.xform));
		}
		
		var firstMin:Float = 0;
		var firstMax:Float = 0;
		var secondMin:Float = 0;
		var secondMax:Float = 0;
		var intervalOneAbs:Float = 0;
		var intervalTwoAbs:Float = 0;
		var firstPolyProjection:ProjectionResult;
		var secondPolyProjection:ProjectionResult;
		
		var secondVerticeSet:Array<Vector2D> = [];
		body = secondPoly.body;
		for (i in 0...secondPoly.getNumVertices()) 
		{
			secondVerticeSet[i] = secondPoly.body.localToWorld(secondPoly.vertices[i]);
			testAxisList.push(secondPoly.normals[i].clone().applyXform(body.xform));
		}
		for (i in 0...totalVerges) 
		{
			var testAxis:Vector2D;
			testAxis = testAxisList[i];
			
			firstPolyProjection = projectVerticeSetOnAxis(firstVerticeSet, testAxis);
			firstMin = firstPolyProjection.min;
			firstMax = firstPolyProjection.max;
			
			secondPolyProjection = projectVerticeSetOnAxis(secondVerticeSet, testAxis);
			secondMin = secondPolyProjection.min;
			secondMax = secondPolyProjection.max;
			
			if (secondMin > firstMax)
			{
				return null;
			}
			if (firstMin > secondMax)
			{
				return null;
			}
			
			intervalOne = secondMin - firstMax;
			intervalTwo = secondMax - firstMin;
			intervalOneAbs = intervalOne < 0 ? -intervalOne:intervalOne;
			intervalTwoAbs = intervalTwo < 0 ? -intervalTwo:intervalTwo;
			
			// use faster math for ABSes or get rid of 'em
			if (intervalTwoAbs < intervalOneAbs)
			{
				intervalOneAbs = intervalTwoAbs;
				if (intervalTwo < 0)
				{
					testAxis = testAxis.clone().invert();
				}
			} else {
				if (intervalOne < 0)
				{
					testAxis = testAxis.clone().invert();
				}
			}
			
			if (intervalOneAbs < resultMTD)
			{
				//trace(interval);
				resultMTD = intervalOneAbs;
				mtdAxis = testAxis.clone();
			}
		}
		
		var result:CollisionResult = new CollisionResult();
		result.mtdAmount = resultMTD;
		result.mtdAxis = mtdAxis;
		result.collision = true;
		
		return result;
	}
	
	public function detectPolyCircle(circle:CircleShape, poly:Polygon):Null<CollisionResult>
	{
		
		
		var resultMTD:Float = Math.POSITIVE_INFINITY;
		var mtdAxis:Vector2D = null;
		var collision:Bool = true;
		
		var circlePosition:Vector2D = circle.body.localToWorld(circle.position);
		
		var totalEdges:Int = poly.getNumVertices();
		
		var polyVerticeSet:Array<Vector2D> = [];
		for (i in 0...totalEdges) 
		{
			polyVerticeSet[i] = poly.body.localToWorld(poly.vertices[i]);
		}
		
		var testAxis:Vector2D;
		var circleProjection:ProjectionResult;
		var secondPolyProjection:ProjectionResult;
		var intervalOneAbs:Float;
		var intervalTwoAbs:Float;
		
		var circleMin:Float = 0;
		var circleMax:Float = 0;
		var polyMin:Float = 0;
		var polyMax:Float = 0;
		var intervalOneAbs:Float = 0;
		var intervalTwoAbs:Float = 0;
		
		for (i in 0...totalEdges) 
		{
			//*
			testAxis = poly.normals[i].clone().applyXform(poly.body.xform);
			/*/
			testAxis = poly.normals[i].clone();
			//*/
			
			circleProjection = projectCircleOnAxis(circle, testAxis);
			circleMin = circleProjection.min;
			circleMax = circleProjection.max;
			
			secondPolyProjection = projectVerticeSetOnAxis(polyVerticeSet, testAxis);
			polyMin = secondPolyProjection.min;
			polyMax = secondPolyProjection.max;
			
			if (polyMin > circleMax)
			{
				return null;
			}
			if (circleMin > polyMax)
			{
				return null;
			}
			intervalOne = polyMin - circleMax;
			intervalTwo = polyMax - circleMin;
			intervalOneAbs = intervalOne < 0 ? -intervalOne:intervalOne;
			intervalTwoAbs = intervalTwo < 0 ? -intervalTwo:intervalTwo;
			// use faster math for ABSes or get rid of 'em
			if (intervalTwoAbs < intervalOneAbs)
			{
				intervalOneAbs = intervalTwoAbs;
				if (intervalTwo < 0)
				{
					testAxis = testAxis.invert();
				}
			} else {
				if (intervalOne < 0)
				{
					testAxis = testAxis.invert();
				}
			}
			
			if (intervalOneAbs < resultMTD)
			{
				resultMTD = intervalOneAbs;
				mtdAxis = testAxis;
			}
		}
		for (i in 0...totalEdges) 
		{
			testAxis = circle.body.localToWorld(circle.position).subtract(poly.body.localToWorld(poly.vertices[i])).normalize();
			
			circleProjection = projectCircleOnAxis(circle, testAxis);
			circleMin = circleProjection.min;
			circleMax = circleProjection.max;
			secondPolyProjection = projectVerticeSetOnAxis(polyVerticeSet, testAxis);
			polyMin = secondPolyProjection.min;
			polyMax = secondPolyProjection.max;
			
			if (polyMin > circleMax)
			{
				return null;
			}
			if (circleMin > polyMax)
			{
				return null;
			}
			intervalOne = polyMin - circleMax;
			intervalTwo = polyMax - circleMin;
			intervalOneAbs = intervalOne < 0 ? -intervalOne:intervalOne;
			intervalTwoAbs = intervalTwo < 0 ? -intervalTwo:intervalTwo;
			// use faster math for ABSes or get rid of 'em
			if (intervalTwoAbs < intervalOneAbs)
			{
				intervalOneAbs = intervalTwoAbs;
				if (intervalTwo < 0)
				{
					testAxis = testAxis.invert();
				}
			} else {
				if (intervalOne < 0)
				{
					testAxis = testAxis.invert();
				}
			}
			
			if (intervalOneAbs < resultMTD)
			{
				resultMTD = intervalOneAbs;
				mtdAxis = testAxis;
			}
		}
		
		var result:CollisionResult = new CollisionResult();
		result.mtdAmount = resultMTD;
		result.mtdAxis = mtdAxis;
		result.collision = true;
		
		return result;
		//*/
	}
	
	private function detectCircleCircle(circleOne:CircleShape, circleTwo:CircleShape):Null<CollisionResult>
	{
		var circleOneWorldPosition:Vector2D = circleOne.body.localToWorld(circleOne.position);
		var circleTwoWorldPosition:Vector2D = circleTwo.body.localToWorld(circleTwo.position);
		var distanceSquared:Float = Math.pow(circleTwoWorldPosition.x - circleOneWorldPosition.x, 2) + Math.pow(circleTwoWorldPosition.y - circleOneWorldPosition.y, 2);
		var radiusesSquared:Float = (circleOne.radius + circleTwo.radius)*(circleOne.radius + circleTwo.radius);
		if (distanceSquared >= radiusesSquared)
		{
			return null;
		}
		var result:CollisionResult = new CollisionResult();
		result.collision = true;
		result.mtdAmount = Math.sqrt(radiusesSquared) - Math.sqrt(distanceSquared);
		result.mtdAxis = circleOneWorldPosition.clone().subtract(circleTwoWorldPosition).normalize();
		return result;
	}
	
	private function projectVerticeSetOnAxis(verticeSet:Array<Vector2D>, axis:Vector2D):ProjectionResult
	{
		verticeNum = verticeSet.length;
		min = Vector2D.dotProduct(verticeSet[0], axis);
		max = Vector2D.dotProduct(verticeSet[0], axis);
		for (i in 1...verticeNum) 
		{
			projectionPoint = Vector2D.dotProduct(verticeSet[i], axis);
			if (projectionPoint < min) 
			{
				min = projectionPoint;
			}
			if (projectionPoint > max)
			{
				max = projectionPoint;
			}
		}
		
		projectionResult.min = min;
		projectionResult.max = max;
		
		return projectionResult;
	}
	
	private function projectPolygonOnAxis(polygon:Polygon, axis:Vector2D):ProjectionResult
	{
		var body:PhysicalBody = polygon.body;
		var min:Float = Vector2D.dotProduct(body.localToWorld(polygon.vertices[0]), axis);
		var max:Float = Vector2D.dotProduct(body.localToWorld(polygon.vertices[0]), axis);
		var projectionPoint:Float;
		for (i in 1...polygon.getNumVertices()) 
		{
			projectionPoint = Vector2D.dotProduct(body.localToWorld(polygon.vertices[i]), axis);
			if (projectionPoint < min) 
				min = projectionPoint;
			if (projectionPoint > max)
				max = projectionPoint;
		}
		
		projectionResult.min = min;
		projectionResult.max = max;
		
		return projectionResult;
	}
	
	private function closestPointOnLineSegment(startPoint:Vector2D, segment:Vector2D, point:Vector2D):Vector2D
	{
		var closestPoint:Vector2D;
		
		var testDotProduct:Float = Vector2D.dotProduct(segment, point.clone().subtract(startPoint));
		var segmentLengthSquared:Float = segment.getLengthSquared();
		
		if (testDotProduct <= 0)
		{
			closestPoint = startPoint.clone();
		} else if(testDotProduct >= segmentLengthSquared) {
			closestPoint = startPoint.clone().add(segment);
		} else {
			var segmentPart:Float = testDotProduct / segmentLengthSquared;
			closestPoint = startPoint.clone().add(segment.clone().multiply(segmentPart));
		}
		
		return closestPoint;
	}
	
	private function projectCircleOnAxis(circle:CircleShape, axis:Vector2D):ProjectionResult
	{
		var center:Float = Vector2D.dotProduct(circle.body.localToWorld(circle.position), axis);
		projectionResult.min = center - circle.radius;
		projectionResult.max = center + circle.radius;
		return projectionResult;
	}
	
}