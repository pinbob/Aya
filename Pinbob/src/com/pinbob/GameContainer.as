package com.pinbob
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	public class GameContainer extends Sprite
	{
		
		/* map's bitmap */
		private var mapBmp:Bitmap;
		/* map's bitmap data */
		private var mapData:BitmapData;
		
		private var star:MyStar;
		private var starData:BitmapData;
		private var starBmp:Bitmap;
		private const STAR_RADIUS:int = 15;
		
		private var startCircle:Circle;
		private var startCircleData:BitmapData;
		private var startCircleBmp:Bitmap;
		private const START_CIRCLE_RADIUS:int = 40;
		
		private var endCircle:Circle;
		private var endCircleData:BitmapData;
		private var endCircleBmp:Bitmap;
		private const END_CIRCLE_RADIUS:int = 40;
		private var currentLevel:int = 0;
		
		public static const STATE_PREPARE:int = 0;
		public static const STATE_IS_READY:int = 1;
		public static const STATE_IN_GAME:int = 2;
		public static const STATE_GAME_OVER:int = 3;
		public static const STATE_COMPLETE:int = 4;
		public static const STATE_FINAL:int = 5;
		public static const STAGE_WIDTH:Number = 640;
		public static const STAGE_HEIGHT:Number = 480;
		
		public static const REDUCE_TIME = 10;
		public var isReducing:Boolean = false;
		private var lastHit = false;
		
		private var gameInfo:GameInfo = new GameInfo();
		
		private var currentState:int;
		private var stCircleColor:uint = 0xff0000;
		private var edCircleColor:uint = 0x00ff00;
		
		/* text fields */
		private var scoreBoard:TextField;
		private var timeBoard:TextField;
		private var levelBoard:TextField;
		private var currentScore:int = 0;
		private var secondRemain:int = 0;
		
		private var timer:Timer;
		
		public function GameContainer() {
			super();
		}
		
		/**
		 * intiallize the game container by some game information
		 * @param mapUrl the url of the bitmap image of game
		 */
		public function init():void {
			this.currentState = STATE_PREPARE;
			initResources();
			this.initLevel(this.currentLevel);
			
		}
		
		/**
		 * Initialize all resources
		 */
		private function initResources():void {
			/* the start circle */
			startCircle = new Circle(START_CIRCLE_RADIUS, this.stCircleColor);
			startCircleData = new BitmapData(START_CIRCLE_RADIUS * 2,
				START_CIRCLE_RADIUS * 2, true, 0);
			startCircleData.draw(startCircle,
				new Matrix(1, 0, 0, 1, START_CIRCLE_RADIUS, START_CIRCLE_RADIUS));
			startCircleBmp = new Bitmap(startCircleData);
			startCircleBmp.visible = false;
			addChild(startCircleBmp);
			
			/* the end circle */				
			endCircle = new Circle(END_CIRCLE_RADIUS, this.edCircleColor);
			/* does not show till showStatistics function calls */
			endCircle.visible = false;
			this.addChild(endCircle);
			endCircleData = new BitmapData(END_CIRCLE_RADIUS * 2,
				END_CIRCLE_RADIUS * 2, true, 0);
			endCircleData.draw(endCircle,
				new Matrix(1, 0, 0, 1, END_CIRCLE_RADIUS, END_CIRCLE_RADIUS));
			endCircleBmp = new Bitmap(endCircleData);
			endCircleBmp.visible = false;
			addChild(endCircleBmp);
			
			// This is a star that goes with the mouse
			star = new MyStar(STAR_RADIUS);
			starData = new BitmapData(STAR_RADIUS * 2, STAR_RADIUS * 2, true, 0);
			starData.draw(star, new Matrix(1, 0, 0, 1, STAR_RADIUS, STAR_RADIUS));
			starBmp = new Bitmap(starData);
			starBmp.visible = false;
			addChild(starBmp);
			
			/* score board to show */
			this.scoreBoard = new TextField();
			
			var scoreBoardTf:TextFormat = new TextFormat();
			scoreBoardTf.size = 39;
			scoreBoardTf.color = 0xf78000; // something like orange
			this.scoreBoard.autoSize = TextFieldAutoSize.LEFT; 

			scoreBoard.x = 500;
			this.addChild(this.scoreBoard);
			this.scoreBoard.defaultTextFormat = scoreBoardTf;
			scoreBoard.text = "Score: " + currentScore;
			/* timer board to show */
			this.timeBoard = new TextField();
			this.timeBoard.x = 500;
			this.timeBoard.y = 40;
			this.timeBoard.autoSize = TextFieldAutoSize.LEFT; 
			
			this.addChild(this.timeBoard);
			var tfTimer:TextFormat = new TextFormat();
			tfTimer.color = 0xffff00;
			tfTimer.size = 39;
			this.timeBoard.defaultTextFormat = tfTimer;
			
			/* set the timer */
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onComplete);
		}
		
		private function onTimer(event:TimerEvent):void {
			this.timeBoard.text = (this.secondRemain - timer.currentCount) + ' sec';
			this.isReducing = false;
			if (this.secondRemain - timer.currentCount <= 0){
				resetAll();
				this.currentState = GameContainer.STATE_GAME_OVER;
				this.timer.stop();
			}
		}
		
		private function onComplete(event:TimerEvent):void {
			this.currentState = STATE_GAME_OVER;
		}
		
		/**
		 * initialize a level
		 */ 
		private function initLevel(level:int):void {
			this.currentState = STATE_PREPARE;
			this.setStartCircle(gameInfo.getStartPoint(level));
			this.setEndCircle(gameInfo.getEndPoint(level));
			startCircleBmp.visible = true;
			endCircleBmp.visible = false;
			starBmp.visible = true;
			var loader:Loader = new Loader();
			var urlRequest:URLRequest = new URLRequest(gameInfo.getMapUrl(level));
			loader.load(urlRequest);
			//			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loaderProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderError);
			function loaderError(error:IOErrorEvent): void {
				trace("file not found: " +  error);
			}
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			function loaderComplete(event:Event): void {
				trace("load successfully!\n");
				
				mapBmp = loader.content as Bitmap;
				//addChild(loader.content as Bitmap);
				addChild(mapBmp);
				mapData = mapBmp.bitmapData;				
				timer.repeatCount = secondRemain;	
			}
			this.secondRemain = gameInfo.getTime(level);
			this.timeBoard.text = secondRemain.toString() + ' sec';
		}
		
		/**
		 * reset the position of the start circle.
		 * @param point the array containing coordinate information
		 */
		public function setStartCircle(point:Array):void {
			this.startCircleBmp.x = point[0];
			this.startCircleBmp.y = point[1];
		}
		
		/**
		 * reset the position of the end circle.
		 * @param point the array containing coordinate information
		 */
		public function setEndCircle(point:Array):void {
			this.endCircleBmp.x = point[0];
			this.endCircleBmp.y = point[1];
		}

		private function handlePrepare():void {
			if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
				new Point(startCircleBmp.x, startCircleBmp.y), 255)){
				starBmp.filters = [new GlowFilter()];
				startCircleBmp.filters = [new GlowFilter()];
				endCircleBmp.filters = [];
				mapBmp.filters = [];
				//removeChild(startCircleBmp);
				//addChild(endCircleBmp);
				startCircleBmp.visible = false;
				endCircleBmp.visible = true;
				currentState = STATE_IS_READY;
				trace("Game Start!");
				timer.start();
			}
		}
		
		private function handleIsReady():void {
			if(!starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
				new Point(startCircleBmp.x, startCircleBmp.y), 255)){					
				endCircleBmp.filters = [];				
				startCircleBmp.filters = [];
				starBmp.filters = [];
				mapBmp.filters = [];
				currentState = STATE_IN_GAME;	
			}
		}
		
		private function handleInGame():void {
			//-------Hit the map-----------
			if(mapData !=null && mapData.hitTest(new Point(mapBmp.x, mapBmp.y), 255, starData,
				new Point(starBmp.x, starBmp.y), 255)) {
				if (!lastHit) {
					mapBmp.filters = [new GlowFilter()];
					starBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [];
					endCircleBmp.filters = [];
					//currentState = STATE_GAME_OVER;
					//timer.stop();
					//handleGameOver();
				//	handleComplete();
					handleIllegal();
					lastHit = true;
					//trace("Game Over! You lose!");
				}
			}
			
			//---------Hit the end circle
			else if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, endCircleData,
				new Point(endCircleBmp.x, endCircleBmp.y), 255)){
				starBmp.filters = [new GlowFilter()];
				endCircleBmp.filters = [new GlowFilter()];
				startCircleBmp.filters = [];
				mapBmp.filters = [];
				currentState = STATE_COMPLETE;
				timer.stop();
				handleComplete();
				lastHit = false;
				trace("Game Over! You win!");
			} else {
				lastHit = false;
			}
		}
		
		private function handleComplete():void {
			resetAll();
			showStatistics();
		}
		
		private function handleGameOver():void {
			resetAll();
		}
		
		private function showStatistics():void {
			var tmpArr:Array = gameInfo.getEndPoint(this.currentLevel);
			this.endCircle.x = tmpArr[0];
			this.endCircle.y = tmpArr[1];
			this.endCircle.visible = true;
			TweenLite.to(this.endCircle,1.5,
				{x:(STAGE_WIDTH - START_CIRCLE_RADIUS)/2,
				 y:(STAGE_HEIGHT - END_CIRCLE_RADIUS)/2,
				 scaleX:5,
				 scaleY:5,
				 alpha:0.5});
			nextLevel();
			this.endCircle.visible = false;
		}
		
		/**
		 * This function handles illegal hit by user.
		 */
		private function handleIllegal():void {
		//	showStatistics();
			if (this.secondRemain - REDUCE_TIME > 0 && !this.isReducing){
				this.secondRemain -= 10;
				this.isReducing = true;
			} else if (this.secondRemain <= 0){
//				this.secondRemain <= 0;
				resetAll();
			}
		}
		
		private function resetAll():void {
			this.startCircleBmp.visible = false;
			this.endCircleBmp.visible = false;
			if (mapBmp != null && this.contains(mapBmp)) {
				this.removeChild(mapBmp);
				mapBmp = null;
			}
		}
		
		private function nextLevel():void {
			if (this.currentLevel + 1 < GameInfo.LEVEL_COUNT) {
				this.currentLevel += 1;
				this.initLevel(this.currentLevel);
			} else {
				//TODO grand slam interface
			}
		}
		
		/**
		 * move the point of the star
		 * @param x x-coordinate
		 * @param y y-coordinate
		 */
		public function moveController(x:Number, y:Number):void {
			if (starBmp != null && this.currentState != STATE_GAME_OVER) { //sanity check is necessary
				starBmp.x = x - STAR_RADIUS;
				starBmp.y = y - STAR_RADIUS;
			}
			switch(currentState) {
				case STATE_PREPARE: //before hit start circle
					handlePrepare();
					break;
				case STATE_IS_READY: //after hit start circle, before leave
					handleIsReady();
					break;
				case STATE_IN_GAME: //leave start circle
					handleInGame();
					break;
				default:
					break;
			}
		}
	}
}