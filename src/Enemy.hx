package ;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...
 */
class Enemy extends FlxSprite
{
	
	private var _enemyType:Int = 0;
	//0 = lock
	//1 = flyer
	//2 = shooter
	//3 = ninja
	//4 = boss
	
	private var _enemyHealthArray:Array<Int> = [5, 10, 20, 100];
	
	private var _speed:Array<Int> = [0, 190+cast(Math.random()*25), 350, 200];
	private var _alertDist:Array<Int> = [0,400+cast(Math.random()*150), 750,600];
	
	private var _runTime:Int = 200;
	private var _runPrep:Int = 50;
	private var _runFrame:Int = 0;
	private var _runLeft:Bool = true;
	
	private var _maxHp:Int;
	private var _curHP:Int;
	
	private var _pX:Float;
	private var _pY:Float;
	
	private var _semiDead:Bool = false;
	
	public var openGate:Bool = false;
	
	public var hitTextGroup:FlxTypedGroup<FlxText>;
	
	private var _immuneTime:Int = 45; //In Frames
	private var _immuneFrame:Int = 0;
	
	public var gameClear:Bool = false;
	
	private var _bathitsnd:FlxSound;
	private var _runhitsnd:FlxSound;
	private var _bosshitsnd:FlxSound;
	private var _lockhitsnd:FlxSound;
	

	public function new(X:Float = 0, Y:Float = 0, eType:Int = 0)
	{
		super(X, Y);
		
		hitTextGroup = new FlxTypedGroup<FlxText>();
		if (eType == 0)
		{
			loadGraphic('assets/images/locksprite.png', true, 60, 60);
			animation.add("idle", [0, 0, 0, 1], 4, true);
			animation.play("idle");
			setSize(40, 40);
			offset.set(10, 10);
		}
		else if (eType == 1)
		{
			loadGraphic('assets/images/flyer-sprite.png', true, 40, 40);
			animation.add("idle", [0, 1, 2, 3,1,2], 8, true);
			setSize(20, 30);
			offset.set(10, 5);
		}
		else if (eType == 2)
		{
			loadGraphic('assets/images/runner-sprite.png', true, 90, 60);
			animation.add("idle", [1], 1, false);
			animation.add("run", [0,1,2], 12, true);
			setSize(60, 40);
			offset.set(15, 10);
		}
		else if (eType == 3)
		{
			loadGraphic('assets/images/runner-green-sprite.png', true, 180, 120);
			animation.add("idle", [1], 1, false);
			animation.add("jump", [2,3,3,3,3,3,3,3,3,3,3,3,0], 6, false);
			setSize(140, 80);
			offset.set(20, 10);
		}
		
		_enemyType = eType;
		
		_curHP = _maxHp = _enemyHealthArray[eType];
		
		_bathitsnd = FlxG.sound.load('assets/sounds/bathit.wav');
		_runhitsnd = FlxG.sound.load('assets/sounds/runhit.wav');
		_bosshitsnd = FlxG.sound.load('assets/sounds/bosshit.wav');
		_lockhitsnd = FlxG.sound.load('assets/sounds/lockhit.wav');
		
		drag.x = _speed[eType] * 30;
		
	}
	
	public function living():Bool {
		if (!_semiDead)
		{
			return true;
		}
		return false;
	}
	
	public function getType():Int
	{
		return _enemyType;
	}
	
	public function isImmune():Bool
	{
		if (_immuneFrame > 0)
		{
			return true;
		}
		return false;
	}
	
	public function updatePlayerPos(pX:Float, pY:Float)
	{
		_pX = pX;
		_pY = pY;
	}
	
	public function attackedFor(atkAmount:Int)
	{
		if (_immuneFrame == 0 && !_semiDead) {
			_immuneFrame = _immuneTime;
			
			displayHit(atkAmount);
			if (_enemyType == 0)
			{
				atkAmount = 1;
				_lockhitsnd.play();
			}
			else if (_enemyType == 1)
			{
				_bathitsnd.play();
			}
			else if (_enemyType == 2)
			{
				_runhitsnd.play();
			}
			else if (_enemyType == 3)
			{
				_bosshitsnd.play();
			}
			_curHP -= atkAmount;
		}
	}
	
