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
			
			TxtStart = new FlxText(0,FlxG.height/2-70,FlxG.width,"NO MOON 1.03\n\nROM check ok!\n\nClick to boot");
			TxtStart.alignment = "center";
			TxtStart.size = 16;
			add(TxtStart);
			
			FlxG.flash();
		}

		
		
		override public function update():void
		{

			 
			if (FlxG.mouse.pressed() || FlxG.mouse.justPressed() || FlxG.mouse.justReleased()) {
				FlxG.switchState(new AttractState);
			}
			
			super.update();
			
		}
	}
}
