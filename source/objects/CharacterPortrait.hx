package objects;

import haxe.Json;

typedef PortraitData =
{
	var offsets:Array<Float>;
	var bgSprite:String;
	var scale:Array<Float>;
	var ?flipTween:Bool;
}

class CharacterPortrait extends FlxSprite
{
	public var pJson:PortraitData;
	
	public function new(portrait:String)
	{
		super();
		loadPortrait(portrait);
	}
	
	public function loadPortrait(portrait:String)
	{
		try {
			loadGraphic(Paths.image('menus/story-freeplay/portraits/' + portrait));
			antialiasing = ClientPrefs.data.antialiasing;
			
			var jsonPath:String = Paths.json('menus/story-freeplay/portraits/' + portrait);
            if(Paths.fileExists(jsonPath, TEXT)) {
                var rawJson:String = Paths.getTextFromFile(jsonPath);
                pJson = Json.parse(rawJson);
            }
			var _scale = pJson.scale;
			var _offsets = pJson.offsets;
				
			offset.x += _offsets[0];
			offset.y += _offsets[1];
			scale.set(_scale[0], _scale[1]);
			updateHitbox();
	   }
	}
	
	public function changePortrait(portrait:String)
	{
	   loadPortrait(portrait);
	}
}