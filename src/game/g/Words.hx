package g;

class Words extends Game {
	var curWord : String;

	public function new() {
		super();
		pickWord();
	}

	function setWord(w:String) {
		// Cleanup
		for(e in Letter.ALL)
			e.destroy();

		curWord = w.toUpperCase();
		var lwid = 50;
		var i = 0;
		var offX = rnd(0,100,true);
		var offY = rnd(0,100,true);
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
		setWord("gabriel");
	}

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
		cd.setS("nextLock", 2);
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()==0 && !cd.has("nextLock") )
			pickWord();
	}
}