package en;

class Letter extends Entity {
	public static var ALL : FixedArray<Letter> = new FixedArray(50);
	static var recents : Map<Int, Float> = new Map();

	var tf : h2d.Text;
	public var letterIdx : Int;
	public var done = false;
	var color : Col;
	var ds = 0.;
	var floatOff = R.fullCircle();

	public function new(letterIdx:Int) {
		super(0,0);
		ALL.push(this);

		this.letterIdx = letterIdx;
		recents.set(letterIdx, haxe.Timer.stamp());

		spr.set(D.tiles.empty);
		color = Col.randomHSL(R.zto(), R.around(0.7,20), 1);
		spr.rotation = rnd(0,0.2,true);

		tf = new h2d.Text(Assets.fontLarge, spr);
		tf.text = String.fromCharCode( "A".code + letterIdx );
		tf.x = Std.int( -tf.textWidth*0.5);
		tf.y = Std.int( -tf.textHeight*0.5);
		tf.blendMode = Add;
		tf.textColor = color;
		tf.smooth = true;

		cd.setS("fadeIn", 1);
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	public static inline function count() {
		var n = 0;
		for( e in ALL )
			if( !e.destroyed )
				n++;
		return n;
	}

	public static function get(letterIdx) : Null<Letter> {
		for(e in ALL)
			if( !e.destroyed && !e.done && e.letterIdx==letterIdx )
				return e;
		return null;
	}

	public static function createOneRandom() : Letter {
		// Try to pick a non-recent letter
		var lidx = R.irnd(0,25);
		var limit = 100;
		while( recents.exists(lidx) && haxe.Timer.stamp()-recents.get(lidx)<=5 && limit-->0 )
			lidx = R.irnd(0,25);


		var l = new Letter(lidx);

		// Try to find an empy screen location
		var limit = 50;
		var retry = true;
		while( retry && limit-->0 ) {
			retry = false;
			var p = 64;
			l.setPosPixel( R.rnd(p, Game.ME.wid-p), R.rnd(p, Game.ME.hei-p) );

			for(e in ALL)
				if( e!=l && e.distPx(l)<=80 ) {
					retry = true;
					break;
				}
		}

		return l;
	}

	public function validate() {
		done = true;
		cd.setS("keep",0.3);

		ds = 0.03;
		sprScaleX += 0.1;
		sprScaleY += 0.1;

		tf.textColor = White;

		fx.halo(attachX, attachY, 0.7, color, 0.4);
		fx.explosion(attachX, attachY, color);
		fx.sparksBall(attachX, attachY, 100, color);

		var n = 5;
		for(i in 0...n)
			game.delayer.addS(
				fx.sparksBall.bind(attachX+rnd(20,40,true), attachY+rnd(20,40,true), rnd(60,80), color),
				0.1 + 0.6*i/n + rnd(0,0.05,true)
			);
	}

	override function postUpdate() {
		super.postUpdate();

		// Float around
		spr.x += Math.cos(ftime*0.027+floatOff)*4;
		spr.y += Math.sin(ftime*0.031+floatOff)*3;

		// Alpha anims
		if( !done )
			spr.alpha = ( 0.7 + 0.3*Math.sin(ftime*0.012) ) * (1-cd.getRatio("fadeIn"));
		else
			spr.alpha = 1 * cd.getRatio("keep");

		// Scale anim
		sprScaleX+=ds*tmod;
		sprScaleY+=ds*tmod;
		ds*=Math.pow(0.9,tmod);

	}


	override function fixedUpdate() {
		super.fixedUpdate();

		// Kill
		if( done && !cd.has("keep") )
			destroy();
	}
}