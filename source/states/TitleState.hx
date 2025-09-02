package states;

import backend.WeekData;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import haxe.Json;
import flixel.text.FlxText;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;

import states.StoryMenuState;
import states.MainMenuState;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
    var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
    var ngSpr:FlxSprite;
    var curWacky:Array<String> = [];
    var wackyImage:FlxSprite;
    var logo:FlxSprite;
    var titleText:FlxText;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
			MobileData.init();
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			controls.isInSubstate = false; //idfk what's wrong
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
			startIntro();
		#end
		
		Paths.image('menus/title/logo');
        Paths.image("menus/title/trollface");
	}

	function startIntro()
	{
		if (!initialized) if (FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

    Conductor.bpm = 102;
    persistentUpdate = true;

    logo = new FlxSprite().loadGraphic(Paths.image("menus/title/logo"));
    logo.antialiasing = ClientPrefs.data.antialiasing;
    logo.updateHitbox();
    logo.screenCenter();
    add(logo);

    titleText = new FlxText(0, 640, 0, '[ PRESS ENTER TO BEGIN ]');
	titleText.setFormat(Paths.font('vcr.ttf'), 36, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
	titleText.borderSize = 2;
	titleText.screenCenter(X);
    titleText.y += 10;
	titleText.updateHitbox();
	add(titleText);

    add(credGroup);

    blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
	credGroup.add(blackScreen);

	ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('menus/title/trollface'));
	ngSpr.visible = false;
	ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
	ngSpr.updateHitbox();
	ngSpr.screenCenter(X);
	ngSpr.antialiasing = ClientPrefs.data.antialiasing;
    add(ngSpr);

	if (initialized)
		skipIntro();
	else
		initialized = true;
	}

    var transitioning:Bool = false;
    var skippedIntro:Bool = false;
    var titleSine:Float = 0;
    public static var closedState:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

    if (logo != null) {
        logo.angle = FlxG.random.float(-1, 1);
        logo.offset.set(FlxG.random.float(-1, 1), FlxG.random.float(-1, 1));
    }

    var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

    var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
	if (gamepad != null) if (gamepad.justPressed.START) pressedEnter = true;

    if (initialized && !transitioning && skippedIntro)
	{
        if (!pressedEnter) {
			titleSine += 180 * elapsed;
			titleText.alpha = 1 - Math.sin((Math.PI * titleSine) / 180);
		} else {
			titleText.alpha = 1;

			FlxTween.tween(logo, {'scale.x': 0, 'scale.y': 0, alpha: 0}, 1.8, {ease: FlxEase.cubeIn});
			FlxTween.tween(titleText, {y: FlxG.height, alpha: 0}, 1, {ease: FlxEase.expoIn});

			FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 0.8);
			FlxG.sound.play(Paths.sound('confirmMenuBell'), 0.7);

			transitioning = true;
			new FlxTimer().start(1.8, function(tmr:FlxTimer)
			{
			    MusicBeatState.switchState(new MainMenuState());
				closedState = true;
			});
		}
    }

    if (initialized && pressedEnter && !skippedIntro) skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
{
	for (i in 0...textArray.length) {
		var money = new Alphabet(0, 0, textArray[i], true);
		money.screenCenter(X);
		money.y += (i * 60) + 200 + offset;
		if(credGroup != null && textGroup != null) {
			credGroup.add(money);
			textGroup.add(money);
		}
	}
}

    function addMoreText(text:String, ?offset:Float = 0)
{
	if (textGroup != null && credGroup != null) {
		var coolText = new Alphabet(0, 0, text, true);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200 + offset;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}
}

function deleteCoolText()
{
	while (textGroup.members.length > 0)
	{
		credGroup.remove(textGroup.members[0], true);
		textGroup.remove(textGroup.members[0], true);
	}
}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	override function beatHit()
	{
		super.beatHit();

	  if (!closedState)
      {
        sickBeats += 1;
        switch (sickBeats)
        {
			case 1:
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxG.sound.music.fadeIn(4, 0, 0.7);

			case 2: createCoolText(['The Troll Team']);

			case 4: 
                addMoreText('presents...');
				ngSpr.visible = true;

			case 5:
				deleteCoolText();
				ngSpr.visible = false;

			case 6: createCoolText([getIntroTextShit()[curWacky][0]]);
			case 8: addMoreText(getIntroTextShit()[curWacky][1]);

			case 9:
                deleteCoolText();
				curWacky = FlxG.random.int(0, getIntroTextShit().length);

			case 10: createCoolText([getIntroTextShit()[curWacky][0]]);
			case 12: addMoreText(getIntroTextShit()[curWacky][1]);
			case 13: deleteCoolText();
			case 14: addMoreText('Let\'s do');
			case 15: addMoreText('a little');
			case 16: addMoreText('trolling');
			case 17: skipIntro();
        }
      }
}

	function skipIntro():Void
   {
	if (!skippedIntro)
	{
		remove(ngSpr);
		remove(credGroup);
		if (ClientPrefs.data.flashing) FlxG.camera.flash(0xFFFFFFFF, 1);
		skippedIntro = true;
	}
}

function getIntroTextShit():Array<Array<String>>
{
	var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
	var swagGoodArray:Array<Array<String>> = [];

	for (i in firstArray)
	{
		swagGoodArray.push(i.split('--'));
	}

	return swagGoodArray;
}
}
