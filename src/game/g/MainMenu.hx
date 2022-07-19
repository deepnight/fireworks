package g;

typedef MenuOption = {
	var i : h2d.Interactive;
	var tf : h2d.Text;
	var cb : Void->Void;
}

class MainMenu extends Game {
	var cur = 0;
	var options : Array<MenuOption> = [];
	var menuFlow : h2d.Flow;

	public function new() {
		super();

		menuFlow = new h2d.Flow(root);
		menuFlow.layout = Vertical;
		menuFlow.horizontalAlign = Middle;
		menuFlow.verticalSpacing = 2;

		addOption( "Words", ()->App.ME.startGame( ()->new g.Words() ) );
		addOption( "Letters", ()->App.ME.startGame( ()->new g.RandomTyping() ) );

		dn.Process.resizeAll();
	}

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
}