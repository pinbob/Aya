package com.pinbob{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;

	public class StarTest extends Sprite {
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
		
		private var mapData:BitmapData;
		private var mapBmp:Bitmap;
		
		/* gameStatus:
		 * 0: before hit start circle
		 * 1: after hit start circle, before leave
		 * 2: leave start circle
		 * 3: hit map, before leave -> game over
		 * 4: hit end circle -> next stage
		 */
		private var gameStatus:int;
		
		public function StarTest() {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageWidth = 640;
			stage.stageHeight = 480;
			
			this.gameStatus = 0;
			
			// load external bitmap
			var loader:Loader = new Loader();
			var urlRequest:URLRequest = new URLRequest("map1.png");
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
				
				stage.addEventListener(Event.ENTER_FRAME, onMouseMoving);
			}
		}
		
		private function onMouseMoving(event:Event):void {
			if (gameStatus != 3){//When game over, don't move to see why is game over
				// Move with mouse
				starBmp.x = mouseX - STAR_RADIUS;
				starBmp.y = mouseY - STAR_RADIUS;
			}
			
			// check if hit
			if (gameStatus == 0){//0: before hit start circle
				if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
					new Point(startCircleBmp.x, startCircleBmp.y), 255)){
					starBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [new GlowFilter()];
					endCircleBmp.filters = [];
					mapBmp.filters = [];
					removeChild(startCircleBmp);
					addChild(endCircleBmp);
					gameStatus = 1;
					trace("Game Start!");
				}
			}else if (gameStatus == 1){//1: after hit start circle, before leave
				if(!starData.hitTest(new Point(starBmp.x, starBmp.y), 255, startCircleData,
					new Point(startCircleBmp.x, startCircleBmp.y), 255)){					
					endCircleBmp.filters = [];				
					startCircleBmp.filters = [];
					starBmp.filters = [];
					mapBmp.filters = [];
					gameStatus = 2;
				}
			}else if (gameStatus == 2){//2: leave start circle
				//-------Hit the map-----------
				if(mapData.hitTest(new Point(mapBmp.x, mapBmp.y), 255, starData,
					new Point(starBmp.x, starBmp.y), 255)) {
					mapBmp.filters = [new GlowFilter()];
					starBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [];
					endCircleBmp.filters = [];
					gameStatus = 3;
					trace("Game Over! You lose!");
				}
				
				//---------Hit the end circle
				if(starData.hitTest(new Point(starBmp.x, starBmp.y), 255, endCircleData,
					new Point(endCircleBmp.x, endCircleBmp.y), 255)){
					starBmp.filters = [new GlowFilter()];
					endCircleBmp.filters = [new GlowFilter()];
					startCircleBmp.filters = [];
					mapBmp.filters = [];
					gameStatus = 4;
					trace("Game Over! You win!");
				}
			}
		}
	}
}