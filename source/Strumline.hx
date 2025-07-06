package;

import flixel.addons.sound.FlxRhythmConductor;
import flixel.util.FlxSort;
import flixel.group.FlxGroup;

class Strumline extends FlxGroup
{
	public var cpu:Bool = true;
	public var unspawnNotes:Array<Array<Dynamic>> = [];

	public var strums:FlxTypedGroup<Strum>;
	public var notes:FlxTypedGroup<Note>;
	public var sustains:FlxTypedGroup<Sustain>;
	public var downScroll = false;
	public var speed:Float = 12;

	public function new(x:Float = 0, y:Float = 0, ?downScroll:Bool = false)
	{
		super();
		this.downScroll = downScroll;

		sustains = new FlxTypedGroup<Sustain>();
		add(sustains);

		strums = new FlxTypedGroup<Strum>();
		add(strums);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		gen(x, y);
	}

	function gen(x, y)
	{
		for (i in 0...4)
		{
			var strum:Strum = new Strum(i);
			strum.downScroll = downScroll;
			strum.y = y;
			strum.x = x + (Note.swagWidth * i);
			strum.animation.onFinish.add((_) ->
			{
				if (cpu)
					strum.playAnim('static', true);
			});
			strums.add(strum);
		}
	}

	inline public static function sortNotesByTimeHelper(Order:Int, Obj1:Note, Obj2:Note)
		return FlxSort.byValues(Order, Obj1.strumTime, Obj2.strumTime);

	override function update(elapsed:Float)
	{
		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;
			if (speed < 1)
				time /= speed;

			if (unspawnNotes.length > 0 && unspawnNotes[0][0] - FlxRhythmConductor.instance.musicPosition < time)
			{
				var dunceNote:Note = notes.recycle(Note)
					.redo(unspawnNotes[0], cpu, strums.members[Math.floor(unspawnNotes[0][1]) % strums.members.length].skin);
				notes.add(dunceNote);
				dunceNote.mustPress = cpu;
				dunceNote.strumline = this;
				dunceNote.y = 98903840834;

				if (dunceNote.sustainLength > 3)
				{
					var sustain:Sustain = sustains.recycle(Sustain).init(dunceNote);
					sustain.x = -55555555;
					sustain.revive();
					sustain.parent = dunceNote;
				}

				unspawnNotes.remove(unspawnNotes[0]);
			}
		}

		notes.sort(sortNotesByTimeHelper, FlxSort.DESCENDING);

		super.update(elapsed);

		notes.forEachAlive(function(n)
		{
			var strum = strums.members[n.noteData % 4];
			n.x = strum.x;
			n.y = strum.y + (n.strumTime - FlxRhythmConductor.instance.musicPosition) * (0.45 * speed * (!strum.downScroll ? 1 : -1)) + 0;
			n.speed = speed;
			n.strumline = this;

			if(n.sustain != null && !n.wasGoodHit)
			{
				n.sustain.regenPos();
			}
			if (cpu && n.strumTime <= FlxRhythmConductor.instance.musicPosition)
			{
				strum.playAnim('confirm', !n.wasGoodHit);
				n.wasGoodHit = true;
			}

			if (n.wasGoodHit && n.strumTime + n.sustainLength <= FlxRhythmConductor.instance.musicPosition)
			{
				if (n.sustainLength > 0)
					strum.playAnim(!cpu ? 'pressed' : 'static', true);
				invalNote(n);
			}

			if (!n.wasGoodHit
				&& n.strumTime + n.sustainLength <= FlxRhythmConductor.instance.musicPosition - (350 / speed)
				&& !n.wasGoodHit)
			{
				invalNote(n);
			}
		});
	}

	public function invalNote(n:Note)
	{
		n.kill();
		if (n.sustain != null)
		{
			sustains.remove(n.sustain, true);
			n.sustain.destroy();
			n.sustain = null;
		}
	}
}
