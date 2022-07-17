import h2d.Sprite;
import dn.heaps.HParticle;


class Fx extends GameProcess {
	var pool : ParticlePool;

	public var bg_add    : h2d.SpriteBatch;
	public var bg_normal    : h2d.SpriteBatch;
	public var main_add       : h2d.SpriteBatch;
	public var main_normal    : h2d.SpriteBatch;

	public function new() {
		super();

		pool = new ParticlePool(Assets.tiles.tile, 4096, Const.FPS);

		bg_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_add, Const.DP_FX_BG);
		bg_add.blendMode = Add;
		bg_add.hasRotationScale = true;

		bg_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bg_normal, Const.DP_FX_BG);
		bg_normal.hasRotationScale = true;

		main_normal = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_normal, Const.DP_FX_FRONT);
		main_normal.hasRotationScale = true;

		main_add = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(main_add, Const.DP_FX_FRONT);
		main_add.blendMode = Add;
		main_add.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();
		bg_add.remove();
		bg_normal.remove();
		main_add.remove();
		main_normal.remove();
	}

	/** Clear all particles **/
	public function clear() {
		pool.clear();
	}

	/** Create a HParticle instance in the BG layer, using ADDITIVE blendmode **/
	public inline function allocBg_add(id,x,y) return pool.alloc(bg_add, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the BG layer, using NORMAL blendmode **/
	public inline function allocBg_normal(id,x,y) return pool.alloc(bg_normal, Assets.tiles.getTileRandom(id), x, y);

	/** Create a HParticle instance in the MAIN layer, using ADDITIVE blendmode **/
	public inline function allocMain_add(id,x,y) return pool.alloc( main_add, Assets.tiles.getTileRandom(id), x, y );

	/** Create a HParticle instance in the MAIN layer, using NORMAL blendmode **/
	public inline function allocMain_normal(id,x,y) return pool.alloc(main_normal, Assets.tiles.getTileRandom(id), x, y);


	public inline function markerEntity(e:Entity, c:Col=Pink, short=false) {
		#if debug
		if( e!=null && e.isAlive() )
			markerCase(e.cx, e.cy, short?0.03:3, c);
		#end
	}

	public inline function markerCase(cx:Int, cy:Int, sec=3.0, c:Col=Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxCircle15, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.lifeS = sec;

		var p = allocMain_add(D.tiles.pixel, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.lifeS = sec;
		#end
	}

	public inline function markerFree(x:Float, y:Float, sec=3.0, c:Col=Pink) {
		#if debug
		var p = allocMain_add(D.tiles.fxDot, x,y);
		p.setCenterRatio(0.5,0.5);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.lifeS = sec;
		#end
	}

	public inline function markerText(cx:Int, cy:Int, txt:String, t=1.0) {
		#if debug
		var tf = new h2d.Text(Assets.fontPixel, main_normal);
		tf.text = txt;

		var p = allocMain_add(D.tiles.fxCircle15, (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPosition(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
		#end
	}

	public inline function flashBangS(c:Col, a:Float, t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_FRONT);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});
	}


	public inline function halo(x:Float, y:Float, scale:Float, c:Col, alpha=0.2) {
		var p = allocMain_add(D.tiles.fxLightCircle, x,y);
		p.setFadeS(R.aroundBO(alpha), 0, R.around(0.7));
		p.setScale(scale);
		p.colorAnimS(c, "#3656dd", 1);
		p.ds = 0.1;
		p.dsFrict = 0.9;
		p.lifeS = 0.6;
	}


	public function sparksTrail(x:Float, y:Float, c:Col, ang:Float) {
		var p = allocMain_add(D.tiles.fxLineThinLeft, x, y);
		p.setCenterRatio(1,0.5);
		p.setFadeS(R.around(0.6), 0.1, 0.4);
		p.colorize(c);
		p.scaleX = rnd(0.3,0.6);
		p.scaleY = rnd(1,2);
		p.moveAng(ang, rnd(1,2));
		p.rotation = ang;
		p.frict = 0.9;
		p.alphaFlicker = 0.7;
		p.lifeS = R.around(0.5);
	}


	public function shoot(x:Float, y:Float, ang:Float, c:Col) {
		for(i in 0...10) {
			var p = allocMain_add( D.tiles.fxImpact, x,y);
			p.setFadeS(R.around(0.6), 0, 0.15);
			p.setCenterRatio(1, 0.5);
			p.rotation = ang + M.A180;
			p.scaleX = rnd(1.5,2);
			p.scaleY = rnd(0.5, 1.1, true);
			p.scaleXMul = rnd(1, 1.02);
			p.scaleYMul = rnd(0.97, 0.99);
			p.colorize(c);
			p.lifeS = R.around(0.1);
		}

		for(i in 0...20) {
			var p = allocMain_add(D.tiles.pixel, x, y);
			p.moveAng(ang+rnd(0, 0.06, true), rnd(3,5));
			p.frict = R.aroundBO(0.9,7);
			p.colorize(c);
			p.lifeS = rnd(0.1, 0.4);
		}
	}


	public function explosion(x:Float, y:Float, c:Col) {
		var n = 20;
		for(i in 0...n) {
			var a = M.A360 * i/n + rnd(0,0.2,true);
			var p = allocMain_add( D.tiles.fxImpact, x, y);
			p.setFadeS(rnd(0.4,0.6), 0, 0.1);
			p.setCenterRatio(1,0.5);
			p.colorize(c);
			p.rotation = a;
			p.scaleX = rnd(0.5, 0.7);
			p.scaleY = rnd(0.5,1,true);
			p.dsX = rnd(0.1,0.2);
			p.dsFrict = R.aroundBO(0.92);
			p.scaleYMul = rnd(0.96, 0.98);
			p.lifeS = rnd(0.1,0.2);
		}
	}


	public inline function sparksBall(x:Float, y:Float, radius:Float, c:Col) {
		// Lines
		var n = M.ceil( 90*radius/30 );
		for(i in 0...n) {
			var a = R.fullCircle();
			var dr = rnd(0, 0.3);
			var p = allocMain_add(D.tiles.fxLineThinLeft, x+Math.cos(a)*dr*radius, y+Math.sin(a)*dr*radius);
			p.setFadeS(rnd(0.6, 0.9), 0, R.around(0.3));
			p.colorAnimS(c, "#810c0c", rnd(0.5,2));
			p.alphaFlicker = 0.7;
			p.scaleX = rnd(0.4,0.6);
			p.scaleY = rnd(1,2,true);
			p.autoRotate();
			p.scaleXMul = rnd(0.95, 0.97);
			p.moveAwayFrom( x, y, R.around(1.5, 15) * (0.5+0.5*dr) * (1*radius/60) );
			p.frict = R.aroundBO(0.98, 4);
			p.gy = R.around(0.02, 5);
			p.lifeS = rnd(0.5,0.7);
		}

		// Dots
		var n = M.ceil( 90*radius/30 );
		for(i in 0...n) {
			var a = R.fullCircle();
			var dr = rnd(0.15, 0.8);
			var p = allocMain_add(D.tiles.pixel, x+Math.cos(a)*dr*radius, y+Math.sin(a)*dr*radius);
			p.setFadeS(rnd(0.5, 0.7), 0, R.around(0.3));
			p.colorAnimS(c, "#810c0c", rnd(0.5,2));
			p.alphaFlicker = 0.7;
			p.moveAwayFrom( x, y, R.around(0.3, 15) * (0.5+0.5*dr) * (1*radius/100) );
			p.frict = R.aroundBO(0.97, 4);
			p.gy = R.around(0.005, 5);
			p.lifeS = rnd(0.8, 1.4);
			p.delayS = 0.6 + rnd(0, 0.3);
		}
	}


	public function paintLine(fx:Float, fy:Float, tx:Float, ty:Float, c:Col) {
		var d = M.dist(fx,fy, tx,ty);
		var a = M.angTo(fx,fy, tx,ty);
		var n = M.ceil(d/3);
		var step = d/n;
		for(i in 0...n) {
			var p = allocMain_add(D.tiles.fxLine, fx+Math.cos(a)*i*step + rnd(0,1,true), fy+Math.sin(a)*i*step + rnd(0,1,true));
			p.setCenterRatio(0.1,0.5);
			p.setFadeS( rnd(0.4,1), 0.1, R.around(1));
			p.gy = rnd(0, 0.0015);
			p.alphaFlicker = 0.2;
			p.scaleX = 0.1 + R.around(1) * step/p.t.width;
			p.rotation = a;
			p.colorize(c);
			p.frict = R.aroundBO(0.92,4);
			p.lifeS = rnd(2,3);

			var p = allocMain_add(D.tiles.pixel, fx+Math.cos(a)*i*step + rnd(0,2,true), fy+Math.sin(a)*i*step + rnd(0,2,true));
			p.setFadeS( rnd(0.6,0.8), 0.1, R.around(1));
			p.gy = rnd(0, 0.003);
			p.alphaFlicker = 0.4;
			p.colorize(c);
			p.frict = R.aroundBO(0.92,4);
			p.lifeS = rnd(2,3);
		}
	}


	/**
		A small sample to demonstrate how basic particles work. This example produces a small explosion of yellow dots that will fall and slowly fade to purple.

		USAGE: fx.dotsExplosionExample(50,50, 0xffcc00)
	**/
	public inline function dotsExplosionExample(x:Float, y:Float, color:Col) {
		for(i in 0...80) {
			var p = allocMain_add( D.tiles.fxDot, x+rnd(0,3,true), y+rnd(0,3,true) );
			p.alpha = rnd(0.4,1);
			p.colorAnimS(color, 0x762087, rnd(0.6, 3)); // fade particle color from given color to some purple
			p.moveAwayFrom(x,y, rnd(1,3)); // move away from source
			p.frict = rnd(0.8, 0.9); // friction applied to velocities
			p.gy = rnd(0, 0.02); // gravity Y (added on each frame)
			p.lifeS = rnd(2,3); // life time in seconds
		}
	}


	override function update() {
		super.update();
		pool.update(game.tmod);
	}
}