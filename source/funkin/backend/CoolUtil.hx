package funkin.backend;

import flixel.FlxG;
import lime.utils.Assets;

using StringTools;

final class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	/* public static function camLerpShit(ratio:Float)
	{
		return FlxG.elapsed / (1 / 60) * ratio;
	}

	public static function coolLerp(a:Float, b:Float, ratio:Float)
	{
		return a + camLerpShit(ratio) * (b - a);
	} */

	inline public static function showPopUp(message:String, title:String #if sl_windows_api, ?icon:MessageBoxIcon, ?type:MessageBoxType #end, showScrollableMSG:Bool = false):Void
	{
		#if android
		AndroidTools.showAlertDialog(title, message, {name: "OK", func: null}, null);
		#elseif linux
		Sys.command("zenity", ["--info", "--title=" + title, "--text=" + message]);
		#elseif sl_windows_api
		if (showScrollableMSG)
			WindowsAPI.showScrollableMessage(message, title);
		else
			WindowsAPI.showMessageBox(message, title, icon, type);
		#else
		lime.app.Application.current.window.alert(message, title);
		#end
	}

	public static inline function openURL(url:String)
    {
        #if linux
        var xdgCommand = Sys.command("xdg-open", [url]);
        if (xdgCommand != 0) xdgCommand = Sys.command("/usr/bin/xdg-open", [url]);
        #else
        FlxG.openURL(url);
        #end

        // trace("URL: " + url);
    }

	inline public static function colorFromString(color:String):FlxColor
	{
		var hideCharacters = ~/[\t\n\r]/;
		var color:String = hideCharacters.split(color).join('').trim();
		if(color.startsWith('0x')) color = color.substring(color.length - 6);

		var colorNum:Null<FlxColor> = FlxColor.fromString(color);
		if(colorNum == null) colorNum = FlxColor.fromString('#$color');
		return colorNum != null ? colorNum : FlxColor.WHITE;
	}
}
