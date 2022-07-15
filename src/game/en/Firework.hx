package en;

class Firework extends Entity {
	var target : LPoint;
	var col : Col;

	public function new(x,y) {
		super(0,0);
		col = Yellow;
		setPosPixel(x+rnd(20,60,true), game.h()/Const.SCALE);
		target = LPoint.fromPixels(x,y);
		frict = 0.94;
		dy = -rnd(0.1,0.2);
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		var s = rnd(0.01, 0.02);
		var a = Math.atan2(target.levelY-attachY, target.levelX-attachX);
		dx += Math.cos(a) * s;
		dy += Math.sin(a) * s;

		if( attachY<=target.levelY ) {
			destroy();
			fx.halo(attachX, attachY, 1, col);
			fx.sparksBall(attachX, attachY, rnd(20,100), col);
		}
	}
}