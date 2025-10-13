package;

import funkin.backend.system.FNFGame;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import lime.graphics.Image;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	public static final game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: Init, // initial game state
        zoom: -1, // If -1, zoom is automatically calculated to fit the window dimensions.
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsCounter:FPSCounter;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());

		MemoryUtil.enableGC();
	}

	public function new()
	{
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end

		super();

		CrashHandler.init();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		FlxG.stage.addEventListener(openfl.events.KeyboardEvent.KEY_DOWN, (e) ->
		{
			if (e.keyCode == FlxKey.F11) FlxG.fullscreen = !FlxG.fullscreen;
			if (e.keyCode == FlxKey.ENTER && e.altKey) e.stopImmediatePropagation();
		}, false, 100);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		#if (openfl < '9.2.0')
        var stageWidth:Int = Lib.current.stage.stageWidth;
	    var stageHeight:Int = Lib.current.stage.stageHeight;

	    if (game.zoom == -1)
	    {
		    var ratioX:Float = stageWidth / game.width;
		    var ratioY:Float = stageHeight / game.height;
		    game.zoom = Math.min(ratioX, ratioY);
		    game.width = Math.ceil(stageWidth / game.zoom);
		    game.height = Math.ceil(stageHeight / game.zoom);
	    }
        #elseif (openfl >= '9.2.0')
        if (game.zoom == -1) {
            game.zoom = 1;
        }
	    #end

		addChild(new FNFGame(game.width, game.height, Init, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		fpsCounter = new FPSCounter(5, 3);
		addChild(fpsCounter);

		FlxG.signals.gameResized.add((w, h) -> {
			resetSpriteCache(this);

            if (FlxG.cameras != null && FlxG.cameras.list != null) {
                for (cam in FlxG.cameras.list) {
                    if (cam != null)
                        resetSpriteCache(cam.flashSprite);
                }
            }

            if (FlxG.game != null)
                resetSpriteCache(FlxG.game);
        });

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end
	}

	@:noCompletion
	private static function resetSpriteCache(sprite:Sprite):Void {
		@:privateAccess {
			if (sprite != null)
			{
		   		sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
    }
}
