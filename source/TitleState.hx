package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		super.create();

		FlxG.save.bind('jetpackfunkin', 'thewhtieninja');
		ClientPrefs.loadPrefs();

		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		}
		persistentUpdate = true;
		persistentDraw = true;

		FlxG.mouse.visible = false;
		
		#if desktop
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
		}
		#end

		var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		bg.scrollFactor.set();
		add(bg);
		var logo:FlxSprite;
		logo = new FlxSprite(0, 0).loadGraphic(Paths.image('funkinamazing'));
		logo.screenCenter();
		logo.x -= 25;
		logo.alpha = 0;
		add(logo);

		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			FlxG.sound.play(Paths.sound('intro'));
			FlxTween.tween(logo, {alpha: 1}, 0.25);
			new FlxTimer().start(1, function(tmr:FlxTimer) {
				FlxTween.tween(logo, {alpha: 0}, 1);
				new FlxTimer().start(1, function(tmr:FlxTimer) {
					if(FlxG.sound.music == null) {
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					}
			
					Conductor.changeBPM(102);
					persistentUpdate = true;
			
					var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					bg.scrollFactor.set();
					add(bg);
			
					var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					bg.scrollFactor.set();
					add(bg);
			
					MusicBeatState.switchState(new MainMenuState());
				});
			});
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}
}
