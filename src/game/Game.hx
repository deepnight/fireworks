class Game extends dn.Process {
	public static var ME : Game;

	/** Game controller (pad or keyboard) **/
	public var ca : ControllerAccess<GameAction>;

	/** Particles **/
	public var fx : Fx;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** UI **/
	public var hud : ui.Hud;

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;
	var slowMos : Map<String, { id:String, t:Float, f:Float }> = new Map();

	var inter : h2d.Interactive;
	var bg : h2d.Bitmap;

	public var wid(get,never) : Int;  inline function get_wid() return M.ceil( w()/Const.SCALE );
	public var hei(get,never) : Int;  inline function get_hei() return M.ceil( h()/Const.SCALE );

	var bgWrapper : h2d.Object;
	var lastClick : Null<LPoint>;

	public function new() {
		super(App.ME);

		ME = this;
		ca = App.ME.controller.createAccess();
		ca.lockCondition = isGameControllerLocked;
		ca.lock(0.1);
		createRootInLayers(App.ME.root, Const.DP_BG);
		dn.Gc.runNow();

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.Nothing(); // force rendering for pixel perfect

		bg = new h2d.Bitmap( h2d.Tile.fromColor(Const.COLOR_BG), scroller );
		fx = new Fx();
		hud = new ui.Hud();

		inter = new h2d.Interactive(w(), h(), root);
		inter.propagateEvents = true;
		inter.onPush = onMouseDown;
		inter.onRelease = onMouseUp;
		inter.onReleaseOutside = onMouseUp;
		inter.onOut = onMouseUp;
		inter.onMove = onMouseMove;
		inter.onKeyDown = onKeyDown;

		start();
	}


	function onMouseDown(ev:hxd.Event) {
		lastClick = LPoint.fromScreen( ev.relX, ev.relY );
	}


	function onMouseUp(ev:hxd.Event) {
		if( lastClick!=null ) {
			var f = new en.Firework();
			f.fromBottom(lastClick.levelX, lastClick.levelY);
			lastClick = null;
		}
	}

	function onKeyDown(ev:hxd.Event) {
		if( !ca.isKeyboardDown(K.SHIFT) && !ca.isKeyboardDown(K.CTRL) && !ca.isKeyboardDown(K.ALT) && ev.keyCode>=K.A && ev.keyCode<=K.Z )
			onLetterPress( ev.keyCode-K.A );
	}

	function onLetterPress(letterIdx:Int) {}


	function onMouseMove(ev:hxd.Event) {
		if( lastClick==null )
			return;

		var cur = LPoint.fromScreen(ev.relX, ev.relY);
		if( lastClick!=null && lastClick.distPx(cur)>=8 ) {
			fx.paintLine(
				lastClick.levelX, lastClick.levelY,
				cur.levelX, cur.levelY,
				Const.COLOR_BG.toWhite(0.4)
			);
			lastClick = cur;
		}
	}


	public static function isGameControllerLocked() {
		return !exists() || ME.isPaused() || App.ME.anyInputHasFocus();
	}


	public static inline function exists() {
		return ME!=null && !ME.destroyed;
	}


	/** Load a level **/
	function start() {
		fx.clear();
		for(e in Entity.ALL) // <---- Replace this with more adapted entity destruction (eg. keep the player alive)
			e.destroy();
		garbageCollectEntities();

		bgWrapper = new h2d.Object();
		scroller.add(bgWrapper, Const.DP_BG);

		hud.onLevelStart();
		dn.Process.resizeAll();
		dn.Gc.runNow();
	}


	function renderBg() {
		var rseed = new dn.Rand(1);
		bgWrapper.removeChildren();

		// Dark gradient
		var gradient = Assets.tiles.h_get(D.tiles.gradient, bgWrapper);
		gradient.scaleX = wid / gradient.tile.width;
		gradient.scaleY = hei / gradient.tile.height;
		gradient.blendMode = Multiply;
		gradient.alpha = 0.6;

		// Stars
		var sb = new HSpriteBatch(Assets.tiles.tile, bgWrapper);
		sb.hasRotationScale = true;
		sb.blendMode = Add;
		var c = Const.COLOR_BG.clone();
		c.saturation*=0.7;
		c.lightness = 0.8;
		for(i in 0...700) {
			var be = Assets.tiles.hbe_get(sb, D.tiles.pixel);
			be.colorize(c);
			be.scaleX = be.scaleY = rseed.irange(1,2);
			be.x = rseed.range(0,wid);
			be.y = rseed.range(0,hei-30);
			be.alpha = 0.1 + 0.9 * (1-be.y/hei) * rseed.range(0.3,1);
		}

		// Trees
		var sb = new HSpriteBatch(Assets.tiles.tile, bgWrapper);
		sb.hasRotationScale = true;
		var x = rseed.irange(0,10);
		var s = 2;
		while( x<wid ) {
			var be = Assets.tiles.hbe_getRandom(sb, D.tiles.tree, rseed.random);
			be.setCenterRatio();
			be.scaleX = s * rseed.range(0.9,1.1,true);
			be.scaleY = s * rseed.range(0.8,1.1);
			be.rotation = rseed.range(0,0.1,true);
			be.colorize(0x0);
			be.x = x;
			be.y = hei + rseed.irange(-6,3);
			x += rseed.irange(6,10)*s;
		}
	}



	/** Called when either CastleDB or `const.json` changes on disk **/
	@:allow(App)
	function onDbReload() {
		hud.notify("DB reloaded");
	}


	/** Window/app resize event **/
	override function onResize() {
		super.onResize();

		inter.width = w();
		inter.height = h();

		bg.scaleX = M.ceil( w()/Const.SCALE );
		bg.scaleY = M.ceil( h()/Const.SCALE );

		scroller.setScale(Const.SCALE);

		renderBg();
	}


	/** Garbage collect any Entity marked for destruction. This is normally done at the end of the frame, but you can call it manually if you want to make sure marked entities are disposed right away, and removed from lists. **/
	public function garbageCollectEntities() {
		if( Entity.GC==null || Entity.GC.allocated==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC.empty();
	}

	/** Called if game is destroyed, but only at the end of the frame **/
	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		garbageCollectEntities();

		if( ME==this )
			ME = null;
	}


	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and all its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:String, sec:Float, speedFactor=0.3) {
		if( slowMos.exists(id) ) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		}
		else
			slowMos.set(id, { id:id, t:sec, f:speedFactor });
	}


	/** The loop that updates slow-mos **/
	final function updateSlowMos() {
		// Timeout active slow-mos
		for(s in slowMos) {
			s.t -= utmod * 1/Const.FPS;
			if( s.t<=0 )
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for(s in slowMos)
			targetGameSpeed*=s.f;
		curGameSpeed += (targetGameSpeed-curGameSpeed) * (targetGameSpeed>curGameSpeed ? 0.2 : 0.6);

		if( M.fabs(curGameSpeed-targetGameSpeed)<=0.001 )
			curGameSpeed = targetGameSpeed;
	}


	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}


	/** Loop that happens at the beginning of the frame **/
	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	/** Loop that happens at the end of the frame **/
	override function postUpdate() {
		super.postUpdate();

		// Update slow-motions
		updateSlowMos();
		baseTimeMul = ( 0.2 + 0.8*curGameSpeed ) * ( ucd.has("stopFrame") ? 0.3 : 1 );
		Assets.tiles.tmod = tmod;

		// Entities post-updates
		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();

		// Entities final updates
		for(e in Entity.ALL) if( !e.destroyed ) e.finalUpdate();

		// Dispose entities marked as "destroyed"
		garbageCollectEntities();
	}


	/** Main loop but limited to 30 fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();

		// Entities "30 fps" loop
		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}


	/** Main loop **/
	override function update() {
		super.update();

		// Entities main loop
		for(e in Entity.ALL) if( !e.destroyed ) e.frameUpdate();


		// Global key shortcuts
		if( !App.ME.anyInputHasFocus() && !ui.Modal.hasAny() && !Console.ME.isActive() ) {

			// Exit by pressing ESC twice
			#if hl
			if( ca.isKeyboardPressed(K.ESCAPE) )
				if( !cd.hasSetS("exitWarn",3) )
					hud.notify("Press ESCAPE again to exit.");
				else
					App.ME.goToMainMenu();
			#end

			// Exit current game
			if( ca.isPressed(Restart) )
				App.ME.goToMainMenu();

		}
	}
}

