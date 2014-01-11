package
{
	import org.flixel.*;
	
	[SWF(width="800", height="600", backgroundColor="#000000")]
	 
	public class NoMoon extends FlxGame
	{
		public function NoMoon()
		{
			// StartState is only necessary if playing on a regular desktop browser.
			// It requires the user to click inside the game embed frame to capture
			// keyboard focus. Alternatively, go straight to AttractState if keyboard
			// focus is captured by default (e.g. in Chrome).
			super(400,300,StartState,2); 
			
			//super(400,300,AttractState,2); 
		}
	}
}