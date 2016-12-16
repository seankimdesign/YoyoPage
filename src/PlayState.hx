package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.system.FlxSound;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;
import flixel.addons.display.FlxBackdrop;


/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	private var _gravity:Int = 950;
	private var _camOff:Int = 250;
	
	private var _winningX:Int = 7500;
	
	private var _yoyoLine:FlxSprite;
	
	public var player:Player;
	public var target:Target;
	
	private var _shadow:FlxSprite;
	
	private var _enemies:FlxTypedGroup<Enemy>;
	
	private var _backBackDrop:FlxTypedGroup<FlxSprite>;
	
	private var _foreBackDrop:FlxTypedGroup<FlxSprite>;
	
	private var _bounds:FlxTypedGroup<FlxSprite>;
	
	private var _uiGroup:FlxTypedGroup<FlxSprite>;
	
	private var _healthGroup:FlxTypedGroup<FlxSprite>;
	
	private var _backdrop:FlxSprite;
	
	private var _pipeUp:FlxSprite;
	private var _pipeDown:FlxSprite;
	
	private var _piping:Bool = false;
	private var _piped:Bool = false;
	
	private var _introGate:FlxSprite;

	private var _floor:FlxSprite;
	private var _floorPix:FlxBackdrop;
	
	private var TxtWin:FlxText;
	private var TxtWin2:FlxText;
	
	private var _bushPix:FlxBackdrop;
	
	private var _angler:FlxSprite;
	
	private var _cam:FlxCamera;
	
	private var _paused:Bool = false;

	private var _rumblesnd:FlxSound;
	
	private var _gameWon:Bool = false;
	
	private var _wonFrame:Int = 0;
	
	override public function create():Void
	{
		super.create();
		
		
		_rumblesnd = FlxG.sound.load('assets/sounds/rumble.wav');
		
		_backdrop = new FlxSprite(0, 90);
		_backdrop.loadGraphic('assets/images/sky.png', false, 800, 500);
		_backdrop.scrollFactor.set(0, 0);
		
		add(_backdrop);
		
		_backBackDrop = new FlxTypedGroup();
		
		var backrock1 = new FlxSprite(800, 290);
		backrock1.loadGraphic('assets/images/farrock1.png', false, 250, 244);
		var backrock2 = new FlxSprite(1400, 300);
		backrock2.loadGraphic('assets/images/farrock2.png', false, 345, 223);
		
		_backBackDrop.add(backrock1);
		_backBackDrop.add(backrock2);
		_backBackDrop.forEach(setSFB);
		
		add(_backBackDrop);
		
		
		_bushPix = new FlxBackdrop('assets/images/bushes.png', 0.6, 0, true, false);
		_bushPix.setPosition(0, 440);
		
		add(_bushPix);
		
		
		
		_foreBackDrop = new FlxTypedGroup();
		
		var wall1 = new FlxSprite(120, 60);
		wall1.loadGraphic('assets/images/wall.png', false, 114, 520);
		var wall1back = new FlxSprite(-400, 0);
		wall1back.makeGraphic(520, 600, 0xff252525);
		var spear1 = new FlxBackdrop('assets/images/spear.png', 0.8, 0, true, false);
		spear1.setPosition(0, 260);
		
		var text1 = new FlxText(175, 210, 400, "Use the Arrow Keys or WASD to control. Press UP or SPACE to jump", 18);
		text1.alignment = "center";
		text1.color = 0xffcceedd;
		
		var text2 = new FlxText(740, 210, 300, "CLICK anywhere on the screen with your MOUSE to attack with your Yo-Yo", 18);
		text2.alignment = "center";
		text2.color = 0xffeebbdd;
		
		var text3 = new FlxText(1480, 210, 250, "Break down the lock with your Yo-Yo attack. It may require more than 1 hit to break.", 18);
		text3.alignment = "left";
		text3.color = 0xffaabbff;
		
		
		_foreBackDrop.add(wall1back);
		_foreBackDrop.add(wall1);
		_foreBackDrop.forEach(setSFF);
		
		_foreBackDrop.add(spear1);
		
		_foreBackDrop.add(text1);
		_foreBackDrop.add(text2);
		_foreBackDrop.add(text3);
		
		add(_foreBackDrop);
		
		
		_floorPix = new FlxBackdrop('assets/images/ground.png', 1, 0, true, false);
		_floorPix.setPosition(0, 510);
		
		add(_floorPix);
		
		_bounds = new FlxTypedGroup();
		
		_floor = new FlxSprite(0, 530);
		_floor.makeGraphic(8800, 50, 0x00000000);
		_floor.immovable = true;
		_introGate = new FlxSprite(-670, 60);
		_introGate.loadGraphic('assets/images/introgate.png', false, 656, 540);
		_introGate.immovable = true;
		_pipeUp = new FlxSprite(1400, 80);
		_pipeUp.loadGraphic('assets/images/pipe.png', false, 52, 260);
		_pipeUp.flipY = true;
		_pipeUp.immovable = true;
		_pipeDown = new FlxSprite(1400, 342);
		_pipeDown.loadGraphic('assets/images/pipe.png', false, 52, 260);
		_pipeDown.immovable = true;
		
		_bounds.add(_pipeUp);
		_bounds.add(_pipeDown);
		_bounds.add(_floor);
		_bounds.add(_introGate);
		
		add(_bounds);
		
		_yoyoLine = new FlxSprite(0, 0);
		_yoyoLine.makeGraphic(800, 600, 0x00000000);
		_yoyoLine.immovable = true;
		_yoyoLine.offset.x = -0;
		
		add(_yoyoLine);
		
		_enemies = new FlxTypedGroup();
		
		var lockEne = new Enemy(1380, 320, 0);
		_enemies.add(lockEne);
		add(lockEne.hitTextGroup);
		
		for (i in 0...30)
		{
			var flyEne = new Enemy(i * 120 + 2600, (180+(Math.random()*220)), 1);
			_enemies.add(flyEne);
			add(flyEne.hitTextGroup);
			flyEne.animation.play("idle", true, i % 4);
		}
		
		for (i in 0...30)
		{
			var flyEne = new Enemy((i * 100) + 3200+(Math.random()*75), (260+(Math.random()*180)), 1);
			_enemies.add(flyEne);
			add(flyEne.hitTextGroup);
			flyEne.animation.play("idle", true, i % 4);
		}
		
		var runEne = new Enemy(4300 + (Math.random() * 100), 350, 2);
		runEne.acceleration.y = _gravity;
		_enemies.add(runEne);
		add(runEne.hitTextGroup);
		runEne.animation.play("run", true);
		
		for (i in 0...12)
		{
			var runEne = new Enemy((i * 175) + 5000 + (Math.random() * 225), 350, 2);
			runEne.acceleration.y = _gravity;
			_enemies.add(runEne);
			add(runEne.hitTextGroup);
			runEne.animation.play("run", true, i % 3);
		}
		
		for (i in 0...2)
		{
			var jumpEne = new Enemy((i * 3500)+2000, 300, 3);
			jumpEne.acceleration.y = (_gravity*1.5);
			_enemies.add(jumpEne);
			add(jumpEne.hitTextGroup);
		}
		
		
		for (i in 0...12)
		{
			var flyEne = new Enemy(i * 50 + 5600+(Math.random()*50), (180+(Math.random()*220)), 1);
			_enemies.add(flyEne);
			add(flyEne.hitTextGroup);
			flyEne.animation.play("idle", true, i % 4);
		}
		
		
		
		add(_enemies);
		
		
		
		
		_angler = new FlxSprite(0, 0);
		_angler.loadGraphic("assets/images/angler-45.png", false, 191, 372);
		_angler.offset.y = (_angler.height / 2);
		_angler.setFacingFlip(FlxObject.LEFT, true, false);
		_angler.setFacingFlip(FlxObject.RIGHT, false, false);
		_angler.alpha = 0;
		
		add(_angler);
		
		target = new Target(250, 200);
		
		add(target);
		
		_shadow = new FlxSprite(0, 530);
		_shadow.loadGraphic("assets/images/shadow.png", false, 80, 26);
		_shadow.offset.x = 10;
		
		add(_shadow);
		
		player = new Player(50, 250);
		player.acceleration.y = _gravity;
		player.scrollFactor.set(1, 1);
		
		add(player);
		
		_uiGroup = new FlxTypedGroup();
		
		var uibg = new FlxSprite(0, 0);
		uibg.loadGraphic("assets/images/ui-overlay.png", false, 800, 153);
		uibg.scrollFactor.set(0, 0);
		_uiGroup.add(uibg);
		
		var uiyoyo = new FlxSprite(645, -25);
		uiyoyo.loadGraphic("assets/images/yoyo-plastic.png", false, 160, 160);
		uiyoyo.scrollFactor.set(0, 0);
		_uiGroup.add(uiyoyo);
		
		var uiTxtLife = new FlxText(30, 12, 100, "LIFE", 14);
		uiTxtLife.color = 0xffeebbbb;
		uiTxtLife.scrollFactor.set(0, 0);
		_uiGroup.add(uiTxtLife);
		
		var uiTxtYoyo = new FlxText(410, 12, 180, "EQUIPPED YO-YO", 14);
		uiTxtYoyo.color = 0xffeebbbb;
		uiTxtYoyo.scrollFactor.set(0, 0);
		_uiGroup.add(uiTxtYoyo);
		
		var uiTxtYoyoType = new FlxText(410, 30, 180, "Standard Plastic Yo-Yo", 12);
		uiTxtYoyoType.color = 0xffcc66bb;
		uiTxtYoyoType.scrollFactor.set(0, 0);
		_uiGroup.add(uiTxtYoyoType);
		
		var uiTxtYoyoDmg = new FlxText(410, 48, 180, "DAMAGE : 10 - 12", 11);
		uiTxtYoyoDmg.color = 0xff994433;
		uiTxtYoyoDmg.scrollFactor.set(0, 0);
		_uiGroup.add(uiTxtYoyoDmg);
		
		TxtWin = new FlxText(0, 360, 800, "YOU WIN", 38);
		TxtWin.color = 0xffddddbb;
		TxtWin.alignment = "center";
		TxtWin.scrollFactor.set(0, 0);
		TxtWin.alpha = 0;
		add(TxtWin);
		
		TxtWin2 = new FlxText(0, 450, 800, "sorry the game is so short :P", 15);
		TxtWin2.color = 0xffaaaaaa;
		TxtWin2.alignment = "center";
		TxtWin2.scrollFactor.set(0, 0);
		TxtWin2.alpha = 0;
		add(TxtWin2);
		
		add(_uiGroup);
		
		_healthGroup = new FlxTypedGroup();
		
		updateHP();
		
		add(_healthGroup);
		
		FlxG.sound.playMusic('assets/sounds/yoyo-theme.mp3', 1, true);
		
		_cam = new FlxCamera(0, 0, 800, 600, 1);
		//_cam.follow(player);
		
		//FlxG.watch.addMouse();
		
		FlxG.worldBounds.set(8800, 600);
		FlxG.worldDivisions = 12;
		
		//FlxG.debugger.drawDebug = true;
		FlxG.cameras.add(_cam);
	}
	
	private function setSFF(S:FlxSprite)
	{
		S.scrollFactor.set(0.7, 0);
	}
	private function setSFB(S:FlxSprite)
	{
		S.scrollFactor.set(0.4, 0);
	}
	
	private function getPX():Float {
		if (player.facing == FlxObject.RIGHT)
		{
			return player.x + (player.width / 1.1);
		}
		else
		{
			return player.x;
		}
	}
	
	private function getPY():Float {
		return player.y + (player.height / 5);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		
		if (player.endPlease)
		{
			gotoMenu();
		}
		
		if (FlxG.keys.anyJustPressed(["Z"]))
		{
			gamePause();
		}
		
		target.updatePlayerPos(getPX(), getPY());
		_angler.setPosition(getPX(), getPY());
		_angler.facing = player.facing;
		
		if (_angler.facing == FlxObject.LEFT)
		{
			_angler.offset.x = _angler.width;
		}
		else
		{
			_angler.offset.x = 0;
		}
		if (_angler.alpha > 0)
		{
			_angler.alpha -= 0.01;
		}
		
		if (target.beingShot == true)
		{
			var lineStyle = { color:0x66ffffff, thickness: 1.0 };
			
			FlxSpriteUtil.fill(_yoyoLine, 0x00000000);
			FlxSpriteUtil.drawLine(_yoyoLine, getPX()-player.x+_camOff, getPY(), target.x + (target.width / 2)-player.x+_camOff, target.y + (target.height / 2), lineStyle);
			
			player.shooting = true;
		}
		else
		{
			if (target.requestErase)
			{
				target.requestErase = false;
				FlxSpriteUtil.fill(_yoyoLine, 0x00000000);
			}
			
			if (FlxG.mouse.justPressed && player.shootable == 0)
			{
				
				var smpAngle = Math.round(FlxAngle.angleBetweenPoint(target, FlxG.mouse.getWorldPosition(_cam), true));
				
				if (player.checkForShot(smpAngle))
				{
					
					target.shootYoyo(smpAngle);
				}
				else
				{
					if (_angler.alpha < 0.1)
					{
						_angler.alpha = 0.6;
					}
				}
			}
			
			player.shooting = false;
		}
		
		_shadow.x = player.x;
		if (player.jumpable)
		{
			_shadow.alpha = 1;
		}
		else
		{
			_shadow.alpha = 0.75;
		}
		
		if (_piping)
		{
			if (_pipeUp.y > -360)
			{
				_pipeUp.y -= 4;
				_pipeDown.y += 4;
			}
			else
			{
				_piped = true;
				_piping = false;
			}
		}
		
		_cam.scroll.x = player.x - _camOff;
		_yoyoLine.x = player.x - _camOff;
		
		_enemies.forEachAlive(injectPcoord);
		
		
		if (getPX() >= _winningX)
		{
			if (!_gameWon)
			{
				_gameWon = true;
				gameWin();
			}
		}
		
		if (_gameWon)
		{
			_wonFrame++;
			if (_wonFrame == 120)
			{
				outtaHere();
			}
		}
		
		
		FlxG.collide(player, _bounds, hitGround);
		FlxG.collide(target, _bounds);
		FlxG.collide(_enemies, _bounds);
		FlxG.overlap(target, _enemies, hitEnemy);
		FlxG.overlap(player, _enemies, getHit);
		
		if (!_paused)
		{
			super.update();
		}
		
	}
	
	private function gotoMenu():Void
	{
		FlxG.switchState(new MenuState());
	}
	
	
	private function gameWin() {
		TxtWin.alpha = 1;
		TxtWin2.alpha = 1;
		
	}
	
	private function outtaHere() {
		FlxG.sound.music.fadeOut(7);
		FlxG.cameras.fade(0xff000000, 10, false, gotoMenu);
	}
	
	private function injectPcoord(E:Enemy)
	{
		E.updatePlayerPos(getPX(), getPY());
	}
	
	private function hitGround(P:Player, F:FlxSprite)
	{
		if (P.isTouching(FlxObject.FLOOR))
		{
			player.jumpable = true;
		}
		if (P.isTouching(FlxObject.LEFT))
		{
			player.shootable = 1;
		}
		else if (P.isTouching(FlxObject.RIGHT))
		{
			player.shootable = -1;
		}
	}
	
	private function killThem(F:FlxSprite)
	{
		F.kill();
	}
	
	private function updateHP()
	{
		
		var curHP = player.getHP();
		
		//FlxG.log.add(curHP);
		
		_healthGroup.forEachAlive(killThem);
		
		for (i in 0...5)
		{
			var hpicon = new FlxSprite((50 * i)+30, 30);
			if (i < curHP)
			{
				hpicon.loadGraphic('assets/images/life.png', false, 40, 40);
				//FlxG.log.add(i+" : filled");
			}
			else
			{
				hpicon.loadGraphic('assets/images/life-empty.png', false, 40, 40);
				//FlxG.log.add(i+" : empty");
			}
			hpicon.scrollFactor.set(0, 0);
			_healthGroup.add(hpicon);
			
		}
	}
	
	private function getHit(P:Player, E:Enemy) {
		if (!P.isImmune() && E.living())
		{
			P.isHit(1);
			updateHP();
		}
	}
	
	private function hitEnemy(T:Target, E:Enemy) {
		if (E.getType() == 0 && E.getHP() <= 2) {
			E.delayKill();
			openGate();
		}
		
		if (T.beingShot)
		{
			var at:Float = 0.0;
			var att:Int;
			at = (Math.random() * T.atkVariant) + T.atkPower;
			att = Std.int(Math.round(at));
			E.attackedFor(att);
		}

	}
	
	private function openGate() {
		if (!_piping && !_piped)
		{
			_piping = true;
			FlxG.cameras.shake(0.0025, 1);
			_rumblesnd.play();
		}
	}
	
	
	private function gamePause()
	{
		if (_paused)
		{
			_paused = false;
		}
		else
		{
			_paused = true;
		}
	}
}