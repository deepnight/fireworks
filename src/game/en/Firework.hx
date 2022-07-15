package en;

class Firework extends Entity {
	var target : LPoint;
	public var color : Col;

	public function new() {
		super(0,0);
		color = Yellow;
		frict = R.around(0.95, 3);
	}

	public function fromBottom(x:Float, y:Float) {
		setPosPixel(x+rnd(20,60,true), game.h()/Const.SCALE);
		target = LPoint.fromPixels(x,y);
		dy = -rnd(0.1,0.2);
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
			fx.halo(attachX, attachY, 1, color);
			fx.sparksBall(attachX, attachY, rnd(20,100), color);
		}
	}
}