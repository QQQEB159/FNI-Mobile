package objects;

class CharacterPortrait extends FlxSprite
{
	public var pJson:Dynamic;
	
	public function new(image:String) {
		super();

	    loadWithData(image);
	}

	private function loadWithData(image:String) {
        try {
            loadGraphic(Paths.image('menus/story-freeplay/portraits/' + image));
            antialiasing = ClientPrefs.data.antialiasing;
            
            var jsonPath:String = Paths.json('menus/story-freeplay/portraits/' + image);
            if(Paths.fileExists(jsonPath, TEXT)) {
                var rawJson:String = Paths.getTextFromFile(jsonPath);
                pJson = haxe.Json.parse(rawJson);
                applyJsonConfig();
           }
        }
    }
	
	private function applyJsonConfig() {
        if (pJson == null) return;
        
        if (pJson.offsets != null) {
            offset.set(pJson.offsets[0], pJson.offsets[1]);
        }
        
        if (pJson.scale != null) {
            scale.set(pJson.scale[0], pJson.scale[1]);
            updateHitbox();
        }
        
        if (pJson.flipTween == null) {
            pJson.flipTween = false;
        }
    }
	
	public function changePortrait(image:String) {
		loadWithData(image);
	}
}