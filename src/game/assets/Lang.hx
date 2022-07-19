package assets;

import dn.data.GetText;

class Lang {
    static var _initDone = false;
    public static var CUR = "??";
    public static var t : GetText;

    public static function init(?lid:String) {
        if( _initDone )
            return;

        _initDone = true;
        CUR = lid==null ? getSysLang() : lid;
        var res =
            try hxd.Res.load("lang/"+CUR+".po")
            catch(_) {
                CUR = "en";
                hxd.Res.load("lang/"+CUR+".po");
            }

		t = new GetText();
		t.readPo( res.entry.getBytes() );
    }

    public static function untranslated(str:Dynamic) : LocaleString {
        init();
        return t.untranslated(str);
    }

	public static function getSysLang() {
		try {
			var code = hxd.System.getLocale();
			if( code.indexOf("-")>=0 )
				code = code.substr(0,code.indexOf("-") );
			return code.toLowerCase();
		}
		catch(_)
			return "en";
	}
}