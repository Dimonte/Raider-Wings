package ;

import assets.GraphicsLibrary;
import com.sphaeraobscura.keyboard.KeyKeeper;
import com.sphaeraobscura.keyboard.KeyKeeperEvent;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.Lib;
import flash.ui.Keyboard;
import game.GameEvent;
import game.PlayerController;
import game.ui.GameOverScreen;
import game.GameStage;
import openfl.Assets;

#if flash
import view.PhysicalWorldView;
#else
import view.TilesView;
#end

import view.WorldView;

/**
 * ...
 * @author Dmitriy Barabanschikov
 */

class RaiderWings extends Sprite
{
	
	static public function main() 
	{
		Lib.current.addChild(new RaiderWings());
	}
	
	private var gameStage:GameStage;
	private var worldView:WorldView;
	private var keyKeeper:KeyKeeper;
	private var startButton:Sprite;
	private var mouseDown:Bool;
	private var screenPad:ScreenPad;
	private var gameOverScreen:GameOverScreen;
	
	public function new () {
		
		super ();
		
		if (stage == null )
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		else 
		{
			addedToStageHandler();
		}
	}
	
	private function addedToStageHandler(?e:Event = null):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		initialize ();
		construct ();
	}
	
	private function initialize ():Void {
		
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		GraphicsLibrary.initialize();
		FontManager.initialize();
	}
	
	private function stage_onDeactivate(e:Event):Void 
	{
		removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function stage_onActivate(e:Event):Void 
	{
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}
	
	private function construct ():Void
	{
		keyKeeper = new KeyKeeper(Lib.current.stage);
		gameStage = new GameStage(stage.stageWidth, stage.stageHeight);
		gameStage.initializeStage();
		
		#if flash
		worldView = new PhysicalWorldView(gameStage, stage.stageWidth, stage.stageHeight);
		#else
		worldView = new TilesView(gameStage, stage.stageWidth, stage.stageHeight);
		#end
		addChild(worldView);
		//
		
		#if (android || iphone)
		screenPad = new ScreenPad();
		screenPad.x = stage.stageWidth - ScreenPad.WIDTH - 64;
		screenPad.y = stage.stageHeight- ScreenPad.HEIGHT - 64;
		screenPad.visible = false;
		addChild(screenPad);
		#end
		
		var stats:FPS = new FPS();
		addChild(stats);
		stats.y = 14;
		stats.x = stage.stageWidth - 60;
		
		createStartButton();
		
		gameOverScreen = new GameOverScreen(gameStage.gameWorld, stage.stageWidth, stage.stageHeight);
		addChild(gameOverScreen);
		gameOverScreen.hide();
		gameOverScreen.addEventListener(MouseEvent.CLICK, gameOverScreen_clickHandler);
		
		gameStage.addEventListener(GameEvent.GAME_OVER, gameStage_gameOverHandler);
	}
	
	private function gameOverScreen_clickHandler(e:MouseEvent):Void 
	{
		gameOverScreen.hide();
		gameStage.initializeStage();
		if (contains(gameOverScreen))
		{
			removeChild(gameOverScreen);
		}
	}
	
	private function gameStage_gameOverHandler(e:GameEvent):Void 
	{
		gameOverScreen.show();
		addChild(gameOverScreen);
	}
	
	private function createStartButton() 
	{
		startButton = new Sprite();
		startButton.graphics.beginFill(0, 0.5);
		startButton.graphics.drawRect(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
		startButton.graphics.endFill();
		var buttonBitmap:Bitmap = new Bitmap(Assets.getBitmapData("assets/general/goButton.png"));
		buttonBitmap.x = (Lib.current.stage.stageWidth - buttonBitmap.width) / 2;
		buttonBitmap.y = (Lib.current.stage.stageHeight- buttonBitmap.height) / 2;
		startButton.addChild(buttonBitmap);
		startButton.addEventListener(MouseEvent.CLICK, startButton_clickHandler);
		addChild(startButton);
	}
	
	private function startButton_clickHandler(e:MouseEvent):Void 
	{
		start();
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		removeChild(startButton);
		
		#if (android || iphone)
		screenPad.visible = true;
		#end
	}
	
	private function start():Void
	{
		Lib.current.stage.addEventListener (Event.ACTIVATE, stage_onActivate);
		Lib.current.stage.addEventListener (Event.DEACTIVATE, stage_onDeactivate);
	}
	
	private function enterFrameHandler(e:Event):Void 
	{
		update();

	}
	
	private function update():Void 
	{
		var frameRateCoeff:Float = 1 / Lib.current.stage.frameRate;
		
		var playerController:PlayerController = gameStage.playerController;
		
		
		#if (android || iphone)
		
		screenPad.update(frameRateCoeff);
		playerController.setHorizontalAcceleration(screenPad.xMagnitude);
		playerController.setVerticalAcceleration(screenPad.yMagnitude);
		playerController.shoot();
		
		#else
		
		if (keyKeeper.isDown(Keyboard.DOWN))
		{
			playerController.accelrateDown();
		}
		
		if (keyKeeper.isDown(Keyboard.UP)) 
		{
			playerController.accelrateUp();
		}
		
		if (keyKeeper.isDown(Keyboard.RIGHT))
		{
			playerController.accelerateRight();
		}
		
		if (keyKeeper.isDown(Keyboard.LEFT)) 
		{
			playerController.accelerateLeft();
		}
		
		if (keyKeeper.isDown(Keyboard.SPACE) || mouseDown) 
		{
			playerController.shoot();
		}
		#end
		
		gameStage.update(1 / Lib.current.stage.frameRate);
		if (worldView != null) 
		{
			worldView.update();
		}
	}
	
}