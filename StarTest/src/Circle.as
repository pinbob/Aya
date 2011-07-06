package
{	
	import flash.display.Sprite;
	
	import flashx.textLayout.formats.Float;
	
	public class Circle extends Sprite
	{
		public function Circle(radius:Number, color:uint = 0x000000, alpha:Number = 1.0):void
		{
			graphics.lineStyle(1, 0x000000);
			graphics.beginFill(color, alpha);			
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		}
	}
}