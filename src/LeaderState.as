package
{
	import flash.display.Graphics;
	//import flash.utils.*;
	
	import org.flixel.*;
	
	
	public class LeaderState extends FlxState
	{
		
		public var stars:FlxGroup;
		
		private var TxtStart:FlxText;
		private var TxtTitle:FlxText;
		private var TxtScores:FlxText;
		private var TxtNames1:FlxText;
		private var TxtNames2:FlxText;
		private var TxtRanks:FlxText;

		private static var Save:FlxSave;
		private var Timer:FlxTimer;
		
		private const TableTop:int = 50;
		private const TableGap:int = 30;
		private const NameWidth:int = 80;
		private const ScoreWidth:int = 100;
		private const RankWidth:int = 40;
		private const ScoreCount:int = 20;
		
		public var TopScores:Array = new Array(ScoreCount);
		
		
		
		private function sortScores():void
		{
			TopScores.sortOn("0",Array.NUMERIC|Array.DESCENDING);
			while (TopScores.length > ScoreCount)
				TopScores.pop();
		}
		
		private function saveScores():void
		{
			Save.data.TopScores = new Array(ScoreCount);
			for (var line:int = 0; line < ScoreCount; line++) {
				Save.data.TopScores[line] = new Array(3);
				for (var field: int = 0; field < 3; field++)
					Save.data.TopScores[line][field] = TopScores[line][field];
			}
			//Save.data.TopScores = TopScores.slice();
			Save.flush();
		}
		
		
		private function loadScores():void
		{
			for (var line:int = 0; line < ScoreCount; line++) 
				TopScores[line] = Save.data.TopScores[line];
		}
		
		private function resetScores():void
		{
			Save.erase();
			Save.bind("nomoon");
			for (var resetLine:int = 0; resetLine < ScoreCount; resetLine++) {
				TopScores[resetLine] = new Array((1+resetLine)*10000,"TAN","TAN");
			}
			sortScores();
			saveScores();
		}

		private function insertScore(newScore:Number):void
		{
				TopScores.unshift(new Array(newScore,"XXX","XXX"));
	 			sortScores();
				saveScores();
		}
		
		override public function create():void
		{
			
			Save = new FlxSave();
			if (Save.bind("nomoon")) {
				if (Save.data.TopScores == null) 
					resetScores(); // Create new score table
				else 
					loadScores(); // Retrieve saved scores
				insertScore(-FlxG.score);
			}
			
			FlxG.bgColor = 0xff101010;
			stars = new FlxGroup(50);
			
			for (var i:int = 0; i < 50; i++)
			{
				//Create star
				var star:FlxSprite = new FlxSprite(FlxG.random()*FlxG.width,FlxG.random()*FlxG.height);
				star.makeGraphic(1,1);
				star.alpha = FlxG.random()/2;
				star.velocity.x = -1;
				stars.add(star);
			}			
			add(stars);
			
			
			
			
			//Create text variables
			
			
			TxtTitle = new FlxText(0,10,FlxG.width,"IMPERIAL COMMENDATIONS");
			TxtTitle.alignment = "center";
			TxtTitle.size = 16;
			add(TxtTitle);
			
			TxtRanks = new FlxText(TableGap,TableTop,RankWidth,"");
			TxtRanks.alignment = "right";
			TxtRanks.size = 8;
			add(TxtRanks);
			
			TxtNames1 = new FlxText(RankWidth + TableGap,TableTop,NameWidth,"");
			TxtNames1.alignment = "left";
			TxtNames1.size = 8;
			add(TxtNames1);
			
			TxtNames2 = new FlxText(RankWidth + NameWidth+2*TableGap,TableTop,NameWidth,"");
			TxtNames2.alignment = "left";
			TxtNames2.size = 8;
			add(TxtNames2);
			
			TxtScores = new FlxText(RankWidth + 2*NameWidth+3*TableGap,TableTop,ScoreWidth,"");
			TxtScores.size = 8;
			TxtScores.alignment = "left";
			add(TxtScores);

			
			var lineNumber:int = 1;
			for each (var line:Array in TopScores)
			{
				TxtRanks.text += lineNumber++ + ".\n";
				TxtNames1.text += "ADM " + line[1] + "\n";
				TxtNames2.text += "CPT " + line[2] + "\n";
				TxtScores.text += line[0] + "\n";
			}
			
			
			
			/*
			TxtStart = new FlxText(0,FlxG.height-60,FlxG.width,"Crush the rebels!");
			TxtStart.alignment = "center";
			TxtStart.size = 24;
			add(TxtStart);*/
			
			
			
			//Save.close();
		}

		
		
		override public function update():void
		{
			
			for each (var st:FlxSprite in stars.members) {
				if (st.x < 0) st.x = FlxG.width;
			}
			
			
			if(FlxG.keys.ONE) {
				FlxG.score = 0;
				FlxG.level = 3;
				FlxG.switchState(new PlayState());
			}
			
			
			if(FlxG.keys.BACKSLASH) {
				FlxG.score = 0;
				FlxG.level = 3;
				resetScores();
				FlxG.resetState();
			}
			
			super.update();
			
		}
	}
}
