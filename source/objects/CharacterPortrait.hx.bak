package objects;

import haxe.Json;

typedef PortraitData =
{
	var ?offsets:Array<Float>;
	var ?bgSprite:String;
	var ?scale:Array<Float>;
	var ?flipTween:Bool;
}

class CharacterPortrait extends FlxSprite
{
	public var pJson:PortraitData;
	
	public function new(portrait:String)
	{
		super();
		antialiasing = ClientPrefs.data.antialiasing;
		loadPortrait(portrait);
	}
	
	public function loadPortrait(portrait:String)
	{
			loadGraphic(Paths.image('menus/story-freeplay/portraits/' + portrait));
			updateHitbox();
			centerOffsets();
			
			pJson.flipTween = false;
			pJson = Json.parse(Paths.getTextFromFile('images/menus/story-freeplay/portraits/$portrait.json'));
			var _scale = json.scale ?? [1, 1];
			var _offsets = json.offsets ?? [0, 0];
				
			offset.x += _offsets[0];
			offset.y += _offsets[1];
			scale.set(_scale[0], _scale[1]);
	}
	
	public function changePortrait(portrait:String)
	{
	   loadPortrait(portrait);
	}
}