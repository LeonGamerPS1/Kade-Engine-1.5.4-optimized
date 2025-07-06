package;

import flixel.addons.sound.FlxRhythmConductor;

class Sustain extends Tile
{
	public var parent:Note;

	public function new(parent:Note)
	{
		super(-3000, 0);
		this.parent = parent;
		if (parent != null)
			parent.sustain = this;

		if (parent != null)
			init(parent);
	}

	public function init(parent:Note):Sustain
	{
		this.parent = parent;
		parent.sustain = this;

		normal();
		return this;
	}

	inline function normal()
	{
		frames = parent.frames;
		animation.copyFrom(parent.animation);

		animation.play('hold');
		setTail('end');
		updateHitbox();

		visible = true;
		scale.set(parent.scale.x, parent.scale.y);
		updateHitbox();

		antialiasing = parent.antialiasing;
	}

	override function update(elapsed:Float)
	{
		if (parent != null)
		{
			var length:Float = parent.sustainLength;

			if (parent.wasGoodHit)
				length -= Math.abs(parent.strumTime - FlxRhythmConductor.instance.musicPosition);

			var expectedHeight:Float = (length * 0.45 * parent.speed) + tailHeight();

			if (height != expectedHeight)
				this.height = Math.max(expectedHeight, 0);
			shader = parent.shader;

			if (alpha != parent.alpha * 0.7)
				alpha = parent.alpha * 0.7;

			regenPos();
		}

		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();

		if (parent.wasGoodHit)
			parent.setPosition(parent.strumline.strums.members[parent.noteData].x, parent.strumline.strums.members[parent.noteData].y);
		regenPos();
	}

	override function kill():Void
	{
		super.kill();
	}

	public inline function regenPos()
	{
		if (parent == null)
			return;

		setPosition(parent.x + ((parent.width - width) * 0.5), parent.y + (parent.height * 0.5));

		var calcAngle:Float = 0;
		calcAngle += parent.sustainAngle - 90;
		@:privateAccess
		if (parent.strumline.strums.members[parent.noteData].downScroll)
		{
			angle = calcAngle + 180;
			y -= 30;
		}
		else
			angle = calcAngle;
	}
}
