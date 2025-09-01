package scripts;

import crowplexus.iris.Iris;

import extensions.hscript.InterpEx;

import objects.*;

@:access(crowplexus.iris.Iris)
@:access(states.PlayState)
class FunkinHScript extends Iris implements IFlxDestroyable
{
	/**
	 * List of all accepted hscript extensions
	 */
	public static final H_EXTS:Array<String> = ['hx', 'hxs', 'hscript'];
	
	/**
	 * wrapper for `Paths.getPath` but attempts to append a supported hx extension to its path
	 * @param path 
	 * @return String
	 */
	public static function getPath(path:String):String
	{
		for (extension in H_EXTS)
		{
			if (path.endsWith(extension)) return path;
			
			final file = '$path.$extension';
			
			final targetPath = Paths.getPath(file, TEXT, null, true);
			if (Paths.exists(targetPath)) return targetPath;
		}
		return path;
	}
	
	/**
	 * Helper to check if a path ends with a support hx extension
	 */
	public static function isHxFile(path:String):Bool
	{
		for (extension in H_EXTS)
			if (path.endsWith(extension)) return true;
			
		return false;
	}
	
	/**
	 * Initiates the debugging backend of Iris
	 */
	/*public static function init()
	{
		Iris.warn = (x, ?pos) -> {
			final output:String = '[${pos.fileName}]: WARN: ${pos.lineNumber} -> $x';
			
			DebugTextPlugin.addText(Std.string(output), Logger.getHexColourFromSeverity(WARN));
			
			Iris.logLevel(ERROR, x, pos);
		}
		
		Iris.error = (x, ?pos) -> {
			final output:String = '[${pos.fileName}]: ERROR: ${pos.lineNumber} -> $x';
			
			DebugTextPlugin.addText(Std.string(output), Logger.getHexColourFromSeverity(ERROR));
			
			Iris.logLevel(NONE, x, pos);
		}
		
		Iris.print = (x, ?pos) -> {
			final output:String = '[${pos.fileName}]: TRACE: ${pos.lineNumber} -> $x';
			
			DebugTextPlugin.addText(Std.string(output), Logger.getHexColourFromSeverity(PRINT));
			
			Iris.logLevel(NONE, x, pos);
		}
	}*/
	
	/**
	 * Creates a new `FunkinHScript` from a string
	 * @param script 
	 * @param name 
	 * @param additionalVars 
	 */
	public static function fromString(script:String, ?name:String = "Script", ?additionalVars:Map<String, Any>)
	{
		return new FunkinHScript(script, name, additionalVars);
	}
	
	/**
	 * Creates a new `FunkinHScript` from a filepath
	 * 
	 * @param file 
	 * @param name 
	 * @param additionalVars 
	 */
	public static function fromFile(file:String, ?name:String, ?additionalVars:Map<String, Any>)
	{
		name ??= file;
		
		return new FunkinHScript(Paths.getContent(file), name, additionalVars);
	}
	
	/**
	 * is true if parsing failed
	 */
	@:noCompletion public var __garbage:Bool = false;
	
	public function new(script:String, ?name:String = "Script", ?additionalVars:Map<String, Any>)
	{
		super(script, {name: name, autoRun: false, autoPreset: false});
		
		interp = new InterpEx(FlxG.state);
		
		preset();
		
		if (additionalVars != null)
		{
			for (key => obj in additionalVars)
				set(key, additionalVars.get(obj));
		}
		
		tryExecute();
	}
	
	/**
	 * safer parsing
	 */
	inline function tryExecute()
	{
		var ret:Dynamic = null;
		try
		{
			ret = execute();
		}
		catch (e)
		{
			__garbage = true;
			//Logger.log('[${name}]: PARSING ERROR: $e', ERROR, true);
		}
		return ret;
	}
	
	// kept for notescript stuff
	public function executeFunc(func:String, ?parameters:Array<Dynamic>, ?theObject:Any, ?extraVars:Map<String, Dynamic>):Dynamic
	{
		extraVars ??= [];
		
		if (exists(func))
		{
			var daFunc = get(func);
			if (Reflect.isFunction(daFunc))
			{
				var returnVal:Dynamic = null;
				var defaultShit:Map<String, Dynamic> = [];
				
				if (theObject != null) extraVars.set("this", theObject);
				
				for (key in extraVars.keys())
				{
					defaultShit.set(key, get(key));
					set(key, extraVars.get(key));
				}
				
				try
				{
					returnVal = Reflect.callMethod(theObject, daFunc, parameters ?? []);
				}
				catch (e:haxe.Exception)
				{
					#if sys
					Sys.println(e.message);
					#end
				}
				
				for (key in defaultShit.keys())
				{
					set(key, defaultShit.get(key));
				}
				
				return returnVal;
			}
		}
		return null;
	}
	
	@:inheritDoc
	override function preset()
	{
		super.preset();
		// Some very commonly used classes
		set('Type', Type);
		#if sys
		set('File', File);
		set('FileSystem', FileSystem);
		#end
		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxCamera', flixel.FlxCamera);
		set('PsychCamera', backend.PsychCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('Countdown', backend.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('StorageUtil', StorageUtil);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		#if ACHIEVEMENTS_ALLOWED
		set('Achievements', Achievements);
		#end
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', objects.Note);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		set('ErrorHandledRuntimeShader', shaders.ErrorHandledShader.ErrorHandledRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		#if flxanimate
		set('FlxAnimate', FlxAnimate);
		#end
		set('script', this);
		set('game', FlxG.state);
		set('controls', Controls.instance);
		set('Function_Halt', Globals.Function_Halt);
		set('Function_Stop', Globals.Function_Stop);
		set('Function_Continue', Globals.Function_Continue);
		set('Globals', scripts.Globals);
	}
}

class CustomFlxColor {
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int 
		return cast FlxColor.fromInt(Value);

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);

	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);

	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);

	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);

	public static function fromString(str:String):Int
		return cast FlxColor.fromString(str);
}
