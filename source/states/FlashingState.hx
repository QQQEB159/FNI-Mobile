package states;

import flixel.FlxSubState;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var disclaimer:FlxSprite;

	override function create()
	{
		super.create();

		disclaimer = new FlxSprite(0, 0);
	    disclaimer.frames = Paths.getSparrowAtlas('menus/disclaimer');
	    disclaimer.animation.addByPrefix('loop', "loop");
        disclaimer.animation.play('loop');
        disclaimer.updateHitbox();
	    disclaimer.antialiasing = ClientPrefs.data.antialiasing;
        add(disclaimer);

		addTouchPad("NONE", "A");
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}
		
		if (controls.ACCEPT) {
        leftState = true;
        ClientPrefs.data.flashing = true;
		ClientPrefs.saveSettings();

        FlxG.sound.play(Paths.sound("confirmMenuBell"));
        FlxG.camera.flash(ClientPrefs.data.flashing ? 0xFFFFFFFF : 0xFF000000, 1, function() {
			new FlxTimer().start(1, function (tmr:FlxTimer) {
				MusicBeatState.switchState(new TitleState())
			});
		});
    }
		super.update(elapsed);
	}
}
