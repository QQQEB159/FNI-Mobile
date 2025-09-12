package states;

#if HSCRIPT_ALLOWED
import psychlua.HScript;
import crowplexus.iris.Iris;
import crowplexus.hscript.Expr.Error as IrisError;
import crowplexus.hscript.Printer;
#end
import flixel.group.FlxGroup;

class CustomState extends MusicBeatState
{
	public var qqqeb:String;

	public function new(script:String = '')
	{
		this.qqqeb = script;

		super();
	}

	#if HSCRIPT_ALLOWED
	var hscript:HScript;
	#end
	override function create()
	{
		#if HSCRIPT_ALLOWED
			var scriptPath:String = qqqeb;
			if(FileSystem.exists(scriptPath))
			{
				try
				{
					hscript = new HScript(null, scriptPath);
	
					if(hscript.exists('onCreate'))
					{
						hscript.call('onCreate');
						trace('initialized hscript interp successfully: $scriptPath');
						return super.create();
					}
					else
					{
						trace('"$scriptPath" contains no \"onCreate" function, stopping script.');
					}
				}
				catch(e:IrisError)
				{
					var pos:HScriptInfos = cast {fileName: scriptPath, showLine: false};
					Iris.error(Printer.errorToString(e, false), pos);
					var hscript:HScript = cast (Iris.instances.get(scriptPath), HScript);
				}
				if(hscript != null) hscript.destroy();
				hscript = null;
			}
		#end
		super.create();
	}

	public function createGroup():FlxGroup {
        return new FlxGroup();
    }
	
	override function closeSubState() {
	    super.closeSubState();
	    
	    #if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onCloseSubstate')) hscript.call('onCloseSubstate');
		}
		#end
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onUpdate')) hscript.call('onUpdate', [elapsed]);
			return;
		}
		#end
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		#if HSCRIPT_ALLOWED
		if(hscript != null)
		{
			if(hscript.exists('onBeatHit')) hscript.call('onBeatHit');
		}
		#end
	}
	
	#if HSCRIPT_ALLOWED
	override function destroy()
	{
		if(hscript != null)
		{
			if(hscript.exists('onDestroy')) hscript.call('onDestroy');
			hscript.destroy();
		}
		hscript = null;
		super.destroy();
	}
	#end
}