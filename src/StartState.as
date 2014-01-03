package
{
	import flash.display.Graphics;
	
	import org.flixel.*;

	
	public class StartState extends FlxState
	{
		
		
		private var TxtStart:FlxText;
		
		override public function create():void
		{
			FlxG.bgColor = 0xff101010;
			
			TxtStart = new FlxText(0,FlxG.height/2-10,FlxG.width,"Click to start");
			TxtStart.alignment = "center";
			TxtStart.size = 16;
			add(TxtStart);
			
		}

		
		
		override public function update():void
		{

			 
			if (FlxG.mouse.pressed() || FlxG.mouse.justPressed() || FlxG.mouse.justReleased())
				FlxG.switchState(new AttractState);
			
			super.update();
			
		}
	}
}
