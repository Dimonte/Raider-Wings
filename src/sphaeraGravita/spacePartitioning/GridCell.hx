package sphaeraGravita.spacePartitioning;

import dataStructures.DLL;
/**
 * ...
 * @author ...
 */
class GridCell
{
	public var x:Int;
	public var y:Int;
	public var activeObjectList:DLL;
	public var fixedObjectList:DLL;
	public var dirty:Bool;
	
	public function new() 
	{
		activeObjectList = new DLL();
		fixedObjectList = new DLL();
	}
	
}