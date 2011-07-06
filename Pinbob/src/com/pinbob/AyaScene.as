package com.pinbob
{

	import com.pinbob.PinBobAr;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import flashx.textLayout.elements.BreakElement;

	public class AyaScene extends Sprite
	{
		/* defines game status */
		public static const MAIN_SCENE:int = 0;
		public static const MAIN_MENU:int = 1;
		public static const GAME_STAT:int = 2;
		
		private var currentStatus:int;
		public function AyaScene():void
		{
			var ar:PinBobAr = new PinBobAr();
			ar.addEventListener(PositionEvent.POSITION_CHANGED, onPosition);
			// Single Marker sample Papervision3D
			this.addChild(ar);
			//initMap();
			init();
		}
		
		private var curMap:MovieClip;
		private var sp:Sprite;
		private var info:TextField;
		/* represents aya's logo */
		private var logo:Sprite;
		/* a start button */
		private var button:Sprite;
		/* the game container */
		private var gameContainer:GameContainer;
		
		/**
		 * Initailize the main game interface
		 */ 
		private function init():void {
			this.currentStatus = MAIN_SCENE;
			//TODO two sprites temporarily stands for logo and start button
			logo = new Sprite();
			logo.graphics.beginFill(0x00ff00, .5);
			logo.graphics.drawRoundRect(0, 0, 300, 280, 20, 20);
			logo.graphics.endFill();
			logo.x = 160;
			logo.y = 80;
			this.addChild(logo);
			
			button = new Sprite();
			button.graphics.beginFill(0x00ffff);
			button.graphics.drawCircle(0, 0, 30);
			button.graphics.endFill();
			button.x = 500;
			button.y = 300;
			this.addChild(button);
		}
		
		private function initMap():void {
			//	this.addChild(curMap);
			
			/* set a button temporarily */
			sp = new Sprite();
			sp.x = 400;
			sp.y = 400;
			sp.buttonMode = true;
			sp.graphics.beginFill(0x880000);
			sp.graphics.drawCircle(0,0,10);
			sp.graphics.endFill();
			this.addChild(sp);
			
			/* create a display to show information */
			info = new TextField();
			info.x = 500;
			info.y = 400;
			this.addChild(info);
		}
		
		/**
		 * Initailize the game when user reached GAME_STAT stage.
		 */
		private function initGame():void {
			gameContainer = new GameContainer();
			gameContainer.init('map1.png');
			this.addChild(gameContainer);
			this.currentStatus = AyaScene.GAME_STAT;
		}
		
		/**
		 * Handles the position event when marker is detected.
		 * And it receives stick's end position which projected
		 * on user's view.
		 * @param event the position event dispatched from the marker detection.
		 */
		private function onPosition(event:PositionEvent):void {
			//trace (event.x, event.y); 
			switch(this.currentStatus) {
				case MAIN_SCENE:
					handleMainScene(event.x, event.y);
					break;
				case MAIN_MENU:
					break;
				case GAME_STAT:
					handleGameStat(event.x, event.y);
					break;
			}
		}
		
		/**
		 * when current status is set to MAIN_SCENE
		 * the function handles users' entering to the main scene.
		 * @param x the x coordinate protected to the main surface 
		 * @param y the y coordinate protected to the main surface 
		 */
		private function handleMainScene(x:Number,y:Number):void {
			if(button.hitTestPoint(x,y)) {
				this.removeChild(logo);
				this.removeChild(button);
				logo = null;
				button = null;
				initGame();
			}
		}
		
		/**
		 * when current status is set to GAME STAT
		 * the function handles users' entering to the game.
		 * @param x the x coordinate protected to the main surface 
		 * @param y the y coordinate protected to the main surface 
		 */
		private function handleGameStat(x:Number, y:Number):void {
			gameContainer.moveController(x, y);
		}
	}
}