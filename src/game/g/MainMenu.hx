package g;

typedef MenuOption = {
	var i : h2d.Interactive;
	var tf : h2d.Text;
	var cb : Void->Void;
}

class MainMenu extends Game {
	var cur = 0;
	var curOption(get,never) : MenuOption;
	var options : Array<MenuOption> = [];
	var menuFlow : h2d.Flow;
	var cursor : HSprite;

	public function new() {
		super();

		menuFlow = new h2d.Flow(root);
		menuFlow.layout = Vertical;
		menuFlow.horizontalAlign = Left;
		menuFlow.verticalSpacing = 2;

		cursor = Assets.tiles.h_get(D.tiles.menuCursor, menuFlow);
		menuFlow.getProperties(cursor).isAbsolute = true;
		cursor.x = -4;
		cursor.setCenterRatio(1, 0.5);

		addOption( L._("Words"), ()->App.ME.startGame( ()->new g.Words() ) );
		addOption( L._("Alphabet"), ()->App.ME.startGame( ()->new g.Alphabet() ) );
		addOption( L._("Letters"), ()->App.ME.startGame( ()->new g.RandomTyping() ) );

		dn.Process.resizeAll();
	}

	inline function get_curOption() return options[cur];

	override function onResize() {
		super.onResize();

		menuFlow.setScale(Const.UI_SCALE);
		menuFlow.x = Std.int( w()*0.5-menuFlow.outerWidth*menuFlow.scaleX*0.5 );
		menuFlow.y = Std.int( h()*0.5-menuFlow.outerHeight*menuFlow.scaleY*0.5 );
	}

	function addOption(label:String, cb:Void->Void) {
		var i = new h2d.Interactive(1,1, menuFlow);
		var tf = new h2d.Text(Assets.fontPixel, i);
		tf.text = label;
		i.width = tf.textWidth;
		i.height = tf.textHeight;

		options.push({
			i: i,
			tf: tf,
			cb: cb,
		});
	}

	override function postUpdate() {
		super.postUpdate();

		if( ca.isPressed(MenuUp) && cur>0 )
			cur--;

		if( ca.isPressed(MenuDown) && cur<options.length-1 )
			cur++;

		if( ca.isPressed(MenuConfirm) )
			curOption.cb();

		if( ca.isPressed(MenuCancel) )
			App.ME.exit();

		cursor.y += ( curOption.i.y + curOption.i.height*0.5 - cursor.y ) * 0.5;
	}
}