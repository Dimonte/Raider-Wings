package dataStructures;

/**
 * ...
 * @author Dimonte
 */
class DLLNode
{
	
	public var next:DLLNode;
	public var previous:DLLNode;
	public var val:Dynamic;
	
	public function new() 
	{
		
	}
	
	public function remove():Void
	{
		if (next != null) 
		{
			next.previous = previous;
		}
		if (previous != null)
		{
			previous.next = next;
		}
	}
	
}