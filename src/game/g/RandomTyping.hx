package g;

class RandomTyping extends Game {
	var maxLetters = 1;
	var curSubScore = 0;
	var score = 0;

	public function new() {
		super();
	}

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
		score++;
		curSubScore++;
		if( curSubScore>=maxLetters*10 ) {
			curSubScore = 0;
			maxLetters++;
		}
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()<maxLetters )
			Letter.createOne();
	}
}