	public function getHP():Int {
		return _curHP;
	}
	
	public function displayHit(dmgAmount:Int)
	{
		
		var textfield = new FlxText(0, 0, 40, "", 11);
		textfield.alignment = "center";
		textfield.color = 0xffdd2233;
		textfield.text = Std.string(dmgAmount);
		textfield.health = 100;
		
		hitTextGroup.add(textfield);
		
	}
	
	public function scanForAttack()
	{
		if ((Math.abs(x - _pX) < _alertDist[_enemyType]))
		{
			if (_enemyType == 1)
			{
				if (_pX > x)
				{
					velocity.x = _speed[_enemyType];
				}
				if (_pX < x)
				{
					velocity.x = -_speed[_enemyType];
				}
				if (_pY < y)
				{
					velocity.y = -_speed[_enemyType]/5;
				}
				if (_pY > y)
				{
					velocity.y = _speed[_enemyType]/5;
				}
			} 
			else if (_enemyType == 2)
			{
				if (_runFrame > _runPrep)
				{
					_runFrame--;
					if (_runLeft)
					{
						velocity.x = -_speed[_enemyType];
					}
					else
					{
						velocity.x = _speed[_enemyType];
					}
				}
				else if (_runFrame > 0)
				{
					animation.play("idle");
					_runFrame--;
					if (_pX > x)
					{
						_runLeft = false;
						flipX = true;
					}
					else
					{
						_runLeft = true;
						flipX = false;
					}
					
				}
				else if (_runFrame <= 0)
				{
					_runFrame = _runTime;
					animation.play("run");
				}
			}
			else if (_enemyType == 3)
			{
				if (_runFrame > _runPrep)
				{
					_runFrame--;
					if (_runLeft)
					{
						velocity.x = -_speed[_enemyType];
					}
					else
					{
						velocity.x = _speed[_enemyType];
					}
					if (_runFrame / _runTime > 0.6) {
						velocity.y = -_speed[_enemyType] * 1.35;
					}
					else if (animation.finished)
					{
						rumble();
						_bosshitsnd.play();
					}
				}
				else if (_runFrame > 0)
				{
					animation.play("idle");
					_runFrame--;
					if (_pX > x)
					{
						_runLeft = false;
						flipX = true;
					}
					else
					{
						_runLeft = true;
						flipX = false;
					}
					
				}
				else if (_runFrame <= 0)
				{
					_runFrame = _runTime;
					animation.play("jump");
				}
			}
		}
	}
	
	function rumble() {
		FlxG.cameras.shake(0.01, 0.05);
	}
	
	override public function update():Void
	{
		
		hitTextGroup.forEachAlive(moveAndFadeText);
		
		if (_curHP <= 0)
		{
			delayKill();
		}
		
		if (alive && !_semiDead)
		{
			if (_enemyType == 1)
			{
				velocity.y = 0;
			}
			if (_immuneFrame > 0)
			{
				alpha = ((_immuneFrame % 2) * .4) + .4;
				_immuneFrame--;
			}
			else
			{
				alpha = 1;
			}
			scanForAttack();
		}
		
		super.update();
		
	}
	
	private function moveAndFadeText(T:FlxText)
	{
		
		T.x = x - 10;
		T.y = (y - 70) + (T.health/2);
		T.alpha = 0.2 + (0.7 * T.health / 100);
		
		T.health--;
		
		if (T.health <= 0)
		{
			T.kill();
			T.destroy();
		}
		
	}
	
	public function delayKill()
	{
		_semiDead = true;
		makeGraphic(40, 40, 0x00000000);
		
		if (hitTextGroup.countLiving() <= 0) {
			hitTextGroup.destroy();
			if (_enemyType == 3)
			{
				gameClear = true;
			}
			kill();
		}
	}
	
	
	
}