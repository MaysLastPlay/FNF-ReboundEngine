package funkin.states.secret;

class WarningState extends MusicBeatState
{
    var bg:FlxSprite;
    var reboundLogo:FlxSprite;
    var sbinator:FlxSprite;
    var haxeFlixelLogo:FlxSprite;
    var powered:FlxText;
    var flixelEngine:FlxText;
    var info:FlxText;

    var warningText:FlxText;
    var subWarningText:FlxText;
    var controlsAllower:Bool = true;

    override public function create()
    {   
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
        bg.setGraphicSize(Std.int(bg.width * 1.2));
        bg.color = FlxColor.GRAY;
        bg.alpha = 0.3;
        bg.antialiasing = true;
        bg.screenCenter();
        add(bg);

        reboundLogo = new FlxSprite().loadGraphic(Paths.image("intro/rebound"));
        reboundLogo.scale.set(0.8, 0.8);
        reboundLogo.active = false;
        reboundLogo.alpha = 0;
        reboundLogo.updateHitbox();
        reboundLogo.screenCenter();
        add(reboundLogo);
        
        sbinator = new FlxSprite().loadGraphic(Paths.image("menus/creditsMenu/credits/stefan"));
        sbinator.active = false;
        sbinator.alpha = 0;
        sbinator.screenCenter();
        sbinator.updateHitbox();
        add(sbinator);

        haxeFlixelLogo = new FlxSprite(270, 20).loadGraphic(Paths.image("intro/flixel"));
        haxeFlixelLogo.scale.set(0.4, 0.4);
        haxeFlixelLogo.active = false;
        haxeFlixelLogo.alpha = 0;
        add(haxeFlixelLogo);

        powered = new FlxText(590, 190, 0, "Powered by", true);
        powered.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
        powered.alpha = 0;
        powered.active = false;
        add(powered);

        flixelEngine = new FlxText(590, 210, 0, "HaxeFlixel", true);
        flixelEngine.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
        flixelEngine.alpha = 0;
        flixelEngine.active = false;
        add(flixelEngine);

        info = new FlxText(0, 500, FlxG.width, "@2025 Funkin Crew. All rights reserved. Funkin, the Funkin logo\nHaxeFlixel and the HaxeFlixel logo are trademarks\nand/or registered trademarks of HaxeFlixel!");
        info.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
        info.alpha = 0;
        info.active = false;
        add(info);

        warningText = new FlxText(0, 220, FlxG.width, "WARNING!", true);
        warningText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
        add(warningText);

        subWarningText = new FlxText(0, 320, FlxG.width, "Rebouns Engine is on\ncurrent development and\nnot everything is fully done!\n\nPress ENTER to start engine or\nESCAPE to simply leave!");
        subWarningText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, true);
        add(subWarningText);
    }

    override public function update(elapsed:Float)
    {
        if (controls.ACCEPT && controlsAllower)
        {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            controlsAllower = false;
            for (warningStuff in [bg, warningText, subWarningText])
            {
                FlxTween.tween(warningStuff, {alpha: 0}, 1, {
                    onComplete: (_) -> startValveIntro()
                });
            }
        }

        if (controls.BACK && controlsAllower)
        {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            controlsAllower = false;
            for (warningStuff in [bg, warningText, subWarningText])
            {
                FlxTween.tween(warningStuff, {alpha: 0}, 1, {
                    onComplete: (_) -> lime.system.System.exit(1)
                });
            }
        }

        super.update(elapsed);
    }

    public function startValveIntro()
    {
        new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.sound.play(Paths.sound("heavyIntro"));
            for (warningStuff in [warningText, subWarningText]) warningStuff.kill();
		});

        new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			reboundLogo.active = true;
            FlxTween.tween(reboundLogo, {alpha: 1}, 0.5);
		});

        new FlxTimer().start(6.5, function(tmr:FlxTimer)
		{
            reboundLogo.loadGraphic(Paths.image("intro/play"));
            reboundLogo.scale.set(0.5, 0.5);
		});

        new FlxTimer().start(6.9, function(tmr:FlxTimer)
		{
            reboundLogo.loadGraphic(Paths.image("intro/SB"));
            reboundLogo.scale.set(1, 1);
		});

        new FlxTimer().start(7.3, function(tmr:FlxTimer)
		{
            reboundLogo.loadGraphic(Paths.image("intro/play"));
            reboundLogo.scale.set(0.5, 0.5);
		});

        new FlxTimer().start(7.8, function(tmr:FlxTimer)
		{
            reboundLogo.loadGraphic(Paths.image("intro/SB"));
            reboundLogo.scale.set(1, 1);
		});

        new FlxTimer().start(8.5, function(tmr:FlxTimer)
		{
            reboundLogo.loadGraphic(Paths.image("intro/rebound"));
            reboundLogo.scale.set(0.8, 0.8);
		});

        new FlxTimer().start(9, function(tmr:FlxTimer)
		{
			FlxTween.tween(reboundLogo, {alpha: 0}, 1);
		});

        new FlxTimer().start(10.7, function(tmr:FlxTimer)
		{
			FlxTween.tween(sbinator, {alpha: 1}, 1.5);
            reboundLogo.kill();
		});

        new FlxTimer().start(14, function(tmr:FlxTimer)
		{
			FlxTween.tween(sbinator, {alpha: 0}, 1);
		});

        new FlxTimer().start(15, function(tmr:FlxTimer)
		{
            FlxTween.tween(bg, {alpha: 0.5}, 1);
		});

        new FlxTimer().start(15.5, function(tmr:FlxTimer)
		{
			FlxTween.tween(haxeFlixelLogo, {alpha: 1}, 0.7);
            FlxTween.tween(powered, {alpha: 1}, 0.7);
            FlxTween.tween(flixelEngine, {alpha: 1}, 0.7);
		});

        new FlxTimer().start(16, function(tmr:FlxTimer)
		{
            FlxTween.tween(info, {alpha: 0.6}, 0.7);
		});

        new FlxTimer().start(19, function(tmr:FlxTimer)
		{
            FlxTween.tween(bg, {alpha: 0}, 1);
		});

        new FlxTimer().start(21, function(tmr:FlxTimer)
		{
			FlxTween.tween(haxeFlixelLogo, {alpha: 0}, 1);
            FlxTween.tween(powered, {alpha: 0}, 0.7);
            FlxTween.tween(flixelEngine, {alpha: 0}, 1);
            FlxTween.tween(info, {alpha: 0}, 1);
		});

        new FlxTimer().start(24, function(tmr:FlxTimer)
		{
			FlxG.switchState(() -> new TitleState());
		});
    }
}