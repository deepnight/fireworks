package en;

class Firework extends Entity {
	var target : LPoint;
	public var color : Col;

	public function new() {
		super(0,0);
		color = Col.randomHSL(rnd(0,1), rnd(0.3,0.7), 1);
		frict = R.around(0.95, 3);
		spr.set(D.tiles.empty);
	}

	public function fromBottom(x:Float, y:Float) {
		fx.halo(x,y, rnd(0.1,0.2), color, 0.06);

		setPosPixel(x+rnd(20,60,true), game.h()/Const.SCALE);
		target = LPoint.fromPixels(x,y);
		var a = Math.atan2(target.levelY-attachY, target.levelX-attachX);
		dx = Math.cos(a)*0.1;
		dy = Math.sin(a)*0.1;
		dy -= rnd(0.1,0.2);

		fx.halo(attachX, attachY, rnd(0.1,0.2), color);
		fx.shoot(attachX, attachY+8, Math.atan2(dy,dx), color);
	}

	override function postUpdate() {
		super.postUpdate();

		if( !cd.hasSetS("tail",0.03) )
			fx.sparksTrail(attachX, attachY, color, Math.atan2(dy,dx));
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		var s = rnd(0.01, 0.02);
		var a = Math.atan2(target.levelY-attachY, target.levelX-attachX);
		dx += Math.cos(a) * s;
		dy += Math.sin(a) * s;

		// Reached target
		if( distPx(target.levelX, target.levelY)<=20 ) {
			destroy();
			fx.halo(attachX, attachY, 1, color, 0.25);
			fx.explosion(attachX, attachY, color);
			fx.sparksBall(attachX, attachY, rnd(90,100), color);
		}
	}
}