package com.pinbob
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
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
		
		public static const STATE_PREPARE:int = 0;
		public static const STATE_IS_READY:int = 1;
		public static const STATE_IN_GAME:int = 2;
		public static const STATE_COMPLETE:int = 4;
		public static const STATE_GAME_OVER:int = 3;
		
		private var currentState:int;
		
		public function GameContainer() {
			super();
		}
		
		/**
		 * intiallize the game container by some game information
		 * @param mapUrl the url of the bitmap image of game
		 */
		public function init(mapUrl:String):void {
			this.currentState = STATE_PREPARE;
			
			var loader:Loader = new Loader();
			var urlRequest:URLRequest = new URLRequest(mapUrl);
			loader.load(urlRequest);
			//			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loaderProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderError);
			function loaderError(error:IOErrorEvent): void {
				trace("file not found: " +  error);
			}
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
			function loaderComplete(event:Event): void {
				trace("load successfully!\n");
				addChild(loader.content as Bitmap);
				mapBmp = loader.content as Bitmap;
				mapData = mapBmp.bitmapData;				
				
				// Start Circle				
				startCircle = new Circle(START_CIRCLE_RADIUS, 0xFF0000);
				startCircleData = new BitmapData(START_CIRCLE_RADIUS * 2,
					START_CIRCLE_RADIUS * 2, true, 0);
				startCircleData.draw(startCircle,
					new Matrix(1, 0, 0, 1, START_CIRCLE_RADIUS, START_CIRCLE_RADIUS));
				startCircleBmp = new Bitmap(startCircleData);
				startCircleBmp.x = 90;
				startCircleBmp.y = 200;
				addChild(startCircleBmp);
				
				// End Circle				
				endCircle = new Circle(END_CIRCLE_RADIUS, 0x00FF00);
				endCircleData = new BitmapData(END_CIRCLE_RADIUS * 2,
					END_CIRCLE_RADIUS * 2, true, 0);
				endCircleData.draw(endCircle,
					new Matrix(1, 0, 0, 1, END_CIRCLE_RADIUS, END_CIRCLE_RADIUS));
				endCircleBmp = new Bitmap(endCircleData);
				endCircleBmp.x = 470;
				endCircleBmp.y = 200;
				
				// This is a star that goes with the mouse
				star = new MyStar(STAR_RADIUS);
				starData = new BitmapData(STAR_RADIUS * 2, STAR_RADIUS * 2, true, 0);
				starData.draw(star, new Matrix(1, 0, 0, 1, STAR_RADIUS, STAR_RADIUS));
				starBmp = new Bitmap(starData);
				addChild(starBmp);
				
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
			
			if (currentState == STATE_PREPARE){//0: before hit start circle
				if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
					new Point(startCircleBmp.x, startCircleBmp.y), 255)){
					starBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [new GlowFilter()];
					endCircleBmp.filters = [];
					mapBmp.filters = [];
					removeChild(startCircleBmp);
					addChild(endCircleBmp);
					currentState = STATE_IS_READY;
					trace("Game Start!");
				}
			}else if (currentState == STATE_IS_READY){//1: after hit start circle, before leave
				if(!starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
					new Point(startCircleBmp.x, startCircleBmp.y), 255)){					
					endCircleBmp.filters = [];				
					startCircleBmp.filters = [];
					starBmp.filters = [];
					mapBmp.filters = [];
					currentState = STATE_IN_GAME;
				}
			}else if (currentState == STATE_IN_GAME){//2: leave start circle
				//-------Hit the map-----------
				if(mapData.hitTest(new Point(mapBmp.x, mapBmp.y), 255, starData,
					new Point(starBmp.x, starBmp.y), 255)) {
					mapBmp.filters = [new GlowFilter()];
					starBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [];
					endCircleBmp.filters = [];
					currentState = STATE_GAME_OVER;
					trace("Game Over! You lose!");
				}
				
				//---------Hit the end circle
				if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, endCircleData,
					new Point(endCircleBmp.x, endCircleBmp.y), 255)){
					starBmp.filters = [new GlowFilter()];
					endCircleBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [];
					mapBmp.filters = [];
					currentState = STATE_COMPLETE;
					trace("Game Over! You win!");
				}
			}
		}
	}
}