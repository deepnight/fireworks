package en;

class PendingLetter extends Entity {
	public var letterIdx : Int;
	var color : Col;
	var done = false;
	var ds = 0.;

	public function new(letterIdx:Int) {
		super(0,0);
		var p = 64;
		setPosPixel( rnd(p,game.wid-p), rnd(p,game.hei-p) );

		this.letterIdx = letterIdx;
		spr.set(D.tiles.empty);
		color = Col.randomHSL(R.zto(), R.around(0.7,20), 1);

		var tf = new h2d.Text(Assets.fontLarge, spr);
		tf.text = String.fromCharCode( "A".code + letterIdx );
		tf.x = Std.int( -tf.textWidth*0.5);
		tf.y = Std.int( -tf.textHeight*0.5);
		tf.blendMode = Add;
		tf.textColor = color;

		cd.setS("fadeIn", 1);
	}

	public static function createOne() : PendingLetter {
		var l = new PendingLetter( R.irnd(0,25) );
		return l;
	}

	override function postUpdate() {
		super.postUpdate();

		spr.x += Math.cos(ftime*0.027)*4;
		spr.y += Math.sin(ftime*0.031)*3;

		if( !done )
			spr.alpha = ( 0.7 + 0.3*Math.sin(ftime*0.012) ) * (1-cd.getRatio("fadeIn"));
		else
			spr.alpha = 0.2 * cd.getRatio("keep");

		// Scale anim
		sprScaleX+=ds*tmod;
		sprScaleY+=ds*tmod;
		ds*=Math.pow(0.9,tmod);

		if( !done && game.ca.isKeyboardPressed(K.A + letterIdx) ) {
			done = true;
			ds = 0.03;
			sprScaleX += 0.1;
			sprScaleY += 0.1;
			cd.setS("keep",0.5);
			fx.halo(attachX, attachY, 1, color, 0.3);
			fx.explosion(attachX, attachY, color);
			fx.sparksBall(attachX, attachY, 70, color);
			var n = 4;
			for(i in 0...4)
				game.delayer.addS(
					fx.sparksBall.bind(attachX+rnd(10,30,true), attachY+rnd(10,30,true), rnd(40,60), color),
					0.1 + 0.4*i/n
				);

			createOne();
		}

		if( done && !cd.has("keep") )
			destroy();
	}
}