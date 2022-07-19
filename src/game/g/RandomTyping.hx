package g;

class RandomTyping extends Game {
	var letterCount = 1;
	var curSubScore = 0;
	var score = 0;
	var lettersDeck : dn.struct.RandDeck<Int>;

	public function new() {
		super();

		lettersDeck = new RandDeck();
		for(i in 0...26)
			lettersDeck.push(i);
		lettersDeck.shuffle();
	}

	override function getBgColor() return Col.inlineHex("#4d2424");
	override function getMidColor() return Col.inlineHex("#375a79");
	override function getSunColor() return Yellow;

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
		score++;
		curSubScore++;
		if( curSubScore>=letterCount*10 ) {
			curSubScore = 0;
			letterCount++;
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()==0 )
			for(i in 0...letterCount)
				Letter.createOne( lettersDeck.draw() );
	}
}