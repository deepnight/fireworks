package g;

class SingleLetter extends Game {
	var maxLetters = 1;

	public function new() {
		super();
	}

	override function onLetterPress(letterIdx:Int) {
		super.onLetterPress(letterIdx);

		var e = Letter.get(letterIdx);
		if( e==null )
			return;

		e.validate();
	}

	override function fixedUpdate() {
		super.fixedUpdate();

		if( Letter.count()<maxLetters )
			Letter.createOne();
	}
}