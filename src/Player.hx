package ;

import flash.display.BitmapData;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...
 */
class Player extends FlxSprite
{
	
	private var _speed:Int = 260;
	private var _jumpPower:Int = 550;
	
	private var _angleRange:Float = 45;
	
	private var _maxHP:Int = 5;
	private var _curHP:Int = 5;
	
	private var _running:Int = 0;
	
	public var shootable:Int = 0;
	
	public var shooting:Bool = false;
	
	public var jumpable:Bool = false;
	public var doubleJumpable:Bool;
	
	private var _immuneTime:Int = 45; //In Frames
	private var _immuneFrame:Int = 0;
	
	private var _jumpsnd:FlxSound;
	private var _hurtsnd:FlxSound;
	
	public var endPlease:Bool = false;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		
		loadGraphic('assets/images/player-sprite.png', true, 80, 160);
		animation.add("idle", [0, 0, 1, 2, 2, 1, 0, 3, 4, 4, 3, 5, 5], 3, true);
		animation.add("run", [6, 7, 8, 9], 7, true);
		animation.add("jumpup", [10, 11, 12, 13, 14, 14], 3, false);
		animation.add("jumpdown", [15,14,13,12,11,10], 3, false);
		animation.play("idle");
		setSize(60, 120);
		offset.set(10, 20);
		facing = FlxObject.RIGHT;
		setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
		
		drag.x = _speed * 30;
		
		
		_jumpsnd = FlxG.sound.load('assets/sounds/levitate.wav');
		_hurtsnd = FlxG.sound.load('assets/sounds/ow.wav');
		

		//FlxG.watch.add(this, "shootable");
		//FlxG.watch.add(this, "x");
		//FlxG.watch.add(this, "_curHP");
		//FlxG.watch.add(this, "_running");
		//FlxG.watch.add(this, "velocity.y");
		
	}
	
	public function getHP():Int
	{
		return _curHP;
	}
	
	public function isHit(dmgForce:Int)
	{
		_immuneFrame = _immuneTime;
		_hurtsnd.play(true);
		_curHP--;
		if (_curHP <= 0)
		{
			endPlease = true;
		}
	}
	
	public function checkForShot(Ang:Float):Bool
	{

			if (Ang >= -_angleRange && Ang < 90)
			{
				facing = FlxObject.RIGHT;
				if (_running == -1)
				{
					FlxG.keys.reset();
				}
				return true;
			}
			else if (Ang >= 91 || Ang < -135)
			{
				facing = FlxObject.LEFT;
				if (_running == 1)
				{
					FlxG.keys.reset();
				}
				return true;
			}
		
		return false;
	}
	
	public function isImmune():Bool
	{
		if (_immuneFrame > 0)
		{
			return true;
		}
		return false;
	}
	
	override public function update():Void
	{
		_running = 0;
		
		if (FlxG.keys.anyPressed(["LEFT", "A"]))
		{
			if (_running != 1)
			{
				if (_running == 0)
				{
					_running = -1;
				}
				if (!shooting)
				{
					facing = FlxObject.LEFT;
				}
				if (jumpable)
				{
					animation.play("run");
				}
				velocity.x = -_speed;
				if (shootable == -1)
				{
					shootable = 0;
				}
			}
		}
			
		if (FlxG.keys.anyPressed(["RIGHT", "D"]))
		{
			
			if (_running != -1)
			{
				if (_running == 0)
				{
					_running = 1;
				}
				if (!shooting)
				{
					facing = FlxObject.RIGHT;
				}
				if (jumpable)
				{
					animation.play("run");
				}
				velocity.x = _speed;
				if (shootable == 1)
				{
					shootable = 0;
				}
			}
		}
		
		if (_running == 0 && jumpable)
		{
			animation.play("idle");
		}
		
		if (FlxG.keys.anyPressed(["SPACE", "UP", "W"]))
		{
			if (jumpable)
			{
				velocity.y = -_jumpPower;
				jumpable = false;
				animation.play("jumpup");
				_jumpsnd.play(true);
			}
		}
		
		if (!jumpable && velocity.y > 0)
		{
			animation.play("jumpdown");
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
		
		super.update();
		
	}
	
}