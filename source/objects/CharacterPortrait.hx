package objects;

class CharacterPortrait extends FlxSprite
{
	public var pJson:Dynamic;
	
	public function new(portraitName:String) {
		super(0, 0);

	    changePortrait(portraitName);
	}
	
	public function changePortrait(newPortrait:String):Void
    {
           loadGraphic(Paths.image('menus/story-freeplay/portraits/$newPortrait'));
           antialiasing = ClientPrefs.data.antialiasing;
            
            pJson = {offsets: [0, 0], bgSprite: "placeholder", scale: [0, 0], flipTween: false};
            
            var jsonPath:String = Paths.json('menus/story-freeplay/portraits/$newPortrait');
            if(Paths.fileExists(jsonPath, TEXT)) {
                var rawJson:String = Paths.getTextFromFile(jsonPath);
                pJson = haxe.Json.parse(rawJson);
           }
            
            if (pJson.flipTween == null) {
                pJson.flipTween = false;
            }
            
            if (pJson.bgSprite == null) {
                pJson.bgSprite = "default";
            }
            
            if (pJson.scale != null) {
               scale.set(pJson.scale[0], pJson.scale[1]);
            }
            
            if (pJson.offsets != null) {
               offset.set(pJson.offsets[0], pJson.offsets[1]);
            }
    }
}