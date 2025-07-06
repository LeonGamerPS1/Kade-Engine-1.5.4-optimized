package;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.addons.sound.MusicTimeChangeEvent;
import flixel.addons.sound.FlxRhythmConductor;
import flixel.FlxG;
import flixel.sound.FlxSound;
import Song;

class PlayState extends flixel.FlxState
{
	public static var offsetTesting:Bool = false;
	public static var daPixelZoom:Int = 6;

	public static var storyWeek:Int = 0;
	public static var storyDifficulty:Int = 0;
	public static var curStage:String = "stage";

	public static var SONG:SwagSong;
	public static var storyPlaylist:Array<String> = [];
	public static var campaignScore:Float = 0;
	public static var campaignMisses:Float = 0;

	public static var sicks:Int = 0;
	public static var goods:Int = 0;
	public static var bads:Int = 0;
	public static var shits:Int = 0;

	public static var isStoryMode = false;

	public var inst:FlxSound;
	public var vocals:FlxSound;

	var time:Float = 0;
	var startedCountdown:Bool = false;
	var startedSong = false;

	public var ui:FlxGroup = new FlxGroup();
	public var camH:FlxCamera;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var opponentStrums:Strumline;
	public var playerStrums:Strumline;

	override function create()
	{
		FlxG.sound.music.stop();

		SONG ??= Song.loadFromJson('tutorial', 'tutorial');
		inst = FlxG.sound.load(Paths.inst(SONG.song));
		vocals = FlxG.sound.load(Paths.voices(SONG.song));
		FlxRhythmConductor.reset();
		FlxRhythmConductor.instance.setupTimeChanges([new MusicTimeChangeEvent(0, SONG.bpm, 4, 4, 0.01)]);
		FlxRhythmConductor.instance.target = inst;
		time = -FlxRhythmConductor.instance.beatLengthMs * 5;

		FlxRhythmConductor.instance.onBeatHit.add(beat);
		FlxRhythmConductor.instance.onStepHit.add(step);
		FlxRhythmConductor.instance.onMeasureHit.add(section);

		camH = new FlxCamera();
		camH.bgColor.alpha = 0;
		FlxG.cameras.add(camH, false);
		ui.cameras = [camH];
		add(ui);

		opponentStrums = new Strumline(50, FlxG.save.data.downscroll ? FlxG.height - 150 : 50, FlxG.save.data.downscroll);
		opponentStrums.speed = SONG.speed;
		add(opponentStrums);

		playerStrums = new Strumline(50 + FlxG.width / 2 + 50, FlxG.save.data.downscroll ? FlxG.height - 150 : 50, opponentStrums.downScroll);
				playerStrums.speed = SONG.speed;
		add(playerStrums);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.screenCenter(Y);
		iconP1.x = FlxG.width - 150;
		ui.add(iconP1);

		iconP2 = new HealthIcon(SONG.player2);
		iconP2.screenCenter(Y);
		iconP2.x = 0;
		ui.add(iconP2);

		var info = makeText(SONG.song + ' - ${getDiff(storyDifficulty)} | KE 1.5.4 PS Rewrite v0.1.0', 14);
		info.setPosition(0, FlxG.height - 17);
		ui.add(info);
		startCB();
	}

	static public function getDiff(storyDifficulty:Int)
	{
		return switch (storyDifficulty)
		{
			default:
				"Easy";
			case 1:
				"Normal";
			case 2:
				"Hard";
		}
	}

	public dynamic function startCB()
	{
		startCountdown();
	}

	function startCountdown()
	{
		for (section in SONG.notes)
		{
			for (note in section.sectionNotes)
			{
				var goodhit = section.mustHitSection;
				if (note[1] > 3)
					goodhit = !section.mustHitSection;
				var strumline = !goodhit ? opponentStrums : playerStrums;
				strumline.unspawnNotes.push(note);
				strumline.speed = SONG.speed;
			}
		}

		sorS(playerStrums);
		sorS(opponentStrums);
		startedCountdown = true;
	}

	static function sorS(s:Strumline)
	{
		s.unspawnNotes.sort(function(_, __)
		{
			return Math.floor(_[0] - __[0]);
		});
	}

	override function update(elapsed:Float)
	{
		var m:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 8));
		iconP1.scale.set(m, m);
		iconP1.updateHitbox();

		var m:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 8));
		iconP2.scale.set(m, m);
		iconP2.updateHitbox();

		if (startedSong)
		{
			time = inst.time;
			if (Math.abs(inst.time - vocals.time) > 10 && vocals.playing)
				vocals.time = inst.time;
		}
		else if (startedCountdown && !startedSong)
		{
			time += elapsed * 1000;
			if (time >= 0)
			{
				startSong();
			}
		}

		FlxRhythmConductor.instance.update(time);
		super.update(elapsed);
	}

	function startSong()
	{
		startedSong = true;
		inst.play();
		vocals.play();
	}

	static function makeText(txet:String = "", ?size:Int = 10):FlxText
	{
		var txt = new FlxText(0, 0);
		txt.setFormat(Paths.font('vcr.ttf'), size, FlxColor.WHITE, LEFT, OUTLINE_FAST, FlxColor.BLACK, true);
		txt.text = txet;
		return txt;
	}

	public function beat(v:Int)
	{
		iconP1.scale.set(1.2, 1.2);
		iconP1.updateHitbox();

		iconP2.scale.set(1.2, 1.2);
		iconP2.updateHitbox();
	}

	public function step(v:Int)
	{
	}

	public function section(v:Int)
	{
	}
}
