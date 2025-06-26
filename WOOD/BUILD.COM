$ save_verify := 'f$verify("NO")'
$ on control_y then goto done
$ on error then goto done
$ if p1 .eqs. "" then p1 = "ZBIND"
$ set def [-]
$ compile/nolist/disable=(debug,trace)/libr=zilch -
		movc,-
		fillc,-
		cmpc,-
		findnew,-
		gpopen
$ compile/symbols/nolist/nocheck/nodebug/libr=zilch -
		macro,-
		bind/inc=bind.cmn,-
		fileio,-
		text,-
		hollerith,-
		buffer,-
		window,-
		page,-
		message,-
		indent,-
		mark,-
		search,-
		mappings,-
		dcl,-
		help,-
		spfiles,-
		pushb
$ compile/symbols/nolist/nocheck/nodebug/libr=zilch -
		[]screen/nocheck/nodebug,-
		session,-
		alloc,-
		string,-
		update/nocheck/nodebug,-
		cost,-
		tecon/noch,-
		iobuffer,-
		tty,-
		edfunc,-
		word,-
		region,-
		insert,-
		command,-
		checkp
$ compile/symbols/nolist/nocheck/nodebug -
	/link=(/nomap/notr/nodeb/exe=[.wood]zilch -
				zilch/lib, -
				[.wood]zilch/options, -
				icr$library:icr/lib) -
		edit,-
		[.wood]'p1'
$done:
$ set default [.wood]
$ if save_verify then set verify
