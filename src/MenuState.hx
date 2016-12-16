package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.effects.FlxSpriteFilter;
import openfl.filters.BitmapFilter;
import openfl.filters.BitmapFilterQuality;
import openfl.filters.BlurFilter;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	
	private var _bg:FlxSprite;
	private var _fore:FlxSprite;
	private var _yoyo:FlxSprite;
	
	private var _mylogo:FlxSprite;
	
	private var _tx0:FlxSprite;
	private var _tx1:FlxSprite;
	private var _tx2:FlxSprite;
	private var _tx3:FlxSprite;
	private var _tx4:FlxSprite;
	
	private var _instText:FlxText;
	
	private var _blurFilt:FlxSpriteFilter;
	
	private var _nFilt:BitmapFilter;
	
	private var _frameLimit:Int = 42;
	private var _frameCount:Int = 0;
	
	private var _moveSpeed:Float = 2.2;
	
	private var _flicker:Int = 30;
	private var _flickered:Int = 0;
	private var _ready:Bool = false;
	private var _title:Bool = false;
	
	private var _altn:Bool = false;
	
	private var _introsnd:FlxSound;
	private var _choosesnd:FlxSound;
	private var _wamsnd:FlxSound;
	
	
	override public function create():Void
	{
		
		gotoPlayActual();
		
		super.create();
		
		_bg = new FlxSprite( 0, -60);
		_bg.loadGraphic('assets/images/title-bg.png', false, 920, 690);
		add(_bg);
		
		_yoyo = new FlxSprite(720, -200);
		_yoyo.loadGraphic('assets/images/title-yoyo.png', false, 550, 502);
		add(_yoyo);
		
		_tx0 = new FlxSprite(0, 0);
		_tx0.loadGraphic('assets/images/text00.png', false, 800, 600);
		_tx0.alpha = 0;
		add(_tx0);
		_tx1 = new FlxSprite(0, 0);
		_tx1.loadGraphic('assets/images/text01.png', false, 800, 600);
		_tx1.alpha = 0;
		add(_tx1);
		_tx2 = new FlxSprite(0, 0);
		_tx2.loadGraphic('assets/images/text02.png', false, 800, 600);
		_tx2.alpha = 0;
		add(_tx2);
		_tx3 = new FlxSprite(0, 0);
		_tx3.loadGraphic('assets/images/text03.png', false, 800, 600);
		_tx3.alpha = 0;
		add(_tx3);
		_tx4 = new FlxSprite(0, 0);
		_tx4.loadGraphic('assets/images/text04.png', false, 800, 600);
		_tx4.alpha = 0;
		add(_tx4);
		
		_mylogo = new FlxSprite(480, 530);
		_mylogo.loadGraphic('assets/images/mylogo.png', false, 299, 56);
		add(_mylogo);
		
		_instText = new FlxText(20, 560, 760, "PRESS SPACE TO CONTINUE", 17);
		_instText.color = 0xdddddd;
		_instText.alignment = "left"; 
		_instText.alpha = 0;
		add(_instText);
		
		_introsnd = FlxG.sound.load('assets/sounds/intro.wav');
		_introsnd.play();
		_choosesnd = FlxG.sound.load('assets/sounds/choose.wav');
		_wamsnd = FlxG.sound.load('assets/sounds/wam.wav');
		
		FlxG.cameras.fade(0xff000000, 2.5, true, showTitle);
		
	}

	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	private function showTitle() {
		_title = true;
	}
	

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		var spaced:Bool = FlxG.keys.anyPressed(["SPACE"]);
		
		if (_title)
		{
			_frameCount++;
			
			if (_frameCount >= _frameLimit) {
				_frameCount = 0;
				
				FlxG.cameras.flash(0x33ffffff, 0.2);
				_wamsnd.play(true);
				
				if (_tx0.alpha == 0)
				{
					_tx0.alpha = 1;
					return;
				}
				if (_tx1.alpha == 0)
				{
					_tx1.alpha = 1;
					return;
				}
				if (_tx2.alpha == 0)
				{
					_tx2.alpha = 1;
					return;
				}
				if (_tx3.alpha == 0)
				{
					_tx3.alpha = 1;
					return;
				}
				if (_tx4.alpha == 0)
				{
					_tx4.alpha = 1;
					_title = false;
					_ready = true;
				}
				
			}
		}
		
		if (_ready)
		{
			_flickered++;
			if (_flickered == _flicker)
			{
				_flickered = 0;
				
				if (_instText.alpha == 0)
				{
					_instText.alpha = 1;
				}
				else
				{
					_instText.alpha = 0;
				}
			}
			if (spaced)
			{
				gotoPlay();
			}
		}
		
		if (_bg.x > -112)
		{
			if (_altn)
			{
				_bg.x -= _moveSpeed;
				_yoyo.x -= (_moveSpeed * 4);
				_yoyo.y += (_moveSpeed);
				_moveSpeed -= 0.02;
				_altn = false;
			}
			else
			{
				_altn = true;
			}
		}
		
		super.update();
		
	}
	
	private function gotoPlay():Void
	{
		FlxG.cameras.flash(0x33ffffff, 0.5);
		FlxG.cameras.fade(0xff000000, 1.5, false, gotoPlayActual, true);
		_choosesnd.play();
	}
	
	private function gotoPlayActual():Void
	{
		FlxG.switchState(new PlayState());
	}
	
}