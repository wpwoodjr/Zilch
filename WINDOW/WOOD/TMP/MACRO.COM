$ !
$ ! This file builds just the macro preproccessor of Ratfiv.
$ ! Input passes through the macro processor unchanged except
$ ! when macros are expanded. The macros are the same as in Ratfiv,
$ ! except that "define" is not available; use "_macro" instead.
$ ! Also, the dot character (.) is legal in macro names.
$ !
$ compile/symbols/nodebug/nocheck -
	/link = (/nodebug/notrace/exe=macro -
		icr$library:rat/lib,icr$library:icr/lib) -
	macsym. + macsrc.arc + dummy2.rat
