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

		var base = Col.randomHSL(R.zto(), rnd(0.7,0.9), 1);
		var colors = [
			base,
			base.adjustHsl(0.4, 0,0),
			base.adjustHsl(0.2, 0,0),
		];

		var lwid = 60;
		var i = 0;
		var offX = rnd(0,20,true);
		var offY = rnd(0,80,true);
		for( c in curWord.split("") ) {
			var l = new Letter(c.charCodeAt(0) - "A".code, colors[ M.round( (colors.length-1) * i/(curWord.length-1) ) ]);
			l.setPosPixel(
				wid*0.5 - curWord.length*lwid*0.5 + i*lwid+rnd(0,5,true) + offX,
				hei*0.5+rnd(0,10,true) + offY
			);
			i++;
		}
	}

	function pickWord() {
		setWord( Assets.wordPicker.draw() );
	}

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.getFirstLeft(letterIdx);
		if( e==null )
			return;

		e.validate();
		cd.setS("nextLock", 3);

		// Word complete
		if( Letter.count()==0 ) {
			// Victory fireworks
			var n = 12;
			for(i in 0...n) {
				delayer.addS( ()->{
					var f = new Firework();
					f.fromBottom(
						rnd(100, wid-100),
						hei - rnd(100,200),
						false
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