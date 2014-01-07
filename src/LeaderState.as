package
{
	import flash.display.Graphics;
	
	import flashx.textLayout.utils.CharacterUtil;
	
	import org.flixel.*;
	
	
	public class LeaderState extends FlxState
	{
		
		[Embed(source="assets/arrows.png")] 					private	var ImgArrows:Class;
		[Embed(source="assets/beep.mp3")] 						private var SndBeepy:Class;
		[Embed(source="assets/alert.mp3")] 						private var SndAlert:Class;
		[Embed(source="assets/power.mp3")] 						private var SndPower:Class;
		
		public var stars:FlxGroup;
		
		private var TxtPrompt:FlxText;
		private var TxtTitle:FlxText;
		private var TxtScores:FlxText;
		private var TxtNames1:FlxText;
		private var TxtNames2:FlxText;
		private var TxtName1:FlxText;
		private var TxtName2:FlxText;
		private var TxtRanks:FlxText;
		private var TxtShoot:FlxText;

		private static var Save:FlxSave;
		private var Timer:FlxTimer;
		
		private var NameP1:Array = new Array(45,32,32);
		private var NameP2:Array = new Array(45,32,32);
		
		private var CharP1:int = 0;
		private var CharP2:int = 0;
		private var PosP1:int = 0;
		private var PosP2:int = 0;
		private var editing:Boolean = true;
		
		private const TableTop:int = 50;
		private const TableGap:int = 30;
		private const NameWidth:int = 80;
		private const ScoreWidth:int = 100;
		private const RankWidth:int = 40;
		private const ScoreCount:int = 20;
		private const NameLength:int = 3;
		
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
				TopScores[resetLine] = new Array((1+resetLine)*10000,"MIT","MIT");
			}
			sortScores();
			saveScores();
		}

		private function insertScore(newScore:Number):void
		{
			TopScores.unshift(new Array(newScore,TxtName1.text,TxtName2.text));				
			sortScores();
			saveScores();
			updateTable();
		}
		
		private function enterScore(newScore:Number):void
		{
			if (newScore > TopScores[ScoreCount - 1][0]) {
				editing = true;
			}
			else editing = false;
		}
		
		private function showScores():void {
				TxtScores.visible = !editing;
				TxtNames1.visible = !editing;
				TxtNames2.visible = !editing;
				TxtRanks.visible = !editing;
				TxtPrompt.visible = editing;
				TxtName1.visible = editing;
				TxtName2.visible = editing;
				TxtShoot.visible = editing;
			
		}
		
		private function updateTable():void{
			
			var lineNumber:int = 1;
			TxtRanks.text = "";
			TxtScores.text = "";
			TxtNames1.text = "";
			TxtNames2.text = "";
			for each (var line:Array in TopScores)
			{
				TxtRanks.text += lineNumber++ + ".\n";
				TxtNames1.text += "ADM " + line[1] + "\n";
				TxtNames2.text += "CPT " + line[2] + "\n";
				TxtScores.text += line[0] + "\n";
			}
		}
		
		private function checkLetter(player:int):void{
			if (player == 1){
				if (NameP1[PosP1] == 46)	NameP1[PosP1] = 65;
				if (NameP1[PosP1] > 90)		NameP1[PosP1] = 65;
				if (NameP1[PosP1] < 65) 	NameP1[PosP1] = 90;
			}
			if (player == 2){
				if (NameP2[PosP2] == 46)	NameP2[PosP2] = 65;
				if (NameP2[PosP2] > 90)		NameP2[PosP2] = 65;
				if (NameP2[PosP2] < 65)		NameP2[PosP2] = 90;
			}
		}
		
		override public function create():void
		{
			FlxG.music.fadeOut(5);
			Timer = new FlxTimer();
			Timer.paused = true;
			
			Save = new FlxSave();
			if (Save.bind("nomoon")) {
				if (Save.data.TopScores == null) 
					resetScores(); // Create new score table
				else 
					loadScores(); // Retrieve saved scores
			}
			
			
			enterScore(-FlxG.score);
			
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
			
			
			TxtPrompt = new FlxText(0,FlxG.height/2-40,FlxG.width,"Enter your initials");
			TxtPrompt.alignment = "center";
			TxtPrompt.size = 24;
			add(TxtPrompt);
			
			
			TxtShoot = new FlxText(0,FlxG.height/2+100,FlxG.width,"Press SHOOT together to confirm");
			TxtShoot.alignment = "center";
			TxtShoot.size = 16;
			add(TxtShoot);
			
			TxtName1 = new FlxText(0,FlxG.height/2+30,FlxG.width/2,"");
			TxtName1.alignment = "center";
			TxtName1.size = 32;
			add(TxtName1);
			
			TxtName2 = new FlxText(FlxG.width/2,FlxG.height/2+30,FlxG.width/2,"");
			TxtName2.alignment = "center";
			TxtName2.size = 32;
			add(TxtName2);
			
			
			updateTable();
			
			
			
			
			//Save.close();
		}

		
		
		override public function update():void
		{
			
			for each (var st:FlxSprite in stars.members) 
				if (st.x < 0) st.x = FlxG.width;
			
			
			
			if(editing) {
				if(FlxG.keys.justReleased("W")) // P1 up NUMPADEIGHT
				{
					NameP1[PosP1]++;
					checkLetter(1);
					FlxG.play(SndBeepy);
				}
				if(FlxG.keys.justReleased("S")) // P1 down NUMPADTWO
				{
					NameP1[PosP1]--;
					checkLetter(1);
					FlxG.play(SndBeepy);
				}
				if(FlxG.keys.justReleased("UP")) // P2 up R
				{
					NameP2[PosP2]++;
					checkLetter(2);
					FlxG.play(SndBeepy);
				}
				if(FlxG.keys.justReleased("DOWN")) // P2 down F
				{
					NameP2[PosP2]--;
					checkLetter(2);
					FlxG.play(SndBeepy);
				}
				
				
				
				if(FlxG.keys.justReleased("A")) // P1 left NUMPADFOUR
				{
					if (PosP1 > 0) {
						NameP1[PosP1] = 32;
						PosP1--;
						NameP1[PosP1] = 45;
						FlxG.play(SndBeepy);
					}
					else {
						FlxG.play(SndAlert);
						TxtName1.flicker(0.1);
					}
				}
				if(FlxG.keys.justReleased("D")) // P1 right NUMPADSIX
				{
					if (PosP1 < NameLength-1) {
						PosP1++;
						NameP1[PosP1] = 45;
						FlxG.play(SndBeepy);
					}
					else {
						FlxG.play(SndAlert);
						TxtShoot.flicker(0.1);
					}
				}
				if(FlxG.keys.justReleased("LEFT")) // P2 left D
				{
					if (PosP2 > 0) {
						NameP2[PosP2] = 32;
						PosP2--;
						NameP2[PosP2] = 45;
						FlxG.play(SndBeepy);
					}
					else {
						FlxG.play(SndAlert);
						TxtName2.flicker(0.1);
					}
				}
				if(FlxG.keys.justReleased("RIGHT")) // P2 right G
				{
					if (PosP2 < NameLength-1) {
						PosP2++;
						NameP2[PosP2] = 45;
						FlxG.play(SndBeepy);
					}
					else {
						FlxG.play(SndAlert);
						TxtShoot.flicker(0.1);
					}
				}
				
				
				
				if(FlxG.keys.T && FlxG.keys.P) {
					editing = false;
					insertScore(-FlxG.score);
					FlxG.play(SndPower);
				}
			} else {
				if (Timer.paused) {
					Timer.paused = false;
					Timer.start(10);
				}
				if (Timer.timeLeft < 1)
					FlxG.fade(FlxG.bgColor);
				
				if (Timer.finished) {
					FlxG.score = 0;
					FlxG.level = 3;
					FlxG.switchState(new AttractState());
				}
				if(FlxG.keys.ONE) {
					FlxG.score = 0;
					FlxG.level = 3;
					FlxG.switchState(new PlayState());
				}
			}
			
			TxtName1.text = String.fromCharCode(NameP1[0],NameP1[1],NameP1[2]);
			TxtName2.text = String.fromCharCode(NameP2[0],NameP2[1],NameP2[2]);
			
			if(FlxG.keys.BACKSLASH) {
				FlxG.score = 0;
				FlxG.level = 3;
				resetScores();
				FlxG.resetState();
			}
			
			showScores();
			
			super.update();
			
		}
	}
}
