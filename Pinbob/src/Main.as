package 
{
	import com.pinbob.AyaScene;
	
	import flash.display.Sprite;
	import flash.filesystem.File;
	
	[SWF(width=640, height=480, backgroundColor=0x808080, frameRate=30)]
	public class Main extends Sprite
	{
		public function Main()
		{
			this.addChild(new AyaScene());
		}
	}
}