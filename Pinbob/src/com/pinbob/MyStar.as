// ActionScript file
package com.pinbob{
	import flash.display.Sprite;
	
	public class MyStar extends Sprite {
		public function MyStar(radius:Number, color:uint = 0xFF00FF):void {
			graphics.lineStyle(0);
			graphics.moveTo(radius, 0);
			graphics.beginFill(color);
			// 绘制十条线
			for(var i:int = 1; i < 11; i++) {
				var radius2:Number = radius;
				if(i % 2 > 0) {
					// 隔一个角度画一条交叉线
					radius2 = radius / 2;
				}
				var angle:Number = Math.PI * 2 / 10 * i;
				graphics.lineTo(Math.cos(angle) * radius2, Math.sin(angle) * radius2);   
			}
		}
	}
}