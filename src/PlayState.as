package
{
	import flash.display.Graphics;
	
	import org.flixel.*;

	
	public class PlayState extends FlxState
	{
		
		[Embed(source="assets/planet.png")] 					private	var ImgPlanet:Class;
		[Embed(source="assets/sun.png")] 						private	var ImgSun:Class;
		[Embed(source="assets/moon.png")] 						private	var ImgMoon:Class;
		[Embed(source="assets/rebel.png")] 						private	var ImgRebel:Class;
		[Embed(source="assets/fighter.png")] 					private	var ImgFighter:Class;
		
		[Embed(source="assets/boom.mp3")] 						private var SndBoom:Class;
		[Embed(source="assets/impact.mp3")] 					private var SndImpact:Class;
		[Embed(source="assets/laser.mp3")] 						private var SndLaser:Class;
		[Embed(source="assets/planet.mp3")] 					private var SndPlanet:Class;
		[Embed(source="assets/power.mp3")] 						private var SndPower:Class;
		[Embed(source="assets/takeoff.mp3")] 					private var SndTakeoff:Class;
		[Embed(source="assets/hit.mp3")] 						private var SndHit:Class;
		[Embed(source="assets/alert.mp3")] 						private var SndAlert:Class;
		
		public var moon:FlxSprite;
		public var chargeMeter:FlxSprite;
		public var damageMeter:FlxSprite;
		
		public var sun:FlxSprite;
		public var planets:FlxGroup;
		public var fighters:FlxGroup;
		public var stars:FlxGroup;
		public var remaining:int;
		  
		
		
		public var beam:FlxEmitter;
		public var thrust:FlxEmitter;
		public var explode:FlxEmitter;
		public var sparks:FlxEmitter;
		
		private const moonWidth:int = 6;
		private const fighterWidth:int = 5;
		private const chargeWidth:int = 10;
		private const sunWidth:int = 40;
		private const planetWidth:int = 10;
		private const chargeDiff:int = (chargeWidth-moonWidth)/2;
		private const chargeColor:int = 0xff0099ff;
		private const maxPower:int = 100;
		private const startHealth:int = 10;
		
		private var power:int;
		private var damage:int = 0;
		private var Timer:FlxTimer;
		private var recharging:Boolean = false;
		private var StartGame:Boolean = true;
		private var EndGame:Boolean=false;
		
		private var TxtClear:FlxText;
		private var TxtStart:FlxText;
		private var TxtEnd:FlxText;
		private var TxtScore:FlxText;
		private var TxtCharge:FlxText;
		
		private function newPlanet():void
		{
			var planet:FlxSprite;
			planet = new FlxSprite(FlxG.random()*(FlxG.width-planetWidth)+planetWidth/2,FlxG.random()*FlxG.height-planetWidth+planetWidth/2,ImgPlanet);
			//planet.makeGraphic(planetWidth, planetWidth, 0xff00aa99);
			planet.color = 0x00ffaa;
			planet.maxVelocity.x = 60;
			planet.maxVelocity.y = 60;
			planet.acceleration.y = 0;
			planet.acceleration.x = 0;
			planet.health = 100;
			planet.velocity.x = FlxG.random()*20-10;
			planet.velocity.y = FlxG.random()*20-10;
			planets.add(planet);
		}
		
		private function addFighter(timer:FlxTimer):void
		{
			var fighter:FlxSprite;
			var fromPlanet:FlxSprite = planets.getRandom() as FlxSprite;
			
			if ((fromPlanet != moon) && (fromPlanet != sun) && (fromPlanet.alive)) {
				fighter = new FlxSprite(fromPlanet.x+planetWidth/2,fromPlanet.y+planetWidth/2, ImgFighter);
				//fighter.makeGraphic(fighterWidth, fighterWidth, 0xffffffff);
				
				fighter.color = 0xFFFF0000;
				fighter.maxVelocity.x = 40;
				fighter.maxVelocity.y = 40;
				fighter.acceleration.y = 0;
				fighter.acceleration.x = 0;
				fighter.health = 1;
				fighter.velocity.x = FlxG.random()*20-10;
				fighter.velocity.y = FlxG.random()*20-10;
				
				FlxG.play(SndTakeoff);
				
				fighters.add(fighter);
				Timer.start(FlxG.random()*30/remaining,1,addFighter);
			}
			else
			{
				Timer.start(1,1,addFighter);
			}
			TxtStart.visible=false;
		}
		
		private function hitPlanet(beamPhoton:FlxParticle, hitPlanet:FlxSprite):void
		{
			if ((hitPlanet != sun) && (hitPlanet != moon)) {
				hitPlanet.health--;
				hitPlanet.color += 0x00020000;
				hitPlanet.color -= 0x00000204;
				hitPlanet.flicker(0.5);

				FlxG.score -= FlxG.random()*10000;
				
			}
			if (hitPlanet.health <= 0) {
				explode.x = hitPlanet.x + planetWidth/2;
				explode.y = hitPlanet.y + planetWidth/2;
				explode.start(true,3);
				
				FlxG.play(SndPlanet);
				
				hitPlanet.kill();
				remaining--;
				FlxG.score -= 500000+FlxG.random()*300000;
				
				if (remaining < 1) {
					add(TxtClear);
					FlxG.level++;
					EndGame = true;
					Timer.start(5);
				}
			}
			
			TxtScore.text = FlxG.score.toString();
		}
		
		private function hitMoon(hitFighter:FlxSprite, hitMoon:FlxSprite):void
		{
			hitMoon.health -= 1;
			hitMoon.color += 0x00020000;
			hitMoon.color -= 0x00000204;
			
			sparks.x = hitFighter.x + fighterWidth/2;
			sparks.y = hitFighter.y + fighterWidth/2;
			sparks.start(true,1);

			FlxG.shake(0.005,0.1);
				
			FlxG.play(SndImpact);
			hitFighter.kill();
			FlxG.score -= 1;
			
			power = 0;
			damage += maxPower/startHealth;
			recharging = true;
			
			if (hitMoon.health <= 0) {
				explode.x = hitMoon.x + moonWidth/2;
				explode.y = hitMoon.y + moonWidth/2;
				explode.start(true,10);
				
				FlxG.play(SndBoom);
				hitMoon.kill();
				
				add(TxtEnd);
				
				FlxG.level = 3;
				EndGame = true;
				Timer.start(10);
				
			}
			

			damageMeter.x = FlxG.width*(1-damage/maxPower);
			
			TxtScore.text = FlxG.score.toString();
		}
		
		
		private function hitFighter(beamPhoton:FlxParticle, hitFighter:FlxSprite):void
		{
			hitFighter.health--;
				
			if (hitFighter.health <= 0) {
				sparks.x = hitFighter.x + fighterWidth/2;
				sparks.y = hitFighter.y + fighterWidth/2;
				sparks.start(true,1);
				
				FlxG.play(SndHit);
				hitFighter.kill();
				FlxG.score -= 1;
				
			}
			
			TxtScore.text = FlxG.score.toString();
		}
		
		
		private function fire():void
		{
			beam.x = moon.x + moonWidth/2;
			beam.y = moon.y + moonWidth/2;
			
			var spread:Number = 20/power;
			
			var magnitude:Number = FlxU.getDistance(new FlxPoint(0,0),moon.velocity)/30;
			
			beam.setXSpeed(moon.velocity.x*8/magnitude, moon.velocity.x*(spread+8)/magnitude);
			beam.setYSpeed(moon.velocity.y*8/magnitude, moon.velocity.y*(spread+8)/magnitude);
			
			
			
			if ((power > 0) && !recharging) {
				power--;
				beam.start(false,1,0.005);
				beam.on = true;
				FlxG.play(SndLaser,0.3);
			} else {
				recharging = true;
				chargeMeter.color=0xFFFF0000;
				TxtCharge.visible = true;
				FlxG.play(SndAlert);
				//beam.kill();
				beam.on = false;
			}
			
			FlxG.overlap(beam,planets,hitPlanet);
			FlxG.overlap(beam,fighters,hitFighter);
		}
		
		private function gravitate(orbiter:FlxSprite):void
		{
			if (orbiter != sun) {
				var pull:FlxPoint = new FlxPoint((sun.x + sunWidth/2) - (orbiter.x + orbiter.width/2),(sun.y + sunWidth/2) - (orbiter.y + orbiter.height/2));
				orbiter.acceleration.x = pull.x/2;
				orbiter.acceleration.y = pull.y/2;
			}
			
			if (orbiter.velocity.x > 25)
				orbiter.alpha = 1;
			else
				if (orbiter.velocity.x < -25)
					orbiter.alpha = 0.5;
				else
					orbiter.alpha = 0.75 + orbiter.velocity.x/100;
			
		}
		
		private function fight(fighter:FlxSprite):void
		{
			var pull:FlxPoint = new FlxPoint((moon.x + moonWidth/2) - (fighter.x + fighter.width/2),(moon.y + moonWidth/2) - (fighter.y + fighter.height/2));	
			
			//var leader:FlxSprite = fighters.getFirstAlive() as FlxSprite;
			
			//pull.x -= fighter.x - leader.x;
			//pull.y -= fighter.y - leader.y;
				
				
			fighter.acceleration.x = 4*pull.x + FlxG.random()*10-5;
			fighter.acceleration.y = 4*pull.y + FlxG.random()*10-5;

			fighter.angle = FlxU.getAngle(new FlxPoint(0,0),fighter.velocity);
		}
		
		
		private function evade(fighter1:FlxSprite, fighter2:FlxSprite):void
		{
			var pull:FlxPoint = new FlxPoint((fighter1.x + fighter1.width/2) - (fighter2.x + fighter2.width/2),(fighter1.y + fighter1.height/2) - (fighter2.y + fighter2.height/2));	
			
			//var leader:FlxSprite = fighters.getFirstAlive() as FlxSprite;
			
			//pull.x -= fighter.x - leader.x;
			//pull.y -= fighter.y - leader.y;
			
			
			fighter1.acceleration.x = -2*pull.x + FlxG.random()*10-5;
			fighter1.acceleration.y = -2*pull.y + FlxG.random()*10-5;
			
			fighter1.angle = FlxU.getAngle(new FlxPoint(0,0),fighter1.velocity);
		}
		
		private function move(xAccel:Number, yAccel:Number):void
		{
			moon.acceleration.x=xAccel;
			moon.acceleration.y=yAccel;
		
			thrust.x = moon.x + moonWidth/2;
			thrust.y = moon.y + moonWidth/2;
		
			thrust.setXSpeed(-xAccel-25, -xAccel+25);
			thrust.setYSpeed(-yAccel-25, -yAccel+25);
		
			if (!thrust.countLiving()) {
				thrust.on = true;
				thrust.start(true,0.1);
			}
		}
		
		override public function create():void
		{
			FlxG.bgColor = 0xff101010;
			planets = new FlxGroup(10);
			fighters = new FlxGroup(1000);
			stars = new FlxGroup(50);
			
			if (FlxG.level < 3) FlxG.level = 3;
			remaining = FlxG.level;
			
			
			
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
			
			
			
			//Create sun
			sun = new FlxSprite((FlxG.width - sunWidth)/2 , (FlxG.height - sunWidth)/2, ImgSun);
			//sun.makeGraphic(sunWidth,sunWidth,0xffffffaa);
			sun.health = 1000;
			planets.add(sun);
			
			
			//Create player (a gray box)
			moon = new FlxSprite((FlxG.width-moonWidth)/2,0,ImgMoon);
			//moon.makeGraphic(moonWidth,moonWidth,0xffaaaaaa);
			moon.color = 0xAAAAAA;
			moon.maxVelocity.x = 40;
			moon.maxVelocity.y = 40;
			moon.acceleration.y = 0;
			moon.acceleration.x = 0;
			moon.velocity.x = -50;
			moon.health = startHealth;
			planets.add(moon);	
			
			//Create beam
			beam = new FlxEmitter(moon.x, moon.y, moonWidth);
			beam.maxSize = 250;
			beam.maxRotation = 0;
			
			for (i = 0; i < 250; i++)
			{
				//Create beam sprite
				var photon:FlxParticle = new FlxParticle();
				photon.makeGraphic(1,1,chargeColor);
				photon.exists = false;
				beam.add(photon);
			}			
			beam.on = false;
			add(beam);
			
			//Create explosions
			explode = new FlxEmitter(0, 0, planetWidth);
			explode.maxSize = 50;
			explode.maxRotation = 0;
			for (i = 0; i < 50; i++)
			{
				//Create explode sprite
				var frag:FlxParticle = new FlxParticle();
				frag.makeGraphic(1,1,0xaaffffff);
				frag.exists = false;
				explode.add(frag);
			}			
			add(explode);
			
			
			//Ship explosion
			sparks = new FlxEmitter(0, 0, fighterWidth);
			sparks.maxSize = 15;
			sparks.maxRotation = 0;
			for (i = 0; i < 15; i++)
			{
				//Create explode sprite
				var parts:FlxParticle = new FlxParticle();
				parts.makeGraphic(1,1,0xaaffff00);
				parts.exists = false;
				sparks.add(parts);
			}			
			add(sparks);
			 
			//Create thrust
			thrust = new FlxEmitter(moon.x, moon.y, moonWidth);
			thrust.maxSize = 5;
			thrust.maxRotation = 0;
			for (i = 0; i < 5; i++)
			{
				//Create thrust sprite
				var impulse:FlxParticle = new FlxParticle();
				impulse.makeGraphic(1,1,0xffffff00);
				impulse.exists = false;
				thrust.add(impulse);
			}
			thrust.on = false;
			add(thrust);
			
			//Set up universe
			
			for (i=0; i < FlxG.level; i++) {
				newPlanet();
			}
			add(planets);
			
			add(fighters);
			
			
			
			
			
			//Create meters
			
			chargeMeter = new FlxSprite(0,FlxG.height-chargeWidth);
			chargeMeter.makeGraphic(FlxG.width,chargeWidth,0xFFFFFFFF);
			chargeMeter.color = chargeColor;
			add(chargeMeter);
			
			damageMeter = new FlxSprite(0,FlxG.height-chargeWidth);
			damageMeter.makeGraphic(FlxG.width,chargeWidth,0xFF990000);
			damageMeter.x = FlxG.width;
			damageMeter.y = FlxG.height - chargeWidth;
			add(damageMeter);
			
			
			//Create text variables
			
			TxtClear = new FlxText(0,FlxG.height/2-70,FlxG.width,"Sector cleared");
			TxtClear.alignment = "center";
			TxtClear.size = 24;
			
			TxtScore = new FlxText(0,0,FlxG.width-15,FlxG.score.toString());
			TxtScore.size = 8;
			TxtScore.alignment = "right";
			add(TxtScore);
			
			add(new FlxSprite(FlxG.width-15,2,ImgRebel));
			
			TxtStart = new FlxText(0,FlxG.height-60,FlxG.width,"Crush the rebels!");
			TxtStart.alignment = "center";
			TxtStart.size = 24;
			add(TxtStart);
			
			TxtEnd = new FlxText(0,FlxG.height-60,FlxG.width,"NO MOON");
			TxtEnd.alignment = "center";
			TxtEnd.size = 24;
			
			TxtCharge = new FlxText(0,FlxG.height-11,FlxG.width,"INSUFFICIENT POWER");
			TxtCharge.alignment = "center";
			TxtCharge.size = 8;
			add(TxtCharge);
			
			FlxG.play(SndPower);
			
			
			
			// Create timers
			Timer = new FlxTimer();
			Timer.start(3,1,addFighter);
			EndGame = false;			
		}

		
		
		override public function update():void
		{

			for each (var pl:FlxSprite in planets.members)
				gravitate(pl);
			for each (var ft:FlxSprite in fighters.members)
				fight(ft);
			for each (var st:FlxSprite in stars.members)
				if (st.x < 0) st.x = FlxG.width;
				
			FlxG.overlap(fighters,fighters,evade);
				
			TxtCharge.visible = false;
			if (recharging) {
				if (power < 1) 
					TxtCharge.visible = true;
				chargeMeter.color = 0xFFFF9900;
			} else
				chargeMeter.color = chargeColor;
			
			chargeMeter.x=FlxG.width*(power/100-1);

			if(FlxG.keys.LEFT)
				move(-moon.maxVelocity.x, moon.acceleration.y);
			if(FlxG.keys.RIGHT)
				move(moon.maxVelocity.x, moon.acceleration.y);
			if(FlxG.keys.UP)
				move(moon.acceleration.x, -moon.maxVelocity.y);
			if(FlxG.keys.DOWN)
				move(moon.acceleration.x, moon.maxVelocity.y);
			
			
			
			
			
			if(FlxG.keys.SPACE) 
				fire();
			else {
				beam.on = false;
				if (power < maxPower-damage) 
					power++;
				else 
					recharging = false;
				
			}
			
			
			FlxG.overlap(fighters,moon,hitMoon);
			planets.sort("alpha",ASCENDING);
			
			if (EndGame)
				if (Timer.finished)
					FlxG.resetState();
			super.update();
			
		}
	}
}
