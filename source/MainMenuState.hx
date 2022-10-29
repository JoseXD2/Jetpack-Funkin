package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;
	public static var curSelected3 = 0;

	var stufflist:Array<String> = ['play', 'credits', 'options'];
	var creditstuff:Array<String> = [
		'https://linktr.ee/the_white_ninja',
		'https://www.youtube.com/channel/UCqWC8U5f0qhK7xTVReq0Ptg',
		'https://www.youtube.com/c/CallyCobble'
	];

	var debugKeys:Array<FlxKey>;

	var buttons:FlxTypedGroup<FlxSprite>;
	var creditsstuffu:FlxTypedGroup<FlxSprite>;

	var floatstuff = 0.0;
	var floatstuff2 = 0.0;

	var logo:FlxSprite;
	var sidebar:FlxSprite;
	var backcredit:FlxSprite;

	var credits = false;

	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In the Main Menu", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var backgroundthing:FlxSprite = new FlxSprite(-56, -71);
		backgroundthing.loadGraphic(Paths.image('main menu/background'));
		add(backgroundthing);

		logo = new FlxSprite(143.75, 190.35);
		logo.loadGraphic(Paths.image('main menu/logo'));
		add(logo);

		sidebar = new FlxSprite(883.95, -21.25);
		sidebar.loadGraphic(Paths.image('main menu/side bar'));
		add(sidebar);

		buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

		backcredit = new FlxSprite(0, 0);
		backcredit.loadGraphic(Paths.image('main menu/backcredit'));
		backcredit.screenCenter(X);
		backcredit.y -= backcredit.height + 10;
		add(backcredit);

		creditsstuffu = new FlxTypedGroup<FlxSprite>();
		add(creditsstuffu);

		for(i in 0...3) {
			var button:FlxSprite = new FlxSprite(910, 3 + (i * 150));
			if(i == 2) {
				button.x = 1175;
				button.y = 615;
			}
			button.loadGraphic(Paths.image('main menu/' + stufflist[i] + ''));
			button.ID = i;
			buttons.add(button);
		}

		for(i in 0...3) {
			var creditnamethingidk:FlxSprite = new FlxSprite(0, 0);
			creditnamethingidk.loadGraphic(Paths.image('main menu/whiteninja'));
			creditnamethingidk.screenCenter(X);
			creditnamethingidk.y -= creditnamethingidk.height - 10;
			creditnamethingidk.ID = i;
			creditsstuffu.add(creditnamethingidk);

			var name = '';
			switch(i) {
				case 0:
					name = 'whiteninja';
				case 1:
					name = 'hnation';
				case 2:
					name = 'cally';
			}

			creditnamethingidk.loadGraphic(Paths.image('main menu/' + name));

			if(i == 0) {
				creditnamethingidk.scale.set(0.85, 0.85);
				creditnamethingidk.color = 0xFFAAAAAA;
			}
		}

		changeItem();
		changecredit();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		floatstuff += FlxG.random.float(0.05, 0.15) / 4;
		floatstuff2 += FlxG.random.float(0.1, 0.2) / 4;
		logo.x += Math.sin(floatstuff);
		logo.y += Math.sin(floatstuff2);

		if (FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;

		if(credits) {
			if(controls.BACK) {
				FlxG.sound.play(Paths.sound('cancelMenu'));
				credits = false;
				buttons.forEach(function(spr:FlxSprite) {
					if(spr.ID == 3) {
						FlxTween.tween(spr, {x: 1175}, 0.7, {ease: FlxEase.quintInOut});
					} else {
						FlxTween.tween(spr, {x: 910}, 0.7, {ease: FlxEase.quintInOut});
					}
				});
				FlxTween.tween(sidebar, {x: 883.95}, 0.7, {ease: FlxEase.quintInOut});
				FlxTween.tween(logo, {x: 143.75}, 0.7, {ease: FlxEase.quintInOut});
				FlxTween.tween(logo, {"scale.x": 1, "scale.y": 1}, 0.7, {ease: FlxEase.quintInOut});

				FlxTween.tween(backcredit, {y: 0 - (backcredit.height + 10)}, 0.7, {ease: FlxEase.quintInOut});
				creditsstuffu.forEach(function(spr:FlxSprite) {
					FlxTween.tween(spr, {y: 0 - ((spr.ID * 125) + spr.height + 20)}, 0.7, {ease: FlxEase.quintInOut});
				});

				selectedSomethin = false;
			}

			if(controls.UI_UP_P) changecredit(-1);
			if(controls.UI_DOWN_P) changecredit(1);
			if(controls.ACCEPT) CoolUtil.browserLoad(creditstuff[curSelected3]);
		} else {
			if (!selectedSomethin) {
				if (controls.UI_UP_P) {
					changeItem(-1);
				}
		
				if (controls.UI_DOWN_P) {
					changeItem(1);
				}
		
				if (controls.ACCEPT) {
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));
		
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
		
					switch(curSelected) {
						case 0:
							startsong('joyride');
						case 1:
							buttons.forEach(function(spr:FlxSprite) {
								FlxTween.tween(spr, {x: FlxG.width + 10}, 0.7, {ease: FlxEase.quintInOut});
							});
							FlxTween.tween(sidebar, {x: FlxG.width + 10}, 0.7, {ease: FlxEase.quintInOut});
							FlxTween.tween(logo, {x: (FlxG.width / 2) - (logo.width / 2)}, 0.7, {ease: FlxEase.quintInOut});
							FlxTween.tween(logo, {"scale.x": 0, "scale.y": 0}, 0.7, {ease: FlxEase.quintInOut});
							FlxTween.tween(backcredit, {y: (FlxG.height / 2) - (backcredit.height / 2)}, 0.7, {ease: FlxEase.quintInOut});
							creditsstuffu.forEach(function(spr:FlxSprite) {
								FlxTween.tween(spr, {y: ((FlxG.height / 2) - (spr.height * 1.5) - 15) + (spr.ID * 110)}, 0.7, {ease: FlxEase.quintInOut});
							});
							#if desktop
							DiscordClient.changePresence("In the Credit Menu", null);
							#end
							credits = true;
						case 2:
							LoadingState.loadAndSwitchState(new OptionsState());
					}
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if(huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (curSelected >= 3)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 2;

		buttons.forEach(function(spr:FlxSprite)
		{
			spr.color = 0xFFFFFFFF;
			spr.scale.set(1, 1);
			if(spr.ID == curSelected) {
				spr.scale.set(0.85, 0.85);
				spr.color = 0xFFAAAAAA;
			}
		});
	}

	function changecredit(addstuff:Int = 0) {
		if(addstuff != 0) FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected3 += addstuff;

		if (curSelected3 >= 3)
			curSelected3 = 0;
		if (curSelected3 < 0)
			curSelected3 = 2;

		creditsstuffu.forEach(function(spr:FlxSprite) {
			if(spr.ID == curSelected3) {
				spr.scale.set(0.85, 0.85);
				spr.color = 0xFFAAAAAA;
			} else {
				spr.color = 0xFFFFFFFF;
				spr.scale.set(1, 1);
			}
		});
	}

	function startsong(songnamestuff:String) {
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;
		FlxG.sound.play(Paths.sound('confirmMenu'));
		PlayState.SONG = Song.loadFromJson(songnamestuff, songnamestuff);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;
		LoadingState.loadAndSwitchState(new PlayState());
	}
}
