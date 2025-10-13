package funkin.states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState
{
    // Base menu stuff
    var bg:FlxSprite;
    var intendedColor:FlxColor;
    var checker:FlxBackdrop;
    var button:FlxSprite;
    var bottomBG:FlxSprite;
    var title:Alphabet;
    var bottomTitle:Alphabet;

    // Credit stuff (['Your name of icon', 'Actual name of you', 'Your descritpion', 'Your color hex id', 'Your social media link'])
    var creditsName:FlxText;
    var creditsDesc:FlxText;
    var creditsIcon:FlxSprite;
    var creditsList:Array<Array<String>> = [
       ['mayslastplay', 'MaysLastPlay', 'Main Owner, Programmer', '1fe1de', 'https://www.youtube.com/@MaysLastPlay'],
       ['2jeno', 'LJeno', 'Main Owner, Programmer', 'a8caff', 'https://www.youtube.com/@LJeno_'],
       ['stefan', 'Stefan2008', 'Owner, Programmer, Artist', '4400bd', 'https://www.youtube.com/@stefan2008_official'],
       ['greencoldtea', 'JustX', 'Programmer for Rebound', '2c81b7', 'https://github.com/GreenColdTea'],
       ['idklel', 'Idklel01', 'Helper for Rebound', '2806b5', 'https://github.com/Idklel01'],
    ];
    var creditsGroup:FlxTypedGroup<FlxSprite>;
    var currentSelector:Int = 0; // This will select a icon if of mentioned string from credits list. Default it will give MaysLastPlay because id is 0. --Stefan2008

    override public function create()
    {
        #if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In Credits Menu", null);
		#end

		bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menuDesat"));
		bg.alpha = 0.8;
        bg.screenCenter(X);
		add(bg);

		checker = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, FlxColor.BLACK, 0x0));
        checker.velocity.set(18, 18);
        checker.screenCenter();
        checker.alpha = 0.6;
        add(checker);

		creditsGroup = new FlxTypedGroup<FlxSprite>();
		add(creditsGroup);

		for (i in 0...creditsList.length)
		{
            creditsIcon = new FlxSprite(50 + (i * 140), 0).loadGraphic(Paths.image("menus/creditsMenu/credits/" + creditsList[i][0]));
            creditsIcon.x = 510;
            creditsIcon.y = 220;
            creditsIcon.updateHitbox();
            creditsGroup.add(creditsIcon);
            creditsIcon.ID = i;
		}

		bottomBG = new FlxSprite(0, FlxG.height - 42).makeGraphic(FlxG.width, 200, 0xFF000000);
        bottomBG.alpha = 0.6;
        add(bottomBG);

        title = new Alphabet(0, 0, "CREDITS", true);
        title.scrollFactor.set(0, 0);
        title.antialiasing = true;
        title.screenCenter(X);
        title.y = FlxG.height - 650;
        add(title);

		creditsName = new FlxText(0, 0, FlxG.width, "");
		creditsName.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditsName.scrollFactor.set(0, 0);
        creditsName.borderSize = 2;
        creditsName.antialiasing = true;
        creditsName.screenCenter(X);
        creditsName.y = FlxG.height - 490;
        add(creditsName);

        creditsDesc = new FlxText(0, 0, FlxG.width, "");
        creditsDesc.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        creditsDesc.scrollFactor.set(0, 0);
        creditsDesc.borderSize = 2;
        creditsDesc.antialiasing = true;
        creditsDesc.screenCenter(X);
        creditsDesc.y = FlxG.height - 38;
        add(creditsDesc);

        changeTheSelection(0);
        intendedColor = bg.color;

		super.create();
    }

    var textFloater:Float = 0;
    override public function update(elapsed:Float)
    {
        textFloater += elapsed;
        creditsName.y = 190 + (Math.sin(textFloater) * 1 ) * 10;

        if (controls.BACK) FlxG.switchState(() -> new MainMenuState());
        
        creditsGroup.forEach(function(member:FlxSprite)
        {
            var distItem:Int = -1;

            // This motherfucker opens 5 links in same time and causes the insane lag, so i don't really know why doesn't wants to open only 1 link. --Stefan2008
            if (controls.ACCEPT && (creditsList[currentSelector][4] == null || creditsList[currentSelector][4].length > 4))
            {
                distItem = member.ID;
                currentSelector = distItem;
                CoolUtil.openURL(creditsList[currentSelector][4]);
            }
        });

        if (controls.UI_LEFT_P) 
        {
            changeTheSelection(-1);
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
        else if (controls.UI_RIGHT_P) 
        {
            changeTheSelection(1);
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        super.update(elapsed);
    }

    function changeTheSelection(changer:Int = 0)
    {
        currentSelector += changer;

        if (currentSelector >= creditsGroup.length - 1) currentSelector = creditsGroup.length - 1; else if (currentSelector <= 0) currentSelector = 0;

        creditsGroup.forEach(function(spr:FlxSprite)
        {
            spr.y += 400;
            spr.kill();
            spr.updateHitbox();

            if (spr.ID == currentSelector)
            {
                spr.revive();
                spr.updateHitbox();
                spr.screenCenter();
            }
            spr.centerOffsets();
        });

        creditsName.text = creditsList[currentSelector][1];
        creditsDesc.text = creditsList[currentSelector][2];

        var newColor:FlxColor = CoolUtil.colorFromString(creditsList[currentSelector][3]);
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 0.5, bg.color, intendedColor);
		}
    }
}
