package funkin.backend.system;

import funkin.system.ui.FunkinSoundTray;
import flixel.FlxBasic;
import flixel.FlxGame;
import flixel.util.typeLimit.NextState;

#if CRASH_HANDLER
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;

#if SAVE_CRASH_LOGS
import sys.io.File;
#end

#if sys
import lime.system.System;
#end
#end

class FNFGame extends FlxGame
{
	public function new(gameWidth = 0, gameHeight = 0, ?initialState:InitialState, updateFramerate = 60, drawFramerate = 60, skipSplash = false, ?startFullscreen:Bool)
	{
		startFullscreen = startFullscreen ?? FlxG.save.data.fullscreen;
		super(gameWidth, gameHeight, initialState, updateFramerate, drawFramerate, skipSplash, startFullscreen);

		// FlxG.game._customSoundTray wants just the class, it calls new from
		// create() in there, which gets called when it's added to stage
		// which is why it needs to be added before addChild(game) here
		@:privateAccess
    	_customSoundTray = funkin.system.ui.FunkinSoundTray;
	}

	override function update():Void
	{
		super.update();

		if (FlxG.keys.justPressed.F5) FlxG.resetState();
	}

	var skipNextTickUpdate:Bool = false;
	public override function switchState() {
		super.switchState();
		// draw once to put all images in gpu then put the last update time to now to prevent lag spikes or whatever
		draw();
		_total = ticks = getTicks();
		skipNextTickUpdate = true;
	}

	public override function onEnterFrame(t) {
		if (skipNextTickUpdate != (skipNextTickUpdate = false))
			_total = ticks = getTicks();
		super.onEnterFrame(t);
	}
}
