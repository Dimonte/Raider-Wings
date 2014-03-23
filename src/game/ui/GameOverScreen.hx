package game.ui;

#if (!android && !iphone)

#end
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import game.GameWorld;
import motion.Actuate;
import openfl.Assets;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class GameOverScreen extends Sprite
{
	
	
	private var darkScreen:Bitmap;
	private var gameOverText:Bitmap;
	private var gameWorld:GameWorld;
	private var scoreText:TextField;
	private var restartText:String;
	private var screenWidth:Float;
	private var screenHeight:Float;

	public function new(gameWorld:GameWorld, screenWidth:Float, screenHeight:Float) 
	{
		this.screenWidth = screenWidth;
		this.screenHeight = screenHeight;
		this.gameWorld = gameWorld;
		super();
		
		#if (android || iphone)
		restartText = "Tap anywhere to restart";
		#else
		restartText = "Click anywhere to restart";
		#end
		
		darkScreen = new Bitmap(new BitmapData(1, 1, true, 0xFF000000));
		darkScreen.scaleX = screenWidth;
		darkScreen.scaleY = screenHeight;
		darkScreen.alpha = 0;
		addChild(darkScreen);
		
		gameOverText = new Bitmap(Assets.getBitmapData("assets/ui/gameOverText.png"));
		gameOverText.x = (screenWidth - gameOverText.width) / 2;
		gameOverText.y = Std.int(screenHeight/2 - 100);
		gameOverText.alpha = 0;
		addChild(gameOverText);
		
		scoreText = new TextField();
		scoreText.alpha = 0;
		scoreText.embedFonts = true;
		scoreText.selectable = false;
		scoreText.width = screenWidth;
		scoreText.y = gameOverText.y + 60;
		addChild(scoreText);
		
		var scoreTF:TextFormat = scoreText.defaultTextFormat;
		scoreTF.font = FontManager.mainFont.fontName;
		scoreTF.bold = true;
		scoreTF.size = 24;
		scoreTF.align = TextFormatAlign.CENTER;
		scoreTF.color = 0xFFFFFF;
		scoreText.defaultTextFormat = scoreTF;
		
		
		#if (android || iphone)
		darkScreen.alpha = 0.6;
		gameOverText.alpha = 1;
		scoreText.alpha = 1;
		#end
	}
	
	public function show():Void
	{
		visible = true;
		#if (!android && !iphone)
		Actuate.tween(darkScreen, 8, { alpha: 0.6 } );
		Actuate.tween(gameOverText, 1, { alpha: 1 } );
		Actuate.tween(scoreText, 3, { alpha: 1 } );
		#end
		scoreText.text = "SCORE: " + Std.string(gameWorld.score) + "\n\n" + restartText;
	}
	
	public function hide():Void
	{
		visible = false;
		#if (!android && !iphone)
		Actuate.stop(darkScreen, "alpha", false, false);
		Actuate.stop(gameOverText, "alpha", false, false);
		darkScreen.alpha = 0;
		gameOverText.alpha = 0;
		#end
	}
	
}