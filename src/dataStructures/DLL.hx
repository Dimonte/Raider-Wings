package dataStructures;


/**
 * ...
 * @author Dimonte
 */
class DLL
{
	public var _head:DLLNode;
	public var _tail:DLLNode;
	
	public function new() 
	{
	}
	
	public function head():DLLNode
	{
		return _head;
	}
	
	public function append(object:Dynamic):DLLNode
	{
		var dllNode:DLLNode = new DLLNode();
		dllNode.val = object;
		if (_head == null) 
		{
			_head = dllNode;
			_tail = dllNode;
		} else {
			_tail.next = dllNode;
			dllNode.previous = _tail;
			_tail = dllNode;
		}
		return dllNode;
	}
	
	public function remove(node:DLLNode):Void
	{
		if (node == _head) {
			_head = _head.next;
		}
		if (node == _tail) {
			_tail = _tail.previous;
		}
		if (node.next != null) 
		{
			node.next.previous = node.previous;
		}
		if (node.previous != null) 
		{
			node.previous.next = node.next;
		}
	}
	
	public function clear():Void
	{
		_tail = null;
		_head = null;
	}
	
	public function getLength():Int
	{
		var length:Int = 0;
		var node:DLLNode = _head;
		while (node != null) 
		{
			length++;
			node = node.next;
		}
		return length;
	}
	
}