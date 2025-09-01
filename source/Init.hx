import flixel.input.keyboard.FlxKey;
import flixel.system.FlxAssets;
import flixel.FlxState;
import openfl.Lib;
import states.StoryMenuState;
import states.CustomState;
import backend.Controls;

/**
	This is the initialization class. if you ever want to set anything before the game starts or call anything then this is probably your best bet.
**/
class Init extends FlxState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public override function create() {
        Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		ClientPrefs.loadPrefs();
		Language.reloadPhrases();
		
		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
		}
		persistentUpdate = true;
		persistentDraw = true;
		MobileData.init();

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;

		super.create();
		
        MusicBeatState.switchState(new CustomState("TitleState"));
    }
}
