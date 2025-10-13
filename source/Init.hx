package;

import flixel.FlxState;
import lime.app.Application;
import ui.PreferencesMenu; 

class Init extends FlxState
{
    override function create():Void
    {
        FlxG.game.focusLostFramerate = 60;

        FlxG.fixedTimestep = false;
        FlxG.sound.muteKeys = [ZERO];

        FlxG.save.bind('funkin', funkin.backend.Constants.SAVE_FILE);

		PreferencesMenu.initPrefs();
		PlayerSettings.init();
		Highscore.load();

        #if desktop
		FlxG.mouse.visible = false;
    	FlxG.mouse.useSystemCursor = true;
		#end

        if(FlxG.save?.data?.fullscreen)
			FlxG.fullscreen = FlxG.save.data.fullscreen;

        if (FlxG.save.data.weekUnlocked != null)
		{
			if (StoryMenuState.weekUnlocked.length < 4) StoryMenuState.weekUnlocked.insert(0, true);
			if (!StoryMenuState.weekUnlocked[0]) StoryMenuState.weekUnlocked[0] = true;
		}

        #if DISCORD_ALLOWED
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		});
		#end

        FlxG.switchState(() -> new funkin.states.menus.TitleState());

        super.create();
    }
}