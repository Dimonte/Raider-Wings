package view;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import game.GameStage;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class WorldView extends Sprite
{
	private var scoreTextField:TextField;
	public var gameStage:GameStage;

	public function new(gameStage:GameStage) 
	{
		super();
		this.gameStage = gameStage;
	}
	
	public function update():Void
	{
		scoreTextField.text = "Score: " + gameStage.gameWorld.score;
	}
	
	public function createScoreDisplay():Void
	{
		scoreTextField = new TextField();
		scoreTextField.embedFonts = true;
		scoreTextField.y = 14;
		scoreTextField.x = 8;
		scoreTextField.autoSize = TextFieldAutoSize.LEFT;
		scoreTextField.mouseEnabled = false;
		
		var scoreTextFormat:TextFormat = scoreTextField.defaultTextFormat;
		
		scoreTextFormat.font = FontManager.mainFont.fontName;
		scoreTextFormat.size = 16;
		scoreTextFormat.color = 0xFFFFFF;
		scoreTextFormat.bold = true;
		
		scoreTextField.defaultTextFormat = scoreTextFormat;
		
		addChild(scoreTextField);
	}
	
}