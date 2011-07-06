package com.pinbob
{

	import com.pinbob.PinBobAr;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;

	public class MainScene extends Sprite
	{
		public function MainScene():void
		{
			var ar:PinBobAr = new PinBobAr();
			ar.addEventListener(PositionEvent.POSITION_CHANGED, onPosition);
			// Single Marker sample Papervision3D
			this.addChild(ar);
			initMap();
			
		}
		
		private var curMap:MovieClip;
		private var sp:Sprite;
		private var info:TextField;
		
		private function initMap():void {
			//	this.addChild(curMap);
			
			/* set a button temporarily */
			sp = new Sprite();
			sp.x = 400;
			sp.y = 400;
			sp.buttonMode = true;
			sp.graphics.beginFill(0x880000);
			sp.graphics.drawCircle(0,0,20);
			sp.graphics.endFill();
			this.addChild(sp);
			
			/* create a display to show information */
			info = new TextField();
			info.x = 500;
			info.y = 400;
			this.addChild(info);
		}
		
		private function onPosition(event:PositionEvent):void {
			//trace (event.x, event.y);
			sp.x = event.x;
			sp.y = event.y; 
			sp.z = event.z;
		}
	}
}