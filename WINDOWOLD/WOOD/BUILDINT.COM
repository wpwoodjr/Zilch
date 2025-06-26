$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ ass 'f$logical("USR$CLP") q
$ ass [.wood.tmp] w
$ set def [.tmp]
$ @build
$ set def [--]
$ compile/nolist/disable=(debug,trace) -
		movc,-
		fillc,-
		cmpc,-
		findnew,-
		gpopen,-
		def
$ com/sym/nolist/noche/nodeb -
	/link=(/noma/notr/nodeb/exe=q:zilch -
				movc,fillc,cmpc,findnew,gpopen,def,-
				w:roff,w:crypt,w:io,-
				icr$library:icr/lib) -
		EDIT,-
		q:KEY,-
		EDFUNC,-
		WORD,-
		REGION,-
		INSERT,-
		COMMAND,-
		checkp,-
		q:SCREEN/nocheck/nodebug,-
		session,-
		ALLOC,-
		string,-
		q:UPDATE/nocheck/nodebug,-
		COST,-
		TECON/noch,-
		IOBUFFER,-
		TTY,-
		macro,-
		bind,-
		PROMPT,-
		FILEIO,-
		TEXT,-
		hollerith,-
		BUFFER,-
		WINDOW,-
		PAGE,-
		message,-
		q:INDENT,-
		MARK,-
		SEARCH,-
		MAPPINGS,-
		dcl,-
		HELP,-
		spfiles,-
		PUSHB,-
		q:interface
$done:
$ deass q
$ deass w
$ set default usr$clp
$ if save_verify then set verify
