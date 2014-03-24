package dataStructures;
import dataStructures.DLLNode;


/**
 * ...
 * @author Dimonte
 */
class DLL
{
	public var _head:DLLNode;
	public var _tail:DLLNode;
	
	inline static var globalNodeCacheSize:Int = 30000;
	static var nodeCache:List<DLLNode> = new List<DLLNode>();
	
	public function new() 
	{
	}
	
	public function head():DLLNode
	{
		return _head;
	}
	
	public function append(object:Dynamic):DLLNode
	{
		var dllNode:DLLNode = getDLLNode();
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
	
	function getDLLNode():DLLNode
	{
		if (nodeCache.length > 0)
		{
			var node:DLLNode = nodeCache.pop();
			node.val = node.next = node.previous = null;
			return node;
		}
		return new DLLNode();
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
		
		if (nodeCache.length < globalNodeCacheSize)
		{
			reuseNode(node);
		}
	}
	
	function reuseNode(node:DLLNode) 
	{
		nodeCache.push(node);
	}
	
	public function clear():Void
	{
		
		var node:DLLNode = _head;
		var nextNode:DLLNode = node;
		while (nextNode != null)
		{
			node = nextNode;
			nextNode = nextNode.next;
			reuseNode(node);
		}
		
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