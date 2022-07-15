package tools;

class GameProcess extends dn.Process {
	public var app(get,never) : App; inline function get_app() return App.ME;
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.exists() ? Game.ME.fx : null;

	public function new() {
		super(Game.ME);
	}
}