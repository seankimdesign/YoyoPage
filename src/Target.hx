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
import flixel.util.FlxPoint;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author ...	
 */
class Target extends FlxSprite
{
	
	private var _pX:Float;
	private var _pY:Float;
	
	private var _shotLength:Int = 180;
	private var _hangTime:Int = 20; //In Frames
	private var _hangFrame:Int = 0;
	private var _shotSpeed:Int = 200;
	private var _returnSpeed:Int = 350;
	private var _multShoot:Float = 6;
	private var _multReturn:Float = 4;
	private var _catchDist:Float = 25;
	private var _forceTime:Int = 38; //In Frames
	private var _forceFrame:Int = 0;
	
	private var _fatigueTime:Int = 10; //In Frames
	private var _fatigueFrame:Int = 0;
	
	public var atkPower:Int = 10;
	public var atkVariant:Int = 2;
	
	public var beingShot:Bool = false;
	private var _shotState:Int = 0;
	private var _shotAngle:Float;
	private var _shotX:Float;
	private var _shotY:Float;
	private var _hangX:Float;
	private var _hangY:Float;
	
	private var _shootsnd:FlxSound;
	private var _returnsnd:FlxSound;
	
	public var requestErase = false;
	
	
	
	public var cc:Calculate;

	public function new(X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		
		loadGraphic('assets/images/yoyo.png', true, 30, 30);
		setSize(28, 28);
		offset.set(1, 1);
		drag.x = drag.y = _shotSpeed * 10;
		
		cc = new Calculate();
		
		_shootsnd = FlxG.sound.load('assets/sounds/yoyoshoot.wav');
		_returnsnd = FlxG.sound.load('assets/sounds/yoyoreturn.wav');
		
		//FlxG.watch.add(this,"_shotX");
		//FlxG.watch.add(this,"_shotY");
		//FlxG.watch.add(this,"_shotAngle");
		//FlxG.watch.add(this,"_shotState");
		
	}
	
	public function updatePlayerPos(pX:Float, pY:Float)
	{
		_pX = pX;
		_pY = pY;
	}
	
	public function shootYoyo(Ang:Float):Void
	{
		if (_fatigueFrame == 0)
		{
			beingShot = true;
			_shotState = 1;
			_shotX = _pX;
			_shotY = _pY;
			_shotAngle = Ang;
			if (_shotAngle == 0)
			{
				_shotAngle = 1;
			}
			else if (_shotAngle == -90)
			{
				_shotAngle = -89;
			}
			_forceFrame = 0;
			_shootsnd.play();
		}
		
	}
	
	override public function update():Void
	{
		
		placeMe();
		if (_fatigueFrame > 0)
		{
			_fatigueFrame--;
		}
		
		super.update();
		
	}
	
	private function getTotalDist(fromPlayer:Bool = true):Float
	{
		var xDist:Float;
		var yDist:Float;
		var catchAns:Float = 0;
		
		if (fromPlayer)
		{
			xDist = Math.abs(x - _pX);
			yDist = Math.abs(y - _pY);
		}
		else
		{
			xDist = Math.abs(x - _shotX);
			yDist = Math.abs(y - _shotY);
		}
		
		catchAns = (cc.pyth(xDist, yDist));
		
		if (Math.isNaN(catchAns))
		{
			catchAns = 0;
		}
		
		return catchAns;
	}
	
	private function placeMe():Void
	{
		if (beingShot)
		{
			var _dest:FlxPoint;
			var _multFactor:Float;
			
			if (_shotState == 1)
			{
				if (getTotalDist(false) < _shotLength && _forceFrame < _forceTime)
				{
					_multFactor = (_shotLength - getTotalDist(false))/_shotLength;
					_multFactor *= (_multShoot - 1);
					_multFactor ++;
					
					_dest = FlxAngle.getCartesianCoords(_shotSpeed, _shotAngle);
					velocity.x = _dest.x * _multFactor;
					velocity.y = _dest.y * _multFactor;
					
					_forceFrame++;
				}
				else
				{
					_shotState = 2;
					_hangFrame = 1;
					_hangX = x - _shotX;
					_hangY = y - _shotY;
				}
			}
			else if (_shotState == 2)
			{
				if (_hangFrame < _hangTime && FlxG.mouse.pressed)
				{
					x = _shotX + _hangX;
					y = _shotY + _hangY;
					_hangFrame++;
				} else {
					//FlxG.log.add("reached hang time");
					_shotState = 3;
					_returnsnd.play();
				}
			}
			else if (_shotState == 3)
			{
				if (getTotalDist(true) > _catchDist)
				{
					_multFactor = 1-(_shotLength - getTotalDist(true))/_shotLength;
					_multFactor *= (_multReturn - 1);
					_multFactor ++;
					
					var playerPoint:FlxPoint = new FlxPoint(_pX, _pY);
					_dest = FlxAngle.getCartesianCoords(_returnSpeed, FlxAngle.angleBetweenPoint(this,playerPoint,true));
					velocity.x = _dest.x * _multFactor;
					velocity.y = _dest.y * _multFactor;
				}
				else
				{
					_shotState = 0;
					beingShot = false;
					requestErase = true;
					_fatigueFrame = _fatigueTime;
				}
			}
		
		}
		else
		{
			x = _pX-(width/2);
			y = _pY-(height/2);
		}
	}
	
}