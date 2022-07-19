import dn.data.GetText;

class LangParser {
	public static function main() {
		// Extract from source code
		var all = GetText.parseSourceCode("src");

		// Extract from CastleDB
		all = all.concat( GetText.parseCastleDB("res/data.cdb") );

		// Write POT
		GetText.writePOT("res/lang/sourceTexts.pot",all);

		Sys.println("Done.");
	}
}