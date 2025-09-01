package states;

class CustomState extends MusicBeatState
{
	public function new(scriptName:String)
	{
		super();
		
		setUpScript(scriptName, false);
		scriptGroup.parent = this;
	}
	
	override function create()
	{
		super.create();
		
		scriptGroup.call('onCreate', []);
	}
}
