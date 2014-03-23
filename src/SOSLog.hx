package ;  

import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.events.SecurityErrorEvent;

#if flash
import flash.net.XMLSocket;
#end

/**
 * ...
 * @author Dmitriy Barabanschikov
 */
class SOSLog
{
	static public inline var SYSTEM:String = "SYSTEM";
	static public inline var DEBUG:String = "DEBUG";
	static public inline var INFO:String = "INFO";
	static public inline var WARNING:String = "WARNING";
	static public inline var ERROR:String = "ERROR";
	static public inline var FATAL:String = "FATAL";
	static public inline var TRACE:String = "TRACE";
	
	#if flash
	static private var xmlSocket:XMLSocket;
	static private var messageQueue:Array<String>;
	static private var socketConnected:Bool;
	
	static public function connectTracer():Void
	{
		messageQueue = [];
		
		xmlSocket = new XMLSocket();
		xmlSocket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		xmlSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
		xmlSocket.addEventListener(Event.CONNECT, onConnect);
		try
		{
			xmlSocket.connect('localhost', 4442);
		}
		catch (e:Dynamic)
		{
			
		}
	}
	
	static public function disconnectTracer():Void
	{
		if (xmlSocket != null && xmlSocket.connected) 
		{
			xmlSocket.close();
		}
	}
	
	static private function onConnect(e:Event):Void 
	{
		socketConnected = true;
		add("Connected to socket");
		while (messageQueue.length > 0) {
			xmlSocket.send(messageQueue.shift());
		}
	}
	
	static private function onSecurityError(e:SecurityErrorEvent):Void 
	{
		
	}
	
	static private function onIOError(e:IOErrorEvent):Void 
	{
		
	}
	
	static public function add(string:String, type:String = "SYSTEM"):Void
	{
		var splitMessage:Array<String> = string.split("\n");
		
		if (xmlSocket == null) {
			connectTracer();
		}
		
		var message:String = '!SOS<showMessage key="'+type+'"><![CDATA[' + (flash.Lib.getTimer() / 1000) + ':' + string +']]></showMessage>';
		if (socketConnected) 
		{
			try 
			{
				xmlSocket.send(message);
			} 
			catch (e:Dynamic) 
			{
				
			}
		} 
		else 
		{
			messageQueue.push(message);
		}
		
		while (messageQueue.length > 1000) 
		{
			messageQueue.shift();
		}
	}
	
	static public function objectToString(target:Dynamic, ?depth:Int = 0):String
	{
		var tab:String = '	';
		for (i in 0...depth) 
		{
			tab += '	';
		}
		
		var out : String = '';
		
		/*
		var item:Dynamic;
		var dat:Dynamic;
		var objectToDescribe:String;
		var enter:String = '\n';
		for (item in target) 
		{
			dat = target[item];
			if (typeof(dat) == 'object') 
			{
				out += tab+'['+item+']' + enter;
				objectToDescribe = objectToString(dat, depth+1);
				out += (objectToDescribe != '' ? objectToDescribe : tab + '...') + enter;
				out += tab+'[/'+item+']' + enter;
			}
		}
		
		var step:Int = 0;
		for (item in target) {
			dat = target[item];
			if (typeof(dat) != 'object') {
				if (step) { out += enter; }
				out += tab+''+item+' = '+dat;
				step++;
			}
		}
		*/
		return out;
	}
	
	static public function sosTrace(data:String, ?logLevel:String = TRACE):Void
	{
		
		/*
		for (var i:int = 0; i < arguments.length; i++) 
		{
			argument = arguments[i];
			if (argument == null ) 
			{
				string += null;
			} 
			else if (typeof(argument) == 'object') 
			{
				string += '\n';
				string += "[" + getQualifiedClassName(argument) + "]";
				string += '\n' + SOSLog.objectToString(argument) + '\n';
				string += "[/" + getQualifiedClassName(argument) + "]";
			} else 
			{
				string += argument;
				if (i < arguments.length - 1) {
					string += ', ';
				}
			}
		}*/
		SOSLog.add(data, logLevel);
	}
	#else 
	static public function sosTrace(data:String, ?logLevel:String = TRACE):Void
	{
		trace(data);
	}
	#end
}