package;

import flixel.math.FlxRect;
import flixel.math.FlxMatrix;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end
import PlayState;

using StringTools;

@:publicFields
class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";
	public var skin:String;
	public var speed:Float = 1;
	public var sustainAngle(default, null):Float = 90;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		if (inCharter)
			this.strumTime = strumTime;
		else
			this.strumTime = Math.round(strumTime);

		if (this.strumTime < 0)
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		skin = "NOTE_assets";
		reload();
	}

	public static var col:Array<String> = ['purple', 'blue', 'green', 'red'];

	function reload()
	{
		frames = Paths.getSparrowAtlas(skin, 'shared');
		animation.addByPrefix('arrow', col[noteData % 4] + '0', 24, true);
		animation.addByPrefix('hold', col[noteData % 4] + ' hold piece0', 24, true);
		animation.addByPrefix('end', col[noteData % 4] + ' hold end0', 24, true);
		playAnim('arrow');
		updateHitbox();
		antialiasing = true;

		scale.set(0.7, 0.7);
		updateHitbox();
	}

	public function playAnim(_:String, f:Bool = false)
	{
		animation.play(_, f);
		centerOffsets();
		centerOrigin();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// ass
			if (isSustainNote)
			{
				if (strumTime > FlxRhythmConductor.instance.musicPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < FlxRhythmConductor.instance.musicPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > FlxRhythmConductor.instance.musicPosition - Conductor.safeZoneOffset
					&& strumTime < FlxRhythmConductor.instance.musicPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

			if (strumTime < FlxRhythmConductor.instance.musicPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= FlxRhythmConductor.instance.musicPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
		
	}

	public function clipSustain(receptor:Strum):Void
	{
		var receptorCenter:Float = receptor.y + (receptor.height * 0.5);

		if (sustain.clipRegion == null)
			sustain.clipRegion = FlxRect.get(0, 0, sustain.width, sustain.height);

		sustain.clipRegion.y = receptorCenter - sustain.y;

		//if (receptor.downScroll)
		//	sustain.clipRegion.y = sustain.height - sustain.clipRegion.y;
	}

	public function redo(arg:Array<Dynamic>, mp:Bool = false, skin:String = "NOTE_assets")
	{
		wasGoodHit = false;
		mustPress = mp;
		alpha = 1;
		prevNote = null;
		tooLate = false;
		mustPress = mp;
		noteData = Std.int(arg[1] % 4);
		canBeHit = false;
		tooLate = false;
		wasGoodHit = false;
		prevNote = null;
		modifiedByLua = false;
		sustainLength = 0;
		isSustainNote = false;
		strumTime = arg[0];
		sustainLength = arg[2] is Float ? arg[2] : 0;

		reload();

		return this;
	}

	public var sustain:Sustain;

	var strumline:Strumline;

	override function draw()
	{
		if (!wasGoodHit)
			super.draw();
	}
}
