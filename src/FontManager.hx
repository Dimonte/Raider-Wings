package ;
import flash.text.Font;
import openfl.Assets;
/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class FontManager 
{
	static public var mainFont:Font;
	
	static public function initialize():Void
	{
		mainFont = Assets.getFont("assets/fonts/04B_03.TTF");
	}
	
}