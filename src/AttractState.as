package
{
	import flash.display.Graphics;
	
	import org.flixel.*;

	// This is the Attract loop. It started out as a copy of PlayState,
	// then had all its key inputs removed and replaced with just 1P and 2P
	// start functions. All the timer functions were set to sync up with
	// text prompts to teach you how to play the game. Both the moon and
	// fighter are given AI functions instead of being controlled by the
	// player. Once the attract loop is "over", i.e. when the moon dies or
	// all the planets are dead, the Attract loop switches to LeaderState.
	
	public class AttractState extends FlxState
	{
		// All the graphics
		[Embed(source="assets/planet.png")] 					private	var ImgPlanet:Class;
		[Embed(source="assets/sun.png")] 						private	var ImgSun:Class;
		[Embed(source="assets/moon.png")] 						private	var ImgMoon:Class;
		[Embed(source="assets/ceptor.png")] 					private	var ImgCeptor:Class;
		[Embed(source="assets/rebel.png")] 						private	var ImgRebel:Class;
		[Embed(source="assets/fighter.png")] 					private	var ImgFighter:Class;
		
		// All the sounds
		[Embed(source="assets/boom.mp3")] 						private var SndBoom:Class;
		[Embed(source="assets/impact.mp3")] 					private var SndImpact:Class;
		[Embed(source="assets/laser.mp3")] 						private var SndLaser:Class;
		[Embed(source="assets/planet.mp3")] 					private var SndPlanet:Class;
		[Embed(source="assets/power.mp3")] 						private var SndPower:Class;
		[Embed(source="assets/takeoff.mp3")] 					private var SndTakeoff:Class;
		[Embed(source="assets/hit.mp3")] 						private var SndHit:Class;
		[Embed(source="assets/alert.mp3")] 						private var SndAlert:Class;
		[Embed(source="assets/ceptor.mp3")] 					private var SndCeptor:Class;
		[Embed(source="assets/launch.mp3")] 					private var SndLaunch:Class;
		
		// All the player-controlled sprites in normal PlayState. In AttractState, they are controlled
		// by AI routines.
		public var moon:FlxSprite;
		public var ceptor:FlxSprite;
		public var chargeMeter:FlxSprite;
		public var damageMeter:FlxSprite;
		public var TwoIcon:FlxSprite;
		
		// All the computer-controlled sprites
		public var sun:FlxSprite;
		public var planets:FlxGroup;
		public var rebels:FlxGroup;
		public var stars:FlxGroup;
		public var planetsRemaining:int;
		  
		// All the particles.
		public var beam:FlxEmitter;
		public var bullets:FlxEmitter;
		public var thrust:FlxEmitter;
		public var jets:FlxEmitter;
		public var explode:FlxEmitter;
		public var sparks:FlxEmitter;
		
		// All the constants
		private const moonWidth:int = 6;
		private const ceptorWidth:int = 6;
		private const rebelWidth:int = 5;
		private const chargeWidth:int = 10;
		private const sunWidth:int = 40;
		private const planetWidth:int = 10;
		private const chargeDiff:int = (chargeWidth-moonWidth)/2;
		private const chargeColor:int = 0xff0099ff;
		private const laserColor:int = 0xff00ff00;
		private const moonColor:int = 0xCCCCCC;
		private const ceptorColor:int = 0xCCCCCC;
		private const maxPower:int = 100;
		private const ceptorTurn:int = 50;
		private const moonHealth:int = 10;
		private const ceptorHealth:int = 3;
		private const timerInterval:int = 4;
		private const moonBorder:int = 50;
		
		// All the other game variables
		private var helpPhrase:int = -1;
		private var power:int;
		private var damage:int = 0;
		private var recharging:Boolean = false;
		private var StartGame:Boolean = true;
		private var willShoot:Boolean = false;
		
		// All the timers
		private var ShipTimer:FlxTimer;
		private var EndTimer:FlxTimer;
		private var HelpTimer:FlxTimer;
		
		// All the text sprites
		private var TxtStart:FlxText;
		private var TxtEnd:FlxText;
		private var TxtCharge:FlxText;
		private var TxtPrompt:FlxText;
		
		// Unique to AttractState, helpPhrases is an Array that includes all the instructional
		// prompts. The function helpText() cycles through them in sequence.
		
		private const helpPhrases:Array = new Array(
			"Left stick: Fly Moon", "Left button: Moon beam", 
			"Beware of rebels", "2P Button: New Fighter", 
			"Right stick: Fly Fighter", "Right button: Fighter laser", "Moons & fighters are costly", "1P Button: New Moon");

		private function helpText():void {
			if (HelpTimer.finished) {
				helpPhrase++;
				if (helpPhrase >= helpPhrases.length) helpPhrase = 0;
				TxtStart.text = helpPhrases[helpPhrase];
				
				if (helpPhrase % 2 == 1) {
					TxtPrompt.text = "Press     for 1-Player Game";
					TwoIcon.visible = false;
				} else {
					TxtPrompt.text = "Press       for 2-Player Game";
					TwoIcon.visible = true;
				}
				
				HelpTimer.start(timerInterval,1);
				
			}
		}
		
		private function newPlanet():void { // Add one random planet
			var planet:FlxSprite;
			planet = new FlxSprite(FlxG.random()*(FlxG.width-planetWidth)+planetWidth/2,FlxG.random()*FlxG.height-planetWidth+planetWidth/2,ImgPlanet);
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
		
		private function addRebel(timer:FlxTimer):void { // Add one new rebel from an existing planet
			var rebel:FlxSprite;
			var fromPlanet:FlxSprite = planets.getRandom() as FlxSprite;
			
			if ((fromPlanet != moon) && (fromPlanet != sun) && (fromPlanet.alive)) {
				rebel = new FlxSprite(fromPlanet.x+planetWidth/2,fromPlanet.y+planetWidth/2, ImgFighter);
				rebel.color = 0xFFFF0000;
				rebel.maxVelocity.x = 40;
				rebel.maxVelocity.y = 40;
				rebel.acceleration.y = 0;
				rebel.acceleration.x = 0;
				rebel.health = 1;
				rebel.velocity.x = FlxG.random()*20-10;
				rebel.velocity.y = FlxG.random()*20-10;
				
				FlxG.play(SndTakeoff);
				
				rebels.add(rebel);
				ShipTimer.start(FlxG.random()*15/planetsRemaining,1,addRebel);
			} else {
				ShipTimer.start(0.1,1,addRebel);
			}
		}
		
		private function hitPlanet(beamPhoton:FlxParticle, hitPlanet:FlxSprite):void { // Moon beam hits a planet
			if ((hitPlanet != sun) && (hitPlanet != moon)) {
				hitPlanet.health--;
				hitPlanet.color += 0x020000;
				hitPlanet.color -= 0x000204;
				hitPlanet.flicker(0.5);
			}
			if (hitPlanet.health <= 0) {
				explode.x = hitPlanet.x + planetWidth/2;
				explode.y = hitPlanet.y + planetWidth/2;
				explode.start(true,3);
				
				FlxG.pauseSounds();
				FlxG.play(SndPlanet);
				FlxG.resumeSounds();
				
				hitPlanet.kill();
				planetsRemaining--;
			}
		}
		
		private function hitCeptor(hitShip:FlxSprite, hitCeptor:FlxSprite):void { // Rebels hit the fighter
			hitCeptor.health -= 1;
			hitCeptor.color += 0x110000;
			hitCeptor.color -= 0x001111;
			
			sparks.x = hitShip.x + rebelWidth/2;
			sparks.y = hitShip.y + rebelWidth/2;
			sparks.start(true,1);
			
			FlxG.shake(0.005,0.1);
			
			FlxG.play(SndImpact);
			hitShip.kill();
			
			if (hitCeptor.health <= 0) {
				explode.x = hitCeptor.x + ceptorWidth/2;
				explode.y = hitCeptor.y + ceptorWidth/2;
				explode.start(true,10);
				
				FlxG.pauseSounds();
				FlxG.play(SndBoom);
				FlxG.resumeSounds();
				
				hitCeptor.kill();
				
				TxtEnd.text = "NO FIGHTER";
				TxtEnd.visible = true;
				if (EndTimer.paused) {
					
					EndTimer.paused = false;
					EndTimer.start(8);
				}
			}
			damageMeter.x = FlxG.width*(1-damage/maxPower);
		}
		
		
		
		private function hitMoon(hitShip:FlxSprite, hitMoon:FlxSprite):void { // Rebels hit the moon
			hitMoon.health -= 1;
			hitMoon.color += 0x040000;
			hitMoon.color -= 0x000404;
			
			sparks.x = hitShip.x + rebelWidth/2;
			sparks.y = hitShip.y + rebelWidth/2;
			sparks.start(true,1);

			FlxG.shake(0.005,0.1);
				
			FlxG.play(SndImpact);
			hitShip.kill();
			
			power = 0;
			damage += maxPower/moonHealth;
			recharging = true;
			
			if (hitMoon.health <= 0) {
				explode.x = hitMoon.x + moonWidth/2;
				explode.y = hitMoon.y + moonWidth/2;
				explode.start(true,10);
				
				FlxG.pauseSounds();
				FlxG.play(SndBoom);
				FlxG.resumeSounds();
				
				hitMoon.kill();
			}
			damageMeter.x = FlxG.width*(1-damage/maxPower);
		}
		
		
		private function hitRebel(beamPhoton:FlxParticle, hitShip:FlxSprite):void { // Moon beam fits a rebel
			hitShip.health--;
				
			if (hitShip.health <= 0) {
				sparks.x = hitShip.x + rebelWidth/2;
				sparks.y = hitShip.y + rebelWidth/2;
				sparks.start(true,1);
				
				FlxG.play(SndImpact);
				hitShip.kill();
			}
		}
		
		private function ceptorFire():void { // Fighter shoots
			if (ceptor.alive) {
				if (bullets.getFirstAlive() == null) {
					FlxG.play(SndCeptor);
					bullets.x = ceptor.x + ceptorWidth/2;
					bullets.y = ceptor.y + ceptorWidth/2;
					
					var magnitude:Number = FlxU.getDistance(new FlxPoint(0,0),ceptor.velocity)/100;
					
					bullets.setXSpeed(ceptor.velocity.x*4/magnitude, ceptor.velocity.x*4.1/magnitude);
					bullets.setYSpeed(ceptor.velocity.y*4/magnitude, ceptor.velocity.y*4.1/magnitude);
					
					bullets.start(true,0.3);
					bullets.on = true;
				}
			}
		}
		
		
		
		private function moonFire():void { // Moon shoots
			if (moon.alive) {
				beam.x = moon.x + moonWidth/2;
				beam.y = moon.y + moonWidth/2;
				
				var spread:Number = 20/power; // Creates a "shotgun" effect to the beam when power is low
				
				var magnitude:Number = FlxU.getDistance(new FlxPoint(0,0),moon.velocity)/30;
				
				beam.setXSpeed(moon.velocity.x*8/magnitude, moon.velocity.x*(spread+8)/magnitude);
				beam.setYSpeed(moon.velocity.y*8/magnitude, moon.velocity.y*(spread+8)/magnitude);
				
				if ((power > 0) && !recharging) { // Only shoot if the moon beam is not recharging
					power--;
					beam.start(false,1,0.005);
					beam.on = true;
					FlxG.play(SndLaser,0.3);
				} else { // If beam energy hits zero, the moon goes into "recharge" mode and cannot fire until fully charged
					recharging = true;
					chargeMeter.color=0xFFFF0000;
					TxtCharge.visible = true;
					FlxG.play(SndAlert);
					//beam.kill();
					beam.on = false;
				}
			}
		}
		
		private function gravitate(orbiter:FlxSprite):void { // Exert a gravitational pull. Actually Hooke's law, so it's more like a spring.
			if (orbiter != sun) {
				var pull:FlxPoint = new FlxPoint((sun.x + sunWidth/2) - (orbiter.x + orbiter.width/2),(sun.y + sunWidth/2) - (orbiter.y + orbiter.height/2));
				orbiter.acceleration.x = pull.x/2;
				orbiter.acceleration.y = pull.y/2;
			}
			
			if (orbiter.velocity.x > 25) // Objects moving from left-to-right are opaque, objects moving right-to-left are translucent
				orbiter.alpha = 1;
			else
				if (orbiter.velocity.x < -25)
					orbiter.alpha = 0.5;
				else
					orbiter.alpha = 0.75 + orbiter.velocity.x/100;
			
		}
		
		private function fight(rebel:FlxSprite):void { // Rebel AI homes on either the moon or fighter
			var pull:FlxPoint;
			var moonPos:FlxPoint = new FlxPoint(moon.x, moon.y);
			var ceptorPos:FlxPoint = new FlxPoint(ceptor.x,ceptor.y);
			var fighterPos:FlxPoint = new FlxPoint(rebel.x,rebel.y);
			
			if (rebel.alive) {
				if ((FlxU.getDistance(fighterPos,ceptorPos) > FlxU.getDistance(fighterPos,moonPos)) || !ceptor.alive) {
					pull = new FlxPoint((moon.x + moonWidth/2) - (rebel.x + rebel.width/2),(moon.y + moonWidth/2) - (rebel.y + rebel.height/2));	
					moveMoon(((moon.x + moonWidth/2) - (rebel.x + rebel.width/2))/2,  ((moon.y + moonWidth/2) - (rebel.y + rebel.height/2)/2));
					
				} else {	
					pull = new FlxPoint((ceptorPos.x + ceptorWidth/2) - (rebel.x + rebel.width/2),(ceptorPos.y + ceptorWidth/2) - (rebel.y + rebel.height/2));	
					if (FlxU.getDistance(fighterPos,ceptorPos) < 100) ceptorFire();
				}
				
				rebel.acceleration.x = 4*pull.x + FlxG.random()*10-5;
				rebel.acceleration.y = 4*pull.y + FlxG.random()*10-5;
	
				rebel.angle = FlxU.getAngle(new FlxPoint(0,0),rebel.velocity);
			}		
		}
		
		
		private function evade(rebel1:FlxSprite, rebel2:FlxSprite):void { // Push rebels apart so they make a formation
			var pull:FlxPoint = new FlxPoint((rebel1.x + rebel1.width/2) - (rebel2.x + rebel2.width/2),(rebel1.y + rebel1.height/2) - (rebel2.y + rebel2.height/2));	

			rebel1.acceleration.x = -2*pull.x + FlxG.random()*10-5;
			rebel1.acceleration.y = -2*pull.y + FlxG.random()*10-5;
			
			rebel1.angle = FlxU.getAngle(new FlxPoint(0,0),rebel1.velocity);
		}
		
		private function moveMoon(xAccel:Number, yAccel:Number):void { // Push moon in direction desired by Player 1
			if (moon.alive) {
				moon.acceleration.x=xAccel;
				moon.acceleration.y=yAccel;
			
				thrust.x = moon.x + moonWidth/2;
				thrust.y = moon.y + moonWidth/2;
			
				thrust.setXSpeed(-xAccel-25, -xAccel+25);
				thrust.setYSpeed(-yAccel-25, -yAccel+25);
			
				if (!thrust.countLiving()) { // Particle effect
					thrust.on = true;
					thrust.start(true,0.1);
				}
			}
		}
		
		
		private function moveCeptor(xAccel:Number, yAccel:Number):void { // Push fighter in direction desired by Player 2
			if (ceptor.alive) {
				ceptor.acceleration.x=2*xAccel;
				ceptor.acceleration.y=2*yAccel;
				
				jets.x = ceptor.x + ceptorWidth/2;
				jets.y = ceptor.y + ceptorWidth/2;
				
				jets.setXSpeed(-xAccel-25, -xAccel+25);
				jets.setYSpeed(-yAccel-25, -yAccel+25);
				
				if (!jets.countLiving()) { // Particle effect
					jets.on = true;
					jets.start(true,0.1);
				}
			}
		}
		
		override public function create():void { // Create is called at the beginning of AttractState
			FlxG.score = 0;
			FlxG.level = 3;
			FlxG.bgColor = 0xff101010;
			planets = new FlxGroup(1000);
			rebels = new FlxGroup(1000);
			stars = new FlxGroup(50);
			
			planetsRemaining = 20;
			
			for (var i:int = 0; i < 50; i++)
			{
				// Create star
				var star:FlxSprite = new FlxSprite(FlxG.random()*FlxG.width,FlxG.random()*FlxG.height);
				star.makeGraphic(1,1);
				star.alpha = FlxG.random()/2;
				star.velocity.x = -1;
				stars.add(star);
			}			
			add(stars);
			
			// Create sun
			sun = new FlxSprite((FlxG.width - sunWidth)/2 , (FlxG.height - sunWidth)/2, ImgSun);
			sun.health = 1000;
			planets.add(sun);
			
			// Create player 1
			moon = new FlxSprite(FlxG.width/3,FlxG.height*2/3,ImgMoon);
			moon.color = moonColor;
			moon.maxVelocity.x = 40;
			moon.maxVelocity.y = 40;
			moon.acceleration.y = 0;
			moon.acceleration.x = 0;
			moon.velocity.x = 40;
			moon.velocity.y = 0;
			moon.health = moonHealth;
			planets.add(moon);	
			
			
			// Create player 2
			ceptor = new FlxSprite(FlxG.width*2/3,FlxG.height*2/3,ImgCeptor);
			ceptor.color = ceptorColor;
			ceptor.maxVelocity.x = 80;
			ceptor.maxVelocity.y = 80;
			ceptor.acceleration.y = 0;
			ceptor.acceleration.x = 0;
			ceptor.velocity.x = 40;
			ceptor.velocity.y = -50;
			ceptor.health = ceptorHealth;
			
			// Create beam
			beam = new FlxEmitter(moon.x, moon.y, moonWidth);
			beam.maxSize = 250;
			beam.maxRotation = 0;
			
			for (i = 0; i < 250; i++)
			{
				// Create beam sprite
				var photon:FlxParticle = new FlxParticle();
				photon.makeGraphic(1,1,chargeColor);
				photon.exists = false;
				beam.add(photon);
			}			
			beam.on = false;
			add(beam);
			
			// Create bullets for fighter
			bullets = new FlxEmitter(ceptor.x, ceptor.y, ceptorWidth);
			bullets.maxSize = 50;
			bullets.maxRotation = 0;
			
			for (i = 0; i < 50; i++) {
				// Create bullet sprite
				var laser:FlxParticle = new FlxParticle();
				laser.makeGraphic(1,1,laserColor);
				laser.exists = false;
				bullets.add(laser);
			}			
			bullets.on = false;
			add(bullets);
			
			// Create planet explosions
			explode = new FlxEmitter(0, 0, planetWidth);
			explode.maxSize = 50;
			explode.maxRotation = 0;
			for (i = 0; i < 50; i++) {
				// Create explode sprite
				var frag:FlxParticle = new FlxParticle();
				frag.makeGraphic(1,1,0xaaffffff);
				frag.exists = false;
				explode.add(frag);
			}			
			add(explode);
			
			// Rebel explosion
			sparks = new FlxEmitter(0, 0, rebelWidth);
			sparks.maxSize = 15;
			sparks.maxRotation = 0;
			for (i = 0; i < 15; i++)
			{
				// Create explode sprite
				var parts:FlxParticle = new FlxParticle();
				parts.makeGraphic(1,1,0xaaffff00);
				parts.exists = false;
				sparks.add(parts);
			}			
			add(sparks);
			 
			// Create thrust for moon
			thrust = new FlxEmitter(moon.x, moon.y, moonWidth);
			thrust.maxSize = 5;
			thrust.maxRotation = 0;
			for (i = 0; i < 5; i++)
			{
				// Create thrust sprite
				var impulse:FlxParticle = new FlxParticle();
				impulse.makeGraphic(1,1,0xffffff00);
				impulse.exists = false;
				thrust.add(impulse);
			}
			thrust.on = false;
			add(thrust);
			
			
			// Create jets for fighter
			jets = new FlxEmitter(ceptor.x, ceptor.y, ceptorWidth);
			jets.maxSize = 5;
			jets.maxRotation = 0;
			for (i = 0; i < 5; i++)
			{
				// Create thrust sprite
				var exhaust:FlxParticle = new FlxParticle();
				exhaust.makeGraphic(1,1,0xffffff00);
				exhaust.exists = false;
				jets.add(exhaust);
			}
			jets.on = false;
			add(jets);
			
			// Set up universe
			for (i=0; i < planetsRemaining; i++) {
				newPlanet();
			}
			add(planets);
			
			add(ceptor);
			ceptor.kill();
			
			add(rebels);
			
			// Create meters
			chargeMeter = new FlxSprite(0,FlxG.height-chargeWidth);
			chargeMeter.makeGraphic(FlxG.width,chargeWidth,0xFFFFFFFF);
			chargeMeter.color = chargeColor;
			add(chargeMeter);
			
			damageMeter = new FlxSprite(0,FlxG.height-chargeWidth);
			damageMeter.makeGraphic(FlxG.width,chargeWidth,0xFF990000);
			damageMeter.x = FlxG.width;
			damageMeter.y = FlxG.height - chargeWidth;
			add(damageMeter);
			
			
			// Create text sprites
			
			TxtStart = new FlxText(0,50,FlxG.width,"NO MOON");
			TxtStart.alignment = "center";
			TxtStart.size = 16;
			add(TxtStart);
			
			TxtEnd = new FlxText(0,FlxG.height-60,FlxG.width,"NO MOON");
			TxtEnd.alignment = "center";
			TxtEnd.size = 24;
			add(TxtEnd);
			TxtEnd.visible=false;
			
			TxtCharge = new FlxText(0,FlxG.height-11,FlxG.width,"INSUFFICIENT POWER");
			TxtCharge.alignment = "center";
			TxtCharge.size = 8;
			add(TxtCharge);
			
			TxtPrompt = new FlxText(0,FlxG.height-30,FlxG.width,"Press     for 1-Player Game");
			TxtPrompt.alignment = "center";
			TxtPrompt.size = 8;
			add(TxtPrompt);
			
			TwoIcon = new FlxSprite(FlxG.width/2-37,FlxG.height-28,ImgRebel)
			add(TwoIcon);
			TwoIcon.visible = false;
			add(new FlxSprite(FlxG.width/2-32,FlxG.height-28,ImgRebel));
			
			FlxG.play(SndPower);
			
			// Create timers
			ShipTimer = new FlxTimer();
			ShipTimer.start(timerInterval*3+1,1,addRebel);
			
			EndTimer = new FlxTimer();
			EndTimer.start(timerInterval*4+1,1);
			
			HelpTimer = new FlxTimer();
			HelpTimer.start(timerInterval,1);
		}

		
		
		override public function update():void { // The main game loop

			for each (var pl:FlxSprite in planets.members) // Exert gravity on all planets and the moon
				gravitate(pl);
			for each (var ft:FlxSprite in rebels.members) // Rebels home towards moon and fighter
				fight(ft);
			for each (var st:FlxSprite in stars.members) // Move background stars slowly
				if (st.x < 0) st.x = FlxG.width;
				
			gravitate(ceptor); // Exert gravity on fighter
				
			// AI for the fighter, only for AttractState
			moveCeptor((3*(moon.x + moon.width/2) + (sun.x + sun.width/2))/4 - (ceptor.x + ceptorWidth/2), (3*(moon.y + moon.height/2)+(sun.y + sun.height/2))/4 - (ceptor.y + ceptorWidth/2));
			
			// Fighter wraps around the screen
			if ((ceptor.x < 0) && (ceptor.velocity.x < 0)) ceptor.x = FlxG.width;
			if ((ceptor.x > FlxG.width) && (ceptor.velocity.x > 0)) ceptor.x = 0;
			if ((ceptor.y < 0) && (ceptor.velocity.y < 0)) ceptor.y = FlxG.height-chargeWidth;
			if ((ceptor.y > FlxG.height-chargeWidth) && (ceptor.velocity.y > 0)) ceptor.y = 0;
			
			// AI for the moon, only for AttractState
			if (moon.x < moonBorder) moveMoon(moon.maxVelocity.x,0);
			if (moon.x > FlxG.width-moonBorder) moveMoon(-moon.maxVelocity.x,0);
			if (moon.y < moonBorder) moveMoon(0, moon.maxVelocity.y);
			if (moon.y > FlxG.height-chargeWidth-moonBorder) moveMoon(0, -moon.maxVelocity.y);
				
			// Move overlapping rebels into formation
			FlxG.overlap(rebels,rebels,evade);
				
			// Draw the recharge meter
			TxtCharge.visible = false;
			if (recharging) {
				if (power < 1) 
					TxtCharge.visible = true;
				chargeMeter.color = 0xFFFF9900;
			} else
				chargeMeter.color = chargeColor;
			
			chargeMeter.x=FlxG.width*(power/100-1);

			
			
			if(FlxG.keys.ONE) { // Start a 1-player game
				FlxG.score = 0;
				FlxG.level = 3;
				FlxG.switchState(new PlayState());
			}
				
			
			if(FlxG.keys.TWO) { // Start a 2-player game
				FlxG.score = 0;
				FlxG.level = -3;
				FlxG.switchState(new PlayState());
			}
				
			// AI for the moon, only for AttractState
			willShoot = false;
			if (!recharging && (moon.alive) && (planetsRemaining > 0)) {
				for each (var target:FlxSprite in planets.members) {
					var diffAngle: Number = FlxU.abs(FlxU.getAngle(new FlxPoint(0,0),moon.velocity) - FlxU.getAngle(new FlxPoint(moon.x,moon.y),new FlxPoint(target.x,target.y)));
					if ((target != moon) && (target != sun) && ((diffAngle < 10) || diffAngle > 350)) {
						moveMoon(target.velocity.x + moon.acceleration.x, target.velocity.y + moon.acceleration.y);
						willShoot = true;
					}
				}	
			}
			if (willShoot)
				moonFire();
			else {
				beam.on = false;
				if (power < maxPower-damage) 
					power++;
				else 
					recharging = false;
			}
			
			helpText(); // Cycle through all the instructional prompts, only for AttractState
			
			// Hit detection routines
			FlxG.overlap(beam,planets,hitPlanet);
			FlxG.overlap(bullets,rebels,hitRebel);
			
			FlxG.overlap(rebels,moon,hitMoon);
			FlxG.overlap(rebels,ceptor,hitCeptor);
			
			// Opaque planets are drawn on top of translucent planets.
			planets.sort("alpha",ASCENDING);
			
			
			
			if (!moon.alive || (planetsRemaining < 1)) { // All possible reasons for ending the game

				if (!moon.alive) 
					TxtEnd.text = "NO MOON";
				if (planetsRemaining < 1)
					TxtEnd.text = "Sector Clear";
				
				TxtEnd.visible = true;
				
				if (EndTimer.paused) {
					EndTimer.paused = false;
					EndTimer.start(4);
				}
			}
			
			
			if (EndTimer.finished) { // Check if it is time to switch to a new game state or simply launch a new fighter
				
				TxtEnd.visible = false;
				if ((planetsRemaining < 1) || !moon.alive)
					FlxG.switchState(new LeaderState);
				if (!ceptor.alive && moon.alive) {
					ceptor.x = moon.x;
					ceptor.y = moon.y;
					ceptor.velocity.x = -moon.velocity.x/2;
					ceptor.velocity.y = -moon.velocity.y/2;
					ceptor.revive();
					ceptor.health = ceptorHealth;
					ceptor.color = ceptorColor;
					TxtEnd.visible=false;
					FlxG.play(SndLaunch);
				}
				EndTimer.paused = true;
			}
		
			super.update();
			
		}
	}
}
