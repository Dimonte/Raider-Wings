package game;

/**
 * ...
 * @author Dimonte
 */
class CollisionCategory
{
	public static inline var INHERIT:Int = 0x00000000;
	
	public static inline var PLAYER:Int = 0x00000001;
	public static inline var TILE:Int = 0x00000002;
	public static inline var LAND_OBJECT:Int = 0x00000004;
	public static inline var ENEMY:Int = 0x00000008;
	public static inline var PLAYER_BULLET:Int = 0x00000010;
	public static inline var ENEMY_BULLET:Int = 0x00000020;
	public static inline var PARTICLE:Int = 0x00000040;
	static public inline var IGNORE:Int = 0x10000000;
}