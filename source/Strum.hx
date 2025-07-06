package;

import flixel.FlxSprite;

class Strum extends FlxSprite
{
	public var id:Int = 0;
	public var skin:String;
	public var downScroll:Bool = false;

	public function new(id:Int = 0)
	{
		super();
		this.id = id;
		skin = "NOTE_assets";

		reload();
	}

	public static var dirs = ['left', 'down', 'up', 'right'];

	public function reload()
	{
		var dir:String = dirs[id];
		frames = Paths.getSparrowAtlas(skin, 'shared');
		animation.addByPrefix('static', 'arrow${dir.toUpperCase()}', 24, false);
		animation.addByPrefix('confirm', '$dir confirm', 24, false);
		animation.addByPrefix('pressed', '$dir press', 24, false);

        playAnim('static');
        updateHitbox();

        scale.set(0.7,0.7);
        antialiasing = true;
        updateHitbox();
	}

	public function playAnim(a:String, ?f:Bool = false)
	{
		animation.play(a, f);
		centerOffsets();
		centerOrigin();
	}
}
