package g;

class Alphabet extends Game {
	var score = 0;
	var curLetterId = -1;

	public function new() {
		super();
	}

	override function getBgColor() return Col.inlineHex("#343c4d");
	override function getMidColor() return Col.inlineHex("#488177");
	override function getSunColor() return Col.inlineHex("#40ad6b");

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
		score++;
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()==0 ) {
			curLetterId++;
			if( curLetterId>=26 )
				curLetterId = 0;
			Letter.createOne( curLetterId );
		}
	}
}