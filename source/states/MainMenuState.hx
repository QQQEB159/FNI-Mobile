package states;

import flixel.FlxObject;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import states.FreeplayState;
import states.PlayState;
import states.StoryMenuState;
import states.FreeplayState;
import states.CreditsState;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.CoolUtil;
import backend.Achievements;
import lime.app.Application;
import Math;
import Date;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
    var menuItems:FlxTypedGroup<Alphabet>;
var optionShit:Array<String> = [
    'Story',
    'Freeplay',
	'Awards',
    'Credits',
    'Twitter',
    'Options'
];

var gradPart1:FlxSprite;
var gradPart2:FlxSprite;
var camGame:FlxCamera;
var camFollow:FlxObject;
var camFollowPos:FlxObject;
var selector:Alphabet;
var leaveState:String = '';
	override function create()
	{
		super.create();

		if (FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'));

        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
    PlayState.SONG = null;
    persistentUpdate = persistentDraw = true;
	OptionsState.onPlayState = false;
	if (FlxG.save.data.weekCompleted != null) StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

    camGame = initPsychCamera();
    var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);

	var leDate = Date.now();
	if (leDate.getDay() == 5 && leDate.getHours() >= 18 && !Achievements.isUnlocked('friday_night_play'))
		Achievements.unlock('friday_night_play');

	var bg:FlxSprite = new FlxSprite(-640, -60).loadGraphic(Paths.image('menus/main/background'));
	bg.antialiasing = ClientPrefs.data.antialiasing;
	bg.scrollFactor.set(1, yScroll);
	bg.setGraphicSize(Std.int(bg.width * 0.52));
	bg.updateHitbox();

	var trol:FlxSprite = new FlxSprite(-640).loadGraphic(Paths.image('menus/main/senortrol'));
	trol.antialiasing = ClientPrefs.data.antialiasing;
	trol.scrollFactor.set(1, yScroll * 0.6);
	trol.setGraphicSize(Std.int(trol.width * 0.48));
	trol.updateHitbox();

	camFollow = new FlxObject(0, 0, 1, 1);
	camFollowPos = new FlxObject(-500, 0, 1, 1);

	gradPart1 = new FlxSprite(480 - FlxG.width).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
	gradPart1.scrollFactor.set();
	gradPart2 = FlxGradient.createGradientFlxSprite(120, FlxG.height, [0x0, 0xFF000000], 1, 180);
	gradPart2.scrollFactor.set();

	menuItems = new FlxTypedGroup<Alphabet>();

	for (i in 0...optionShit.length)
	{
		var newAlphabet:Alphabet = new Alphabet(64, 24, optionShit[i], true);
		newAlphabet.distancePerItem.set(0, 40);
		newAlphabet.y += (80 * (i - (optionShit.length / 2))) + 340;
		newAlphabet.ID = i;
		newAlphabet.scrollFactor.set(0, 0);
		menuItems.add(newAlphabet);

		if (i == 1 && !Achievements.isUnlocked('beat_story_mode')) newAlphabet.color = 0xFF444444;
	}

	menuItems.members[curSelected].alpha = 1;
	FlxG.camera.follow(camFollowPos, null, 1);

	selector = new Alphabet(0, 0, '<', true);
	selector.scrollFactor.set();

	var versionShit:FlxText = new FlxText(12, FlxG.height - 60, 0,
		'Psych Engine v1.0.4' + '\n'
		+ 'Friday Night Funkin\' v0.2.8' + '\n'
		+ "Friday Night Incident: Version 2" + '\n'
	);
	versionShit.scrollFactor.set();
	versionShit.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, "left", FlxTextBorderStyle.OUTLINE, 0xFF000000);

    for (i in [bg, trol, camFollow, camFollowPos, gradPart1, gradPart2, menuItems, selector, versionShit]) add(i);

	changeItem(0, false);
	updateSelection();
}

	var selectedSomethin:Bool = false;
    var lastCurSelected:Int = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 1) {
		FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		if (FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
	}

	gradPart2.x = gradPart1.x + gradPart1.width;

	var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
	camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

	if (!selectedSomethin)
	{
		if (controls.UI_UP_P) changeItem(-1, true);
		if (controls.UI_DOWN_P) changeItem(1, true);

		if (controls.BACK)
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleState());
		}

        if (controls.justPressed("debug_1")) {
            selectedSomethin = true;
            MusicBeatState.switchState(new MasterEditorMenu());
        }

		if (controls.ACCEPT)
		{
			if (optionShit[curSelected] == 'Twitter') {
				CoolUtil.browserLoad('https://twitter.com/FNIncident');
            } else if (curSelected == 1 && !Achievements.isUnlocked('beat_story_mode')) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
			} else {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenuBell'));

				menuItems.forEach(function(spr:Alphabet)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					} else {
						FlxTween.tween(camFollowPos, {x: -360}, 1, {ease: FlxEase.expoInOut});
						FlxTween.tween(gradPart1, {x: 0}, 1, {ease: FlxEase.expoInOut});

						var curOption:String = optionShit[curSelected];
						if (!ClientPrefs.data.flashing)
						{
							new flixel.util.FlxTimer().start(1, function(tmr:flixel.util.FlxTimer) {
								chooseItem(curOption);
							});
						} else {
							FlxFlicker.flicker(selector, 1, 0.06, false, false);
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker) {
								chooseItem(curOption);
							});
						}
					}
				});
			}
		}

		if (Math.floor(curSelected) != lastCurSelected) updateSelection();
	}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0, ?playSound:Bool = true)
{
	if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'));
	curSelected += huh;

	if (curSelected >= menuItems.length) curSelected = 0;
	if (curSelected != null && menuItems != null && curSelected < 0) curSelected = menuItems.length - 1;

	if (menuItems.members[curSelected].text == '') curSelected += huh;

	menuItems.forEach(function(spr:Alphabet){
		if (spr.ID == curSelected) {
			camFollow.setPosition(spr.getGraphicMidpoint().x,
			spr.getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));
		}
	});

	selector.color = menuItems.members[curSelected].color;
}

function chooseItem(daChoice:String)
{
	leaveState = daChoice;
	switch (daChoice)
	{
		case 'Story': MusicBeatState.switchState(new StoryMenuState());
		case 'Freeplay': 
			if (Achievements.isUnlocked('beat_story_mode')) {
				MusicBeatState.switchState(new FreeplayState());
			} else {
				selectedSomethin = false;
			}
		case 'Awards': MusicBeatState.switchState(new CreditsState());
		case 'Credits': MusicBeatState.switchState(new CreditsState());
		case 'Options': MusicBeatState.switchState(new options.OptionsState());
		default: MusicBeatState.resetState();
	}
}

override function destroy()
{
	if (leaveState == "Awards") {
		FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}
	super.destroy();
}

function updateSelection()
{
	menuItems.forEach(function(spr:FlxSprite) { spr.alpha = 0.6; });

	var curSelectedItem = menuItems.members[curSelected];
	FlxTween.tween(selector, {x: curSelectedItem.x + curSelectedItem.width + 16}, 0.15, {ease: FlxEase.sineOut});
	FlxTween.tween(selector, {y: curSelectedItem.y}, 0.15, {ease: FlxEase.sineOut});

	curSelectedItem.alpha = 1;
	lastCurSelected = Math.floor(curSelected);
}
}
