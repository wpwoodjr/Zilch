$ compile/sym/nodebug/nocheck/nolist -
		/link=(icr$library:rat/lib,icr$library:icr/lib) -
	roff
