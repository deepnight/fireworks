package g;

class Words extends Game {
	static var WORD_COOLDOWN_S = 15;
	var curWord : String;
	var recentWords : Map<String,Float> = new Map();

	public function new() {
		super();
		pickWord();
	}

	function setWord(w:String) {
		// Cleanup
		for(e in Letter.ALL)
			e.destroy();

		curWord = w.toUpperCase();
		var lwid = 65;
		var i = 0;
		var offX = rnd(0,80,true);
		var offY = rnd(0,80,true);
		for( c in curWord.split("") ) {
			var l = new Letter(c.charCodeAt(0) - "A".code);
			l.setPosPixel(
				wid*0.5 - curWord.length*lwid*0.5 + i*lwid+rnd(0,5,true) + offX,
				hei*0.5+rnd(0,10,true) + offY
			);
			i++;
		}
	}

	function pickWord() {
		var w = R.pick(Assets.words);
		var limit = 100;
		while( recentWords.exists(w) && haxe.Timer.stamp()-recentWords.get(w)<=WORD_COOLDOWN_S && limit-->0 )
			w = R.pick(Assets.words);
		setWord(w);
	}

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
		cd.setS("nextLock", 3);

		// Word complete
		if( Letter.count()==0 ) {
			recentWords.set( curWord, haxe.Timer.stamp() );
			// Victory fireworks
			var n = 12;
			for(i in 0...n) {
				delayer.addS( ()->{
					var f = new Firework();
					f.fromBottom(
						rnd(100, wid-100),
						hei - rnd(100,200)
					);
					},
					0.8*i/n + rnd(0,0.1,true)
				);
			}
		}
	}



	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()==0 && !cd.has("nextLock") )
			pickWord();
	}
}