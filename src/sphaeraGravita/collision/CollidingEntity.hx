package sphaeraGravita.collision;
import game.CollisionCategory;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class CollidingEntity
{
	public var parent:CollidingEntity;
	
	public var collisionCategory(get, set):Int;
	
	var _collisionCategory:Int = CollisionCategory.INHERIT;
	
	public function get_collisionCategory():Int
	{
		if (_collisionCategory == CollisionCategory.INHERIT)
		{
			if (parent != null)
			{
				return parent.collisionCategory;
			}
		}
		return _collisionCategory;
	}
	
	public function set_collisionCategory(value:Int):Int
	{
		_collisionCategory = value;
		return collisionCategory;
	}
	
	public var collisionMask(get, set):Int;
	
	var _collisionMask:Int;
	
	public function get_collisionMask():Int
	{
		if (_collisionMask == CollisionCategory.INHERIT)
		{
			if (parent != null)
			{
				return parent.collisionMask;
			}
		}
		return _collisionMask;
	}
	
	public function set_collisionMask(value:Int):Int
	{
		_collisionMask = value;
		return collisionMask;
	}
	
}