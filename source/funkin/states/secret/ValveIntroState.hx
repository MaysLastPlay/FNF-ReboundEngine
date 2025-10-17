package funkin.states.secret;

class WarningState extends MusicBeatState
{
    var reboundLogo:FlxSprite;
    var sbinator:FlxSprite;
    var haxeFlixelLogo:FlxSprite;

    var warningText:FlxText;
    var subWarningText:FlxText;
    var controlsAllower:Bool = true;

    override public function create()
    {   
        super.create();

        reboundLogo = new FlxSprite().loadGraphic(Paths.image("intro/rebound"));
        reboundLogo.scale.set(0.8, 0.8);
        reboundLogo.active = false;
        reboundLogo.visible = false;
        reboundLogo.updateHitbox();
        reboundLogo.screenCenter();
        add(reboundLogo);
        
        sbinator = new FlxSprite().loadGraphic(Paths.image("menus/creditsMenu/credits/stefan"));
        sbinator.active = false;
        sbinator.alpha = 0;
        sbinator.screenCenter();
        sbinator.updateHitbox();
        add(sbinator);

        warningText = new FlxText(0, 220, FlxG.width, "WARNING!", true);
        warningText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, true);
        add(warningText);

        subWarningText = new FlxText(0, 320, FlxG.width, "Rebouns Engine is on\ncurrent development and\nnot everything is fully done!\n\nPress ENTER to start engine or\nESCAPE to simply leave!");
        subWarningText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, true);
        add(subWarningText);
    }

    override public function update(elapsed:Float)
    {
        if (controls.ACCEPT && controlsAllower)
        {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            controlsAllower = false;
            for (warningStuff in [warningText, subWarningText])
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
            for (warningStuff in [warningText, subWarningText])
            {
                FlxTween.tween(warningStuff, {alpha: 0}, 1, {
                    onComplete: (_) -> lime.system.System.exit(1)
                });
            }
        }
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
            reboundLogo.visible = true;
		});

        new FlxTimer().start(7.5, function(tmr:FlxTimer)
		{
			FlxTween.tween(reboundLogo, {alpha: 0}, 1);
		});

        new FlxTimer().start(9, function(tmr:FlxTimer)
		{
			FlxTween.tween(sbinator, {alpha: 1}, 1.5);
            reboundLogo.kill();
		});

        new FlxTimer().start(14, function(tmr:FlxTimer)
		{
			FlxTween.tween(sbinator, {alpha: 0}, 1);
		});

        new FlxTimer().start(23, function(tmr:FlxTimer)
		{
			FlxG.switchState(() -> new TitleState());
		});
    }
}