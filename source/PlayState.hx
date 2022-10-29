package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.util.FlxSave;
import StageData;
import Conductor.Rating;
#if sys
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState {
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], 
		['Shit', 0.4], 
		['Bad', 0.5], 
		['Bruh', 0.6], 
		['Meh', 0.69], 
		['Nice', 0.7], 
		['Good', 0.8], 
		['Great', 0.9], 
		['Sick!', 1], 
		['Perfect!!', 1] 
	];

	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var variables:Map<String, Dynamic> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	public var camFollow:FlxPoint;
	public var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = [];
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var thescoretext:FlxText;
	var theacctext:FlxText;
	var themisstext:FlxText;
	var scoreTxtTween:FlxTween;
	var thescoretextTween:FlxTween;
	var theacctextTween:FlxTween;
	var themisstextTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var instance:PlayState;
	public var introSoundsSuffix:String = '';

	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	private var keysArray:Array<Dynamic>;

	var precacheList:Map<String, String> = new Map<String, String>();

	var floatstuff = 0.0;
	var floatstuff2 = 0.0;
	var floatstuff3 = 0.0;
	var floatstuff4 = 0.0;

	var jjbackground:FlxSprite;
	var jjgrid:FlxSprite;
	var jjforeground:FlxSprite;

	public static var mechanictime = false;
	public static var touchingground = false;
	var justchangedmechanic = false;
	var flyingspeed = 50;
	var startdeath = false;
	var death = false;
	var death2 = false;
	var healthlerp = 1.0;
	var fakebfy = 0.0;
	var healthBarShadow:FlxSprite;
	var textsizething = 56;
	var lazersection = 0;
	var lazer:FlxSprite;
	var barrymustgo = 250.0;
	var camerapos = 0.0;
	var camx = 0.0;

	override public function create() {
		Paths.clearStoredMemory();

		instance = this;

		PauseSubState.songName = null;

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		ratingsData.push(new Rating('sick'));

		var rating:Rating = new Rating('good');
		rating.ratingMod = 0.7;
		rating.score = 200;
		ratingsData.push(rating);

		var rating:Rating = new Rating('bad');
		rating.ratingMod = 0.4;
		rating.score = 100;
		ratingsData.push(rating);

		var rating:Rating = new Rating('shit');
		rating.ratingMod = 0;
		rating.score = 50;
		ratingsData.push(rating);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		detailsText = '';
		detailsPausedText = "Paused";
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = SONG.stage;
		SONG.stage = curStage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) {
			stageData = {
				directory: "",
				defaultZoom: 0.9,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		mechanictime = false;
		touchingground = false;

		FlxG.camera.zoom += 0.9 - defaultCamZoom;

		switch (curStage) {
			case 'jjbg':
				jjbackground = new FlxSprite(-129, -259).loadGraphic(Paths.image('jetpack background'));
				add(jjbackground);

				jjgrid = new FlxSprite(-174, 311);
				jjgrid.frames = Paths.getSparrowAtlas('jetpack grid');
				jjgrid.animation.addByPrefix('grid', 'grid', 20);
				jjgrid.animation.play('grid');
				add(jjgrid);

				jjforeground = new FlxSprite(-225, -34);
				jjforeground.frames = Paths.getSparrowAtlas('jetpack foreground');
				jjforeground.animation.addByPrefix('foreground', 'foreground', 40);
				jjforeground.animation.play('foreground');
				add(jjforeground);
		}

		add(gfGroup);
		add(boyfriendGroup);
		add(dadGroup);

		var gfVersion:String = SONG.gfVersion;

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);

		boyfriend = new Boyfriend(0, 0, SONG.player1 + FlxG.save.data.characterskin);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);

		fakebfy = boyfriend.positionArray[1] + BF_Y;

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null) {
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null) gf.visible = false;
		}

		Conductor.songPosition = -1500;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		updateTime = false;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0;

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		if (OpenFlAssets.exists(file)) {
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData)
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						swagNote.tail.push(sustainNote);
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2;
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1)
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2;
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1)
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events)
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) {
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;

		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null) {
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection();

		lazer = new FlxSprite(4700, 0);
		lazer.frames = Paths.getSparrowAtlas('mechanicassets');
		lazer.animation.addByPrefix('lazer', 'lazer', 24);
		lazer.animation.play('lazer');
		lazer.scale.x = 1.5;
		lazer.scale.y = 1.5;
		add(lazer);
		
		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = (FlxG.height * 0.89) + 20;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthlerp = health;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'healthlerp', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		healthBar.numDivisions = 1600;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		healthBarShadow = new FlxSprite(healthBar.x, healthBar.y - (healthBar.height / 2));
		healthBarShadow.makeGraphic(Std.int(healthBar.width), Std.int(healthBar.height / 2), 0xFF000000);
		healthBarShadow.alpha = 1;
		add(healthBarShadow);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = false;
		add(scoreTxt);

		thescoretext = new FlxText(0, 0, FlxG.width, "Score 0", textsizething);
		thescoretext.setFormat(Paths.font("vcr.ttf"), textsizething, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		thescoretext.borderSize = textsizething / 16;
		thescoretext.y = 5 + (0 * (textsizething / 0.8));
		thescoretext.x = 5;
		thescoretext.color = 0xFFF8BF47;
		add(thescoretext);
		
		theacctext = new FlxText(0, 0, FlxG.width, "Accuracy", textsizething);
		theacctext.setFormat(Paths.font("vcr.ttf"), textsizething, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		theacctext.borderSize = textsizething / 16;
		theacctext.y = 5 + (1 * (textsizething / 0.8));
		theacctext.x = 5;
		theacctext.color = 0xFFF8BF47;
		add(theacctext);

		themisstext = new FlxText(0, 0, FlxG.width, "Misses 0", textsizething);
		themisstext.setFormat(Paths.font("vcr.ttf"), textsizething, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		themisstext.borderSize = textsizething / 16;
		themisstext.screenCenter(Y);
		themisstext.y = 5 + (2 * (textsizething / 0.8));
		themisstext.x = 5;
		themisstext.color = 0xFFF8BF47;
		add(themisstext);

		botplayTxt = new FlxText(400, 50, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
				
		var creditTxt = new FlxText(876, 648, 348);
     creditTxt.text = "PORTED BY\nFNF BR";
    creditTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
    creditTxt.scrollFactor.set();
    add(creditTxt);		
				
				
                if(ClientPrefs.downScroll) {
			creditTxt.y = 148;
		}
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		creditTxt.cameras = [camHUD];		
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		thescoretext.cameras = [camHUD];
		theacctext.cameras = [camHUD];
		themisstext.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		startingSong = true;

		#if android
                addAndroidControls();
	androidControls.visible = true;
                #end		
				
		var daSong:String = Paths.formatToSongPath(curSong);

		if(!startedCountdown) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
	
			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			var swagCounter:Int = 0;
	
	
			if(startOnTime < 0) startOnTime = 0;
	
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
			} else if (skipCountdown) {
				setSongTime(0);
			} else {
				startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
					if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) gf.dance();
					if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) boyfriend.dance();
					if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) dad.dance();
			
					var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
					introAssets.set('default', ['ready', 'set', 'go']);
			
					var introAlts:Array<String> = introAssets.get('default');
					var antialias:Bool = ClientPrefs.globalAntialiasing;
			
					notes.forEachAlive(function(note:Note) {
						if(ClientPrefs.opponentStrums || note.mustPress) {
							note.copyAlpha = false;
							note.alpha = note.multAlpha;
							if(ClientPrefs.middleScroll && !note.mustPress) {
								note.alpha *= 0;
							}
						}
					});
			
					swagCounter += 1;
				}, 5);
			}
		}

		mechanicthing(mechanictime);
		
		seenCutscene = true;
		RecalculateRating();

		if(ClientPrefs.hitsoundVolume > 0) precacheList.set('hitsound', 'sound');
		precacheList.set('missnote1', 'sound');
		precacheList.set('missnote2', 'sound');
		precacheList.set('missnote3', 'sound');
		precacheList.set('zap1', 'sound');
		precacheList.set('zap2', 'sound');
		precacheList.set('zap3', 'sound');
		precacheList.set('death1', 'sound');
		precacheList.set('death2', 'sound');
		precacheList.set('death3', 'sound');

		#if desktop
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;

		super.create();

		Paths.clearUnusedMemory();

		for (key => type in precacheList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'sound':
					Paths.sound(key);
				case 'music':
					Paths.music(key);
			}
		}
		CustomFadeTransition.nextCamera = camOther;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(50, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2;

		camerapos = dad.y + 300;
		camx = camFollowPos.x;
	}

	function set_songSpeed(value:Float):Float {
		if(generatedMusic) {
			var ratio:Float = value / songSpeed;
			for(note in notes) note.resizeByRatio(ratio);
			for(note in unspawnNotes) note.resizeByRatio(ratio);
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromInt(CoolUtil.dominantColor(iconP2)), FlxColor.fromInt(CoolUtil.dominantColor(iconP1)));
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
				}
			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
				}
			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
				}
		}
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) {
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	public function clearNotesBefore(time:Float) {
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time) {
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function updateScore(miss:Bool = false)
	{
		thescoretext.text = 'Score ' + songScore;
		theacctext.text = 'Accuracy ' + FlxMath.roundDecimal(ratingPercent * 100, 2);
		themisstext.text = 'Misses ' + songMisses;

		if(!miss && !cpuControlled)
		{
			if(thescoretextTween != null) {
				thescoretextTween.cancel();
			}
			thescoretext.scale.x = 1.075;
			thescoretext.scale.y = 1.075;
			thescoretext.x = 5;
			thescoretextTween = FlxTween.tween(thescoretext.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					thescoretextTween = null;
				}
			});
			if(theacctextTween != null) {
				theacctextTween.cancel();
			}
			theacctext.scale.x = 1.075;
			theacctext.scale.y = 1.075;
			theacctext.x = 5;
			theacctextTween = FlxTween.tween(theacctext.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					theacctextTween = null;
				}
			});
			if(themisstextTween != null) {
				themisstextTween.cancel();
			}
			themisstext.scale.x = 1.075;
			themisstext.scale.y = 1.075;
			themisstext.x = 5;
			themisstextTween = FlxTween.tween(themisstext.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					themisstextTween = null;
				}
			});
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
		}
		vocals.play();
		Conductor.songPosition = time;
		songTime = time;
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			FlxG.sound.music.pause();
			vocals.pause();
		}

		songLength = FlxG.sound.music.length;

		#if desktop
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		switch(event.event) {
			case 'Kill Henchmen':
				return 280;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			if(player == 1)
				playerStrums.add(babyArrow);
			else {
				babyArrow.x = -2000;
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			paused = false;

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void {
		#if desktop
		if (health > 0 && !paused) {
			if (Conductor.songPosition > 0.0) {
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			} else {
				DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter());
			}
		}
		#end
		super.onFocus();
	}

	override public function onFocusLost():Void {
		#if desktop
		if (health > 0 && !paused) {
			DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		}
		#end
		super.onFocusLost();
	}

	public var skipArrowStartTween:Bool = false;

	function resyncVocals():Void {
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length) {
			vocals.time = Conductor.songPosition;
		}
		vocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	override public function update(elapsed:Float) {
		floatstuff += FlxG.random.float(0.075, 0.2);
		floatstuff2 += FlxG.random.float(0.075, 0.2);
		floatstuff3 += FlxG.random.float(0.075, 0.2);
		floatstuff4 += FlxG.random.float(0.075, 0.2);
		dad.x += Math.sin(floatstuff3) / 2;
		dad.y += Math.sin(floatstuff4) * 2;

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 4, 0, 0.5);

		boyfriend.y = FlxMath.lerp(boyfriend.y, fakebfy, lerpVal);
		dad.y = FlxMath.lerp(dad.y, barrymustgo, lerpVal);

		if(!isDead) {
			checksection();
		}

		moveCameraSection();

		if(startdeath) {
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, lerpVal);
			camFollowPos.x = FlxMath.lerp(camFollowPos.x, 2100, lerpVal);
			camFollowPos.y = FlxMath.lerp(camFollowPos.y, 1000, lerpVal);
		} else {
			if(fakebfy >= 1425) fakebfy = 1425;
			if(fakebfy <= 190) fakebfy = 190;
			if(mechanictime) {
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, lerpVal);
				camFollowPos.x = FlxMath.lerp(camFollowPos.x, 2100, lerpVal);
				camFollowPos.y = FlxMath.lerp(camFollowPos.y, 1000, lerpVal);

				fakebfy += flyingspeed;

				if(boyfriend.y >= 1380)
					touchingground = true;
				else
					touchingground = false;
				
				#if android
				if (FlxG.mouse.pressed) fakebfy += -(flyingspeed * 3);
				#else
				if(FlxG.keys.pressed.ANY) fakebfy += -(flyingspeed * 3);
				#end

				if(!touchingground) {
					boyfriend.x += Math.sin(floatstuff) / 2;
					fakebfy += Math.sin(floatstuff2) * 2;
				}
				
				boyfriend.dance();
			} else {
				camerapos = dad.y + 300;
				if(camerapos < 525) camerapos = 525;
				if(camerapos > 1600) camerapos = 1600;
				camFollowPos.x = FlxMath.lerp(camFollowPos.x, camx, lerpVal);
				camFollowPos.y = FlxMath.lerp(camFollowPos.y, camerapos, lerpVal);
				FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, 0.9, lerpVal);
				fakebfy = FlxMath.lerp(fakebfy, dad.y - 50, lerpVal);
				boyfriend.x += Math.sin(floatstuff) / 2;
				fakebfy += Math.sin(floatstuff2) * 2;
				camFollow.x += Math.sin(floatstuff3) / 2;
				camFollow.y += Math.sin(floatstuff4) * 2;
				camFollow.x += Math.sin(floatstuff) / 2;
				camFollow.y += Math.sin(floatstuff2) * 2;
			}
		}

		if(FlxCollision.pixelPerfectCheck(boyfriend, lazer, 1) && !startdeath && mechanictime) {
			FlxG.sound.play(Paths.sound('zap' + FlxG.random.int(1, 3)));
			startdeath = true;
		}

		if(startdeath) {
			lazer.x -= 30;
			if(fakebfy < 1000) {
				fakebfy += 25;
			} else {
				fakebfy += 10;
			}
			vocals.stop();
			FlxG.sound.music.stop();
			boyfriend.angle += (40 + FlxG.random.float(-20, 20)) / 2;
			if(!death) {
				boyfriend.playAnim('death1', true);
				boyfriend.updateHitbox();
				if(fakebfy >= 1550) {
					fakebfy = 1545;
					fakebfy -= 150;
					new FlxTimer().start(elapsed * 1.5, function(tmr:FlxTimer) {
						fakebfy -= 400;
					}, 1);
					FlxG.sound.play(Paths.sound('death1'));
					death = true;
				}
			} else if(!death2 && fakebfy >= 1550) {
				fakebfy = 1545;
				fakebfy -= 75;
				new FlxTimer().start(elapsed * 1.5, function(tmr:FlxTimer) {
					fakebfy -= 200;
				}, 1);
				boyfriend.playAnim('death2', true);
				boyfriend.updateHitbox();
				FlxG.sound.play(Paths.sound('death2'));
				death2 = true;
			} else if(fakebfy >= 1550) {
				FlxG.sound.play(Paths.sound('death3'));
				fakebfy = 1550;
				boyfriend.stunned = true;
				deathCounter++;
				paused = true;
				persistentUpdate = false;
				persistentDraw = false;
				#if desktop
				DiscordClient.changePresence("Game Over" + detailsText, SONG.song, iconP2.getCharacter());
				#end
				isDead = true;
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));
			}
		}

		if(curBeat > 6) {
			lazer.x -= 30;
		}

		super.update(elapsed);

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause && !startdeath)
		{
			openPauseMenu();
		}

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		healthlerp = FlxMath.lerp(healthlerp, health, CoolUtil.boundTo(elapsed * 6, 0, 0.5));
		iconP1.x = FlxMath.lerp(iconP1.x, healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26, CoolUtil.boundTo(elapsed * 6, 0, 0.5));
		iconP2.x = FlxMath.lerp(iconP2.x, healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2, CoolUtil.boundTo(elapsed * 6, 0, 0.5));

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;
				}
			}
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (!ClientPrefs.noReset && controls.RESET && canReset && startedCountdown && !endingSong)
		{
			health = 0;
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned=true;

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll)
				{
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}
				else
				{
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed * daNote.multSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							daNote.y -= 19;
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) {
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		if(FlxCollision.pixelPerfectCheck(boyfriend, lazer, 1) && !startdeath && mechanictime) {
			FlxG.sound.play(Paths.sound('zap' + FlxG.random.int(1, 3)));
			mechanicthing(false, true);
			startdeath = true;
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.pause();
			vocals.volume = 0;
			vocals.pause();
		}
	}

	function openPauseMenu()
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
		}
		FlxG.sound.play(Paths.sound('Pause'));
		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if desktop
		DiscordClient.changePresence(detailsPausedText, SONG.song, iconP2.getCharacter());
		#end
	}

	public var isDead:Bool = false;
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead) {
			mechanicthing(false, true);
			FlxG.sound.music.volume = 0;
			FlxG.sound.music.pause();
			vocals.volume = 0;
			vocals.pause();
			isDead = true;
			return true;
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) {
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}
			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;
			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35 && !mechanictime) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;
				}
			case 'Play Animation':
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}
		}
	}

	function moveCameraSection():Void {
		if(SONG.notes[curSection] == null) return;

		if (gf != null && SONG.notes[curSection].gfSection) {
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			return;
		}

		if(justchangedmechanic) {
			justchangedmechanic = false;
			return;
		} else if(!mechanictime) {
			if(!SONG.notes[curSection].mustHitSection) {
				camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
				camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			} else {
				camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
				camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
			}
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	private function onSongComplete()
	{
		finishSong(false);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong;

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}
			if(doDeathCheck()) return;
		}

		canPause = false;
		endingSong = true;
		camZooming = false;
		updateTime = false;
		deathCounter = 0;
		seenCutscene = false;

		if(!transitioning) {
			if (SONG.validScore) {
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				#end
			}

			if (chartingMode) return;

			cancelMusicFadeTween();
			if(FlxTransitionableState.skipNextTransIn) {
				CustomFadeTransition.nextCamera = null;
			}
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			changedDifficulty = false;
			transitioning = true;
		}
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;
	public var showCombo:Bool = false;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	private function onKeyPress(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if (!cpuControlled && startedCountdown && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode)) {
			if(!boyfriend.stunned && generatedMusic && !endingSong) {
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				var pressNotes:Array<Note> = [];
				var notesStopped:Bool = false;
				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note) {
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote) {
						if(daNote.noteData == key) {
							sortedNotesList.push(daNote);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList) {
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}
					}
				}
				else{
					if (canMiss) {
						noteMissPress(key);
					}
				}
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
		}
	}

	function sortHitNotes(a:Note, b:Note):Int {
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void {
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && startedCountdown && !paused && key > -1) {
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null) {
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int {
		if(key != NONE) {
			for (i in 0...keysArray.length) {
				for (j in 0...keysArray[i].length) {
					if(key == keysArray[i][j]) {
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keyShit():Void {
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		if(ClientPrefs.controllerMode) {
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true)) {
				for (i in 0...controlArray.length) {
					if(controlArray[i]) onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}
		if (startedCountdown && !boyfriend.stunned && generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (boyfriend.holdTimer > Conductor.stepCrochet * 0.0011 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		if(ClientPrefs.controllerMode) {
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true)) {
				for (i in 0...controlArray.length) {
					if(controlArray[i]) onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void {
		if(isDead) return;
		if(mechanictime) return;

		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		health -= daNote.missHealth * healthLoss;
		
		if(instakillOnMiss) {
			vocals.volume = 0;
			doDeathCheck(true);
		}

		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating(true);

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.25));

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && !daNote.noMissAnimation && char.hasMissAnimations) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daNote.animSuffix;
			char.playAnim(animToPlay, true);
		}
	}

	function noteMissPress(direction:Int = 1):Void {
		if(isDead) return;
		if(ClientPrefs.ghostTapping) return;
		if(mechanictime) return;

		if(!boyfriend.stunned) {
			health -= 0.05 * healthLoss;
			if(instakillOnMiss) {
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad')) {
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating(true);

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.25));

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void {
		camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null) {
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection) {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}
			if(char != null) {
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices) vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;

		if (!note.isSustainNote) {
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void {
		if(isDead) return;
		if (!note.wasGoodHit) {
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled) {
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}
			if(note.hitCausesMiss) {
				noteMiss(note);
				note.wasGoodHit = true;
				if (!note.isSustainNote) {
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}
			if (!note.isSustainNote) {
				combo += 1;
				if(combo > 9999) combo = 9999;
				var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);

				vocals.volume = 1;
		
				var placement:String = Std.string(combo);
		
				var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
				coolText.screenCenter();
				coolText.x = FlxG.width * 0.35;
		
				var rating:FlxSprite = new FlxSprite();
				var score:Int = 350;
		
				var daRating:Rating = Conductor.judgeNote(note, noteDiff);
		
				totalNotesHit += daRating.ratingMod;
				note.ratingMod = daRating.ratingMod;
				if(!note.ratingDisabled) daRating.increase();
				note.rating = daRating.name;
				score = daRating.score;
		
				if(!practiceMode && !cpuControlled) {
					songScore += score;
					if(!note.ratingDisabled)
					{
						songHits++;
						totalPlayed++;
						RecalculateRating(false);
					}
				}
		
				rating.loadGraphic(Paths.image(daRating.image));
				if(daRating.image == 'shit') {
					rating.frames = Paths.getSparrowAtlas('ratings');
					rating.animation.addByPrefix('terrible', 'terrible', 24);
					rating.animation.play('terrible');
				} else {
					rating.frames = Paths.getSparrowAtlas('ratings');
					rating.animation.addByPrefix(daRating.image + '', daRating.image + '', 24);
					rating.animation.play(daRating.image + '');
				}
				rating.cameras = [camHUD];
				rating.screenCenter();
				rating.x = coolText.x - 40;
				rating.y -= 60;
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);
				rating.visible = (!ClientPrefs.hideHud && showRating);
				rating.x += ClientPrefs.comboOffset[0];
				rating.y -= ClientPrefs.comboOffset[1];
		
				insert(members.indexOf(strumLineNotes), rating);
		
				rating.updateHitbox();
				if(daRating.image == 'sick') {
					rating.setGraphicSize(Std.int(rating.width / 1.5));
				}
		
				var seperatedScore:Array<Int> = [];
		
				if(combo >= 1000) {
					seperatedScore.push(Math.floor(combo / 1000) % 10);
				}
				seperatedScore.push(Math.floor(combo / 100) % 10);
				seperatedScore.push(Math.floor(combo / 10) % 10);
				seperatedScore.push(combo % 10);
		
				var daLoop:Int = 0;
				var xThing:Float = 0;
				for (i in seperatedScore) {
					var numScore:FlxSprite = new FlxSprite();
					numScore.frames = Paths.getSparrowAtlas('ratings');
					numScore.animation.addByPrefix('num' + Std.int(i), 'num' + Std.int(i), 24);
					numScore.animation.play('num' + Std.int(i));
					numScore.cameras = [camHUD];
					numScore.screenCenter();
					numScore.x = coolText.x + (43 * daLoop) - 90;
					numScore.y += 80;
					numScore.x += ClientPrefs.comboOffset[2];
					numScore.y -= ClientPrefs.comboOffset[3];
					numScore.updateHitbox();
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					if(i == 1) {
						numScore.x += 20;
					}
		
					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);
					numScore.visible = !ClientPrefs.hideHud;
		
					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							numScore.destroy();
						},
						startDelay: Conductor.crochet * 0.002
					});
					daLoop++;
					if(numScore.x > xThing) xThing = numScore.x;
				}
		
				coolText.text = Std.string(seperatedScore);
		
				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});
		
				new FlxTimer().start(0.2 + (Conductor.crochet * 0.002), function(tmr:FlxTimer) {
					coolText.destroy();
					rating.destroy();
				});
			}
			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote) {
					if(gf != null) {
						gf.playAnim(animToPlay + note.animSuffix, true);
						gf.holdTimer = 0;
					}
				} else {
					boyfriend.playAnim(animToPlay + note.animSuffix, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote) {
					if (Math.abs(note.noteData) == spr.ID) {
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote;
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			if (!note.isSustainNote) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	override function destroy() {
		if(!ClientPrefs.controllerMode) {
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	var lastStepHit:Int = -1;
	override function stepHit() {
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20 || (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20)) {
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
	}

	var lastBeatHit:Int = -1;

	override function beatHit() {
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			return;
		}

		if (generatedMusic) {
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if(curBeat > 4 && (curBeat / 4) % 2 == 0) {
			lazerthing(FlxG.random.int(1, 9));
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && gf.animation.curAnim != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned) {
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned) {
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned) {
			dad.dance();
		}

		lastBeatHit = curBeat;
	}

	override function sectionHit() {
		super.sectionHit();

		if (SONG.notes[curSection] != null) {
			if (SONG.notes[curSection].changeBPM) Conductor.changeBPM(SONG.notes[curSection].bpm);
		}
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;

		if(isDad)
			spr = strumLineNotes.members[id];
		else
			spr = playerStrums.members[id];

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;

	public function RecalculateRating(badHit:Bool = false) {
		updateScore(badHit);

		if(totalPlayed < 1)
			ratingName = '100';
		else {
			ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));

			if(ratingPercent >= 1)
				ratingName = ratingStuff[ratingStuff.length-1][0];
			else {
				for (i in 0...ratingStuff.length-1) {
					if(ratingPercent < ratingStuff[i][1]) {
						ratingName = ratingStuff[i][0];
						break;
					}
				}
			}
		}
	}

	var curLight:Int = -1;
	var curLightEvent:Int = -1;

	function mechanicthing(active:Bool, gameover:Bool = false) {
		if(gameover) {
			FlxTween.tween(healthBarBG, {alpha: 0}, 1);
			FlxTween.tween(healthBar, {alpha: 0}, 1);
			FlxTween.tween(healthBarShadow, {alpha: 0}, 1);
			FlxTween.tween(iconP1, {alpha: 0}, 1);
			FlxTween.tween(iconP2, {alpha: 0}, 1);
			FlxTween.tween(thescoretext, {alpha: 0}, 1);
			FlxTween.tween(theacctext, {alpha: 0}, 1);
			FlxTween.tween(themisstext, {alpha: 0}, 1);
			strumLineNotes.forEach(function(babyArrow:StrumNote) {
				FlxTween.tween(babyArrow, {alpha: 0}, 1);
			});
			startdeath = true;
		} else {
			if(active != mechanictime) {
				if(active) {
					FlxTween.tween(healthBarBG, {alpha: 0}, 1);
					FlxTween.tween(healthBar, {alpha: 0}, 1);
					FlxTween.tween(healthBarShadow, {alpha: 0}, 1);
					FlxTween.tween(iconP1, {alpha: 0}, 1);
					FlxTween.tween(iconP2, {alpha: 0}, 1);
					strumLineNotes.forEach(function(babyArrow:StrumNote) {
						FlxTween.tween(babyArrow, {alpha: 0}, 1);
					});
				} else {
					if(!SONG.notes[curSection].mustHitSection) {
						camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
						camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
						camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
					} else {
						camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
						camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
						camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
					}
					FlxTween.tween(healthBarBG, {alpha: 1}, 0.5);
					FlxTween.tween(healthBar, {alpha: 1}, 0.5);
					FlxTween.tween(healthBarShadow, {alpha: 1}, 0.5);
					FlxTween.tween(iconP1, {alpha: 1}, 0.5);
					FlxTween.tween(iconP2, {alpha: 1}, 0.5);
					strumLineNotes.forEach(function(babyArrow:StrumNote) {
						FlxTween.tween(babyArrow, {alpha: 1}, 0.5);
					});
					if(boyfriend.animation.curAnim.name == 'running' || boyfriend.animation.curAnim.name == 'idle2') {
						boyfriend.dance();
					}
				}
			}
		}

		mechanictime = active;
		justchangedmechanic = true;
	}

	function lazerthing(section:Int) {
		lazersection = section;
		lazer.x = 4700;
	
		if(fakebfy >= 1450) fakebfy = 1450;
	
		if(section > 6) {
			lazer.y = 250;
			barrymustgo = FlxG.random.float(700, 900);
		} else if(section > 3) {
			lazer.y = 850;
			barrymustgo = FlxG.random.float(75, 100);
		} else if(section > 0) {
			lazer.y = 1315;
			barrymustgo = FlxG.random.float(250, 450);
		}
	
		if(section == 1 || section == 4 || section == 7) {
			lazer.angle = 0;
			addlazerpos(50);
		} else if(section == 2 || section == 5 || section == 8) {
			lazer.angle = -45;
			addlazerpos(100);
		} else if(section == 3 || section == 6 || section == 9) {
			lazer.angle = -90;
			addlazerpos(175);
		}

		if(section == 1) {
			addlazerpos(400);
		}

		lazer.updateHitbox();
	}

	function addlazerpos(add:Float) {
		lazer.y += add;
		barrymustgo += add;
	}

	function checksection() {
		//remove 10 from the number if bf is gonna sing

		if(curStep > 275 && curStep < 325)
			mechanicthing(true);
		else if(curStep > 405 && curStep < 455)
			mechanicthing(true);
		else if(curStep > 530 && curStep < 645)
			mechanicthing(true);
		else if(curStep > 785 && curStep < 855)
			mechanicthing(true);
		else if(curStep > 930 && curStep < 980)
			mechanicthing(true);
		else if(curStep > 1060)
			mechanicthing(true);
		else
			mechanicthing(false);
	}
}
