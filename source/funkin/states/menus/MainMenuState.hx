package funkin.states.menus;

import ui.OptionsState;
import ui.PreferencesMenu;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var engineVersion:String = '0.1';

	var curSelected:Int = 0;
	var grpOptions:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['story mode', 'freeplay', 'credits', 'options'];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var bgPositionY:Float = 0;
	
	var flickeringMagenta:Float = 1;
	var flickeringButtons:Float = 1;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(0, 0, Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.17;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		magenta = new FlxSprite(0, 0, Paths.image('menuDesat'));
		magenta.scrollFactor.x = bg.scrollFactor.x;
		magenta.scrollFactor.y = bg.scrollFactor.y;
		magenta.setGraphicSize(Std.int(bg.width));
		magenta.updateHitbox();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.screenCenter();
		magenta.color = 0xFFFD719B;
		if (PreferencesMenu.preferences.get('flashing-menu')) add(magenta);

		grpOptions = new FlxTypedGroup<FlxSprite>();
		add(grpOptions);

		var optionSize:Float = 0.9;
		if(optionShit.length > 4)
		{
			for(i in 0...(optionShit.length - 4))
				optionSize -= 0.04;
		}
		
		for(i in 0...optionShit.length)
		{
			var buttons = new FlxSprite();
			buttons.frames = Paths.getSparrowAtlas('menus/mainMenu/' + optionShit[i].replace(' ', '-'));
			buttons.animation.addByPrefix('idle',  optionShit[i] + ' basic', 24, true);
			buttons.animation.addByPrefix('selection', optionShit[i] + ' white', 24, true);
			buttons.animation.play('idle');
			grpOptions.add(buttons);
			
			buttons.scale.set(optionSize, optionSize);
			buttons.updateHitbox();
			
			var buttonsSize:Float = (90 * optionSize);
			
			var minY:Float = 40 + buttonsSize;
			var maxY:Float = FlxG.height - buttonsSize - 40;
			
			if(optionShit.length < 4)
			for(i in 0...(4 - optionShit.length))
			{
				minY += buttonsSize;
				maxY -= buttonsSize;
			}
			
			buttons.x = FlxG.width / 2;
			buttons.y = FlxMath.lerp(minY, maxY, i / (optionShit.length - 1));
			buttons.ID = i;
		}
		
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Rebound Engine v" + engineVersion + "\nFriday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		changeSelection();

		super.create();
	}

	var optionSelected:Bool = false;
	override function update(elapsed:Float)
	{
		// FlxG.camera.followLerp = CoolUtil.camLerpShit(0.06);

		if (FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if (!optionSelected)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeSelection(1);
			}

			if (controls.BACK)
			{
				optionSelected = true;
				FlxG.switchState(() -> new TitleState());
			}
			
			if(controls.ACCEPT)
			{
				if(["donate"].contains(optionShit[curSelected]))
				{
					CoolUtil.openURL("https://ninja-muffin24.itch.io/funkin");
				}
				else
				{
					optionSelected = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
					
					for (item in grpOptions.members)
					{
						if (item.ID != curSelected) FlxTween.tween(item, {alpha: 0}, 0.4, {ease: FlxEase.cubeOut});
					}
					
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						switch(optionShit[curSelected])
						{
							case "story mode": FlxG.switchState(() -> new StoryMenuState());
							case "freeplay": FlxG.switchState(() -> new FreeplayState());
							case "credits": FlxG.switchState(() -> new CreditsState());
							case "options": FlxG.switchState(() -> new OptionsState());
							default: FlxG.resetState();
						}
					});
				}
			}
		}
		else
		{
			if(!PreferencesMenu.getPref('flashing-menu'))
			{
				if(PreferencesMenu.getPref('flashing-menu'))
				{
					flickeringMagenta += elapsed;
					if(flickeringMagenta >= 0.15)
					{
						flickeringMagenta = 0;
						magenta.visible = !magenta.visible;
					}
				}
				
				flickeringButtons += elapsed;
				if(flickeringButtons >= 0.15 / 2)
				{
					flickeringButtons = 0;
					for(item in grpOptions.members)
						if(item.ID == curSelected)
							item.visible = !item.visible;
				}
			}
		}
		
		bg.y = FlxMath.lerp(bg.y, bgPositionY, elapsed * 6);
		magenta.setPosition(bg.x, bg.y);
	}

	public function changeSelection(change:Int = 0)
	{
		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		
		curSelected += change;
		curSelected = FlxMath.wrap(curSelected, 0, optionShit.length - 1);
		
		bgPositionY = FlxMath.lerp(0, -(bg.height - FlxG.height), curSelected / (optionShit.length - 1));
		
		for(item in grpOptions.members)
		{
			item.animation.play('idle');
			if(curSelected == item.ID)
				item.animation.play('selection');
			
			item.updateHitbox();
			item.offset.x += (item.frameWidth * item.scale.x) / 2;
			item.offset.y += (item.frameHeight* item.scale.y) / 2;
		}
	}
}
