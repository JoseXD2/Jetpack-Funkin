package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

using StringTools;

class PrefrencesOption extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Prefrences Settings';
		rpcTitle = 'Prefrences Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Controller Mode',
			'Check this if you want to play with\na controller instead of using your Keyboard.',
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Disable Reset Button',
			"If checked, pressing Reset won't do anything.",
			'noReset',
			'bool',
			false);
		addOption(option);

        var option:Option = new Option('Hide HUD',
            'If checked, hides most HUD elements.',
            'hideHud',
            'bool',
            false);
        addOption(option);

        var option:Option = new Option('Camera Zooms',
            "If unchecked, the camera won't zoom in on a beat hit.",
            'camZooms',
            'bool',
            true);
        addOption(option);

        var option:Option = new Option('HUD Transparency',
            'How much transparent should the health bar and icons be.',
            'healthBarAlpha',
            'percent',
            1);
        option.scrollSpeed = 1.6;
        option.minValue = 0.0;
        option.maxValue = 1;
        option.changeValue = 0.1;
        option.decimals = 1;
        addOption(option);

        var option:Option = new Option('Anti-Aliasing',
            'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
            'globalAntialiasing',
            'bool',
            true);
        option.showBoyfriend = true;
        option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
        addOption(option);

        #if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
        var option:Option = new Option('Framerate',
            "Pretty self explanatory, isn't it?",
            'framerate',
            'int',
            60);
        addOption(option);

        option.minValue = 60;
        option.maxValue = 240;
        option.displayFormat = '%v FPS';
        option.onChange = onChangeFramerate;
        #end

		super();
	}

    var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

    function onChangeAntiAliasing()
    {
        for (sprite in members)
        {
            var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
            var sprite:FlxSprite = sprite; //Don't judge me ok
            if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
                sprite.antialiasing = ClientPrefs.globalAntialiasing;
            }
        }
    }

    function onChangeFramerate()
    {
        if(ClientPrefs.framerate > FlxG.drawFramerate)
        {
            FlxG.updateFramerate = ClientPrefs.framerate;
            FlxG.drawFramerate = ClientPrefs.framerate;
        }
        else
        {
            FlxG.drawFramerate = ClientPrefs.framerate;
            FlxG.updateFramerate = ClientPrefs.framerate;
        }
    }
}
