package;

import flixel.input.keyboard.FlxKey;
import states.StoryMenuState;
import states.CustomState;
import states.FlashingState;

class Init extends MusicBeatState
{
    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];
    
    override function create() {
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
		
		controls.isInSubstate = false;
		if(FlxG.save.data.disclaimerRead == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		    MusicBeatState.switchState(new CustomState(Paths.hscript("states/FlashingState")));
		}
		else
		MusicBeatState.switchState(new CustomState(Paths.hscript("states/TitleState")));
    }
}
