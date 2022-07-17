package assets;

import dn.heaps.slib.*;

/**
	This class centralizes all assets management (ie. art, sounds, fonts etc.)
**/
class Assets {
	// Fonts
	public static var fontPixel : h2d.Font;
	public static var fontPixelMono : h2d.Font;
	public static var fontLarge : h2d.Font;

	/** Main atlas **/
	public static var tiles : SpriteLib;


	static var _initDone = false;
	public static function init() {
		if( _initDone )
			return;
		_initDone = true;

		// Fonts
		fontPixel = new hxd.res.BitmapFont( hxd.Res.fonts.pixel_unicode_regular_12_xml.entry ).toFont();
		fontPixelMono = new hxd.res.BitmapFont( hxd.Res.fonts.pixica_mono_regular_16_xml.entry ).toFont();
		fontLarge = new hxd.res.BitmapFont( hxd.Res.fonts.noto_sans_semibold_65_xml.entry ).toFont();

		// build sprite atlas directly from Aseprite file
		tiles = dn.heaps.assets.Aseprite.convertToSLib(Const.FPS, hxd.Res.atlas.tiles.toAseprite());

		// Hot-reloading of CastleDB
		#if debug
		hxd.Res.data.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("cdb");
			App.ME.delayer.addS("cdb", function() {
				CastleDb.load( hxd.Res.data.entry.getBytes().toString() );
				Const.db.reload_data_cdb( hxd.Res.data.entry.getText() );
			}, 0.2);
		});
		#end

		// Parse castleDB JSON
		CastleDb.load( hxd.Res.data.entry.getText() );

		// Hot-reloading of `const.json`
		hxd.Res.const.watch(function() {
			// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
			App.ME.delayer.cancelById("constJson");
			App.ME.delayer.addS("constJson", function() {
				Const.db.reload_const_json( hxd.Res.const.entry.getBytes().toString() );
			}, 0.2);
		});
	}


	/**
		Pass `tmod` value from the game to atlases, to allow them to play animations at the same speed as the Game.
		For example, if the game has some slow-mo running, all atlas anims should also play in slow-mo
	**/
	public static function update(tmod:Float) {
		if( Game.exists() && Game.ME.isPaused() )
			tmod = 0;

		tiles.tmod = tmod;
		// <-- add other atlas TMOD updates here
	}

